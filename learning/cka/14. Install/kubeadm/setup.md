# Kubernetes Cluster Setup using kubeadm

## 1. Requirements

### System Requirements
- **Operating System**: Ubuntu 20.04+ or CentOS 7+
- **CPU**: 2+ cores per node
- **Memory**: 2GB+ RAM per node
- **Storage**: 20GB+ available disk space
- **Network**: Unique hostname, MAC address, and product_uuid for each node
- **Ports**: 
  - Control plane: 6443, 2379-2380, 10250, 10251, 10252
  - Worker nodes: 10250, 30000-32767

### Node Preparation
```bash
# Set unique hostname for each node
sudo hostnamectl set-hostname <node-name>

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load required kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay          # Container filesystem support
br_netfilter    # Bridge networking + iptables support
EOF

sudo modprobe overlay      # Load overlay module immediately
sudo modprobe br_netfilter # Load br_netfilter module immediately
```

## 2. Install kubeadm (setup all nodes)

**What is kubeadm?**
- **kubeadm** is the official Kubernetes tool for bootstrapping a cluster
- **Purpose**: Automate the installation and configuration of Kubernetes clusters
- **Functions**: 
  - Initialize control plane node (master)
  - Join worker nodes to the cluster
  - Configure certificates, networking, and components
  - Generate kubeconfig files

**Reference**: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

### Update package repository and install dependencies
```bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

### Add Kubernetes repository
```bash
# Download and add the GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### Install Kubernetes components
```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Prevent automatic updates
sudo apt-mark hold kubelet kubeadm kubectl
```

### Verify installation
```bash
# Check versions
kubeadm version
kubectl version --client
kubelet --version
```

## 3. Install Container Runtime

**Reference**: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

**Why Container Runtime?**
- **Container Runtime** is required to run containers (pods) on Kubernetes nodes
- **Kubernetes** doesn't run containers directly - it delegates to a container runtime
- **containerd** is the recommended runtime (lightweight, stable, CNCF project)

**What is systemd cgroup driver?**
- **cgroups** (control groups) manage resource allocation for processes
- **systemd cgroup driver** ensures Kubernetes and systemd use the same cgroup hierarchy
- **Required** for proper resource management and monitoring
- **Prevents conflicts** between systemd and Kubernetes resource tracking

### Install containerd
```bash
sudo apt update
sudo apt install -y containerd
```

### Network Configuration
```bash
# Enable IPv4 packet forwarding
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Verify that net.ipv4.ip_forward is set to 1
sysctl net.ipv4.ip_forward
```

**Network Configuration Parameters Explained:**

1. **`net.ipv4.ip_forward = 1`**
   - **Purpose**: Enables IP packet forwarding between network interfaces
   - **Why needed**: Kubernetes pods on different nodes need to communicate
   - **Impact**: Allows traffic routing between pods across nodes

2. **`net.bridge.bridge-nf-call-iptables = 1`**
   - **Purpose**: Enables iptables rules to work on bridge interfaces
   - **Why needed**: kube-proxy creates iptables rules for service networking
   - **Impact**: Services and network policies can function properly

3. **`net.bridge.bridge-nf-call-ip6tables = 1`**
   - **Purpose**: Same as above but for IPv6 (dual-stack support)
   - **Why needed**: Future-proofing for IPv6 networking
   - **Impact**: Ensures compatibility with IPv6-enabled clusters

### Configure containerd with systemd cgroup driver
```bash
# Check current cgroup driver
ps -p 1

# Create containerd config directory
sudo mkdir -p /etc/containerd

# Generate default config and enable systemd cgroup driver
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# Verify containerd is running
sudo systemctl status containerd
```

## 4. Creating a Cluster with kubeadm

**Reference**: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

### Initialize Control Plane Node
```bash
# Initialize the cluster (run only on control plane node)
sudo kubeadm init \
  --apiserver-advertise-address=<control-plane-ip> \
  --pod-network-cidr=10.244.0.0/16 \
  --upload-certs \
  --control-plane-endpoint=<control-plane-endpoint> \
  --kubernetes-version=v1.33.0

# Example with specific values:
sudo kubeadm init \
  --apiserver-advertise-address=192.168.1.100 \
  --pod-network-cidr=10.244.0.0/16 \
  --upload-certs \
  --control-plane-endpoint=192.168.1.100:6443 \
  --kubernetes-version=v1.33.0
```

