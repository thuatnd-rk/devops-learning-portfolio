# 🧰 Kubernetes Cluster Setup Guide (via `kubeadm`)

## ✅ Prerequisites

Before proceeding, ensure you have:

- One or more machines running **Debian/Ubuntu** or **CentOS/RHEL**
- **Ubuntu 20.04+** or **CentOS 7+** is recommended
- **At least 2 GiB RAM** per machine (for kubelet and system components)
- **At least 2 CPUs** on the machine acting as the control plane
- Access to the internet and administrative privileges (`sudo`)

---

## 🛠 Step 1: System Configuration

### 1.1 Disable Swap (Required by Kubernetes)

Swap must be disabled for the kubelet to function correctly.

```bash
# Temporary (until reboot):
sudo swapoff -a

# Permanent (edit /etc/fstab and comment out swap lines):
sudo vi /etc/fstab
# /dev/sdX none swap sw 0 0
# /swapfile none swap sw 0 0
```

> 🧠 **Why?** Kubernetes needs predictable memory management. Swap can interfere with scheduling and resource limits.

---

### 1.2 Enable IP Forwarding and Netfilter for Bridges

To allow Pods to communicate across nodes, Linux kernel settings must be adjusted.

```bash
# Load br_netfilter module
sudo modprobe br_netfilter

# Optional: make sure it's loaded on boot
echo 'br_netfilter' | sudo tee /etc/modules-load.d/k8s.conf
```

Now create the sysctl configuration:

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply settings immediately
sudo sysctl --system
```

> 💡 These settings ensure traffic through bridged interfaces (used in container networking) is visible to iptables.

---

## 📦 Step 2: Install Container Runtime (containerd)

### 2.1 Install `containerd`

```bash
sudo apt update
sudo apt install -y containerd
```

---

### 2.2 Configure Cgroup Driver (Use `systemd`)

**Control Groups (cgroups)** are a Linux kernel feature for managing system resources (CPU, memory, I/O). Kubernetes uses cgroups internally to allocate resources to Pods and containers via the kubelet.

There are two cgroup drivers:

- `cgroupfs`: The default for `kubelet`, interacts directly with `/sys/fs/cgroup`
- `systemd`: Recommended if your host OS uses `systemd` as the init system

> ⚠️ The container runtime (`containerd`) and `kubelet` **must use the same cgroup driver**. Kubernetes recommends using `systemd` for both on modern Linux distributions.

#### ✅ Check the host's init system

```bash
ps -p 1
```

If the output is `systemd`, proceed with the configuration below.

#### 🔧 Set containerd to use `systemd`

```bash
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
```

#### 🔧 Ensure kubelet also uses `systemd`

Edit `/var/lib/kubelet/config.yaml` if it exists, or it will be created after `kubeadm init`.

Make sure this is set:

```yaml
cgroupDriver: systemd
```

Restart kubelet if you've updated its config:

```bash
sudo systemctl restart kubelet
```

> 🛑 If these drivers are mismatched, `kubeadm` will fail to initialize the cluster with an error like:  
> `"kubelet cgroup driver: cgroupfs is different from container runtime cgroup driver: systemd"`

---

## 🔧 Step 3: Install Kubernetes Components

### 3.1 Add Kubernetes Package Repository

```bash
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

```bash
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

---

### 3.2 Install `kubeadm`, `kubelet`, and `kubectl`

```bash
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

> 📌 Holding versions prevents unintended upgrades that might break compatibility.

---

### 3.3 Enable kubelet Service

```bash
sudo systemctl enable --now kubelet
```

---

## 🚀 Step 4: Initialize Control Plane Node

```bash
sudo kubeadm init --apiserver-advertise-address=<NODE-IP> --pod-network-cidr=10.244.0.0/16 --upload-certs
```

**Parameter explanation:**

- `--apiserver-advertise-address`: Your machine’s internal IP (for cluster communication)
- `--pod-network-cidr`: CIDR block for pod networking. `10.244.0.0/16` is used by Flannel
- `--upload-certs`: Allows other control plane nodes to join easily

---

### Post-init Configuration (non-root user)

```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 🌐 Step 5: Install CNI Plugin (Flannel)

Download and apply the Flannel YAML:

```bash
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
# Optional: edit kube-flannel.yml if you changed the --pod-network-cidr
kubectl apply -f kube-flannel.yml
```

---

## 🤝 Step 6: Join Worker Nodes

On the control plane node, generate the join command:

```bash
kubeadm token create --print-join-command
```

Run this command on each worker node to join the cluster.

---

## 🔍 Step 7: Validate Cluster Status

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

Look for:
- All nodes in `Ready` state
- System pods (`coredns`, `kube-proxy`, etc.) in `Running` or `Completed` state