### Configure kubectl for control plane user
```bash
# Create .kube directory
mkdir -p $HOME/.kube

# Copy admin config
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Set ownership
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### Install Network Addon

**Why Network Addon is Required?**

Kubernetes core components **do not include** a network implementation. After cluster initialization, pods cannot communicate with each other because:

1. **No Pod-to-Pod Communication**: Pods on different nodes cannot reach each other
2. **No Service Networking**: Services cannot route traffic between pods
3. **No Network Policies**: Cannot implement network security rules
4. **Cluster Not Functional**: Applications cannot communicate internally

**What Network Addon Provides:**
- **Pod Networking**: Enables communication between pods across nodes
- **Service Discovery**: Allows services to find and route to pods
- **Network Policies**: Implements network security and isolation
- **Load Balancing**: Distributes traffic across multiple pods

**Reference**: https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy

#### Option 1: Flannel (recommended for beginners)
```bash
# Download Flannel manifest
curl -O https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Edit the manifest to ensure pod network CIDR matches (10.244.0.0/16)
# Apply the manifest
kubectl apply -f kube-flannel.yml

# Verify Flannel pods are running
kubectl get pods -n kube-flannel
```

#### Option 2: Calico
```bash
# Install Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

# Verify Calico installation
kubectl get pods -n calico-system
```

### Join Worker Nodes to Cluster

After successful initialization, kubeadm will output a join command. Use this command on each worker node:

```bash
# On each worker node, run the join command from the control plane output
sudo kubeadm join <control-plane-endpoint>:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>

# Example:
sudo kubeadm join 192.168.1.100:6443 \
  --token abcdef.1234567890abcdef \
  --discovery-token-ca-cert-hash sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

### Verify Cluster Status
```bash
# Check all nodes
kubectl get nodes

# Check all pods across all namespaces
kubectl get pods --all-namespaces

# Check cluster info
kubectl cluster-info

# Check component status
kubectl get componentstatuses
```

## 5. Post-Installation Steps

### Remove Taints from Control Plane (for single-node clusters)
```bash
# Only if you want to schedule pods on control plane
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### Install Additional Tools (Optional)
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install kubectl plugins
kubectl krew install access-matrix
kubectl krew install view-secret
kubectl krew install neat
```

### Configure Storage Class (Optional)
```bash
# For local storage
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## 6. Troubleshooting

### Common Issues and Solutions

#### Node Not Ready
```bash
# Check node status
kubectl describe node <node-name>

# Check kubelet logs
sudo journalctl -u kubelet -f

# Check container runtime
sudo crictl ps
sudo crictl info
```

#### Pod Network Issues
```bash
# Check CNI configuration
ls /etc/cni/net.d/
cat /etc/cni/net.d/*

# Restart kubelet
sudo systemctl restart kubelet
```

#### Certificate Issues
```bash
# Check certificate expiration
kubeadm certs check-expiration

# Renew certificates if needed
kubeadm certs renew all
```

## 7. Cluster Maintenance

### Backup Cluster Configuration
```bash
# Backup kubeadm config
sudo cp /etc/kubernetes/admin.conf ~/kubeadm-backup/
sudo cp /etc/kubernetes/kubelet.conf ~/kubeadm-backup/
sudo cp /etc/kubernetes/pki/* ~/kubeadm-backup/pki/
```

### Upgrade Cluster
```bash
# Check available versions
apt-cache madison kubeadm

# Upgrade kubeadm first
sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=<version>
sudo apt-mark hold kubeadm

# Plan upgrade
sudo kubeadm upgrade plan

# Apply upgrade
sudo kubeadm upgrade apply v<version>
```

## 8. Security Considerations

### Network Policies
```bash
# Enable network policies for your CNI
# For Calico, they're enabled by default
# For Flannel, you may need additional components
```

### RBAC Configuration
```bash
# Review and configure RBAC as needed
kubectl get clusterroles
kubectl get clusterrolebindings
```

### Pod Security Standards
```bash
# Apply pod security standards
kubectl label namespace default pod-security.kubernetes.io/enforce=restricted
```

## 9. Monitoring and Logging

### Basic Monitoring
```bash
# Check resource usage
kubectl top nodes
kubectl top pods

# View logs
kubectl logs <pod-name> -n <namespace>
```

### Install Monitoring Stack (Optional)
```bash
# Install Prometheus and Grafana
kubectl create namespace monitoring
# Follow monitoring stack installation guide
```

## 10. Cleanup (if needed)

### Remove Worker Nodes
```bash
# Drain the node first
kubectl drain <node-name> --delete-emptydir-data --force --ignore-daemonsets

# Remove the node
kubectl delete node <node-name>

# On the worker node, reset kubeadm
sudo kubeadm reset
```

### Complete Cluster Reset
```bash
# On control plane node
sudo kubeadm reset --force

# Remove all Kubernetes data
sudo rm -rf /etc/kubernetes/
sudo rm -rf ~/.kube/
sudo rm -rf /var/lib/etcd/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /var/lib/cni/
sudo rm -rf /etc/cni/net.d/
```

---

**Note**: This guide assumes a basic single control plane cluster. For production environments, consider:
- Multiple control plane nodes for high availability
- External etcd cluster
- Load balancer for control plane endpoints
- Backup and disaster recovery procedures
- Security hardening and compliance requirements