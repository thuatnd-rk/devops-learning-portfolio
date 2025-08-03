# Cài đặt Kubernetes Cluster bằng kubeadm trên EC2

## Tổng quan
Hướng dẫn cài đặt Kubernetes cluster sử dụng kubeadm trên AWS EC2 với cấu hình tối thiểu cho lab:
- 1 Master node (Control Plane)
- 1 Worker node
- Container runtime: containerd
- Network plugin: Calico

## Yêu cầu hệ thống

### Master Node (Control Plane)
- **Instance Type**: t3.medium (2 vCPU, 4GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 20GB EBS
- **Security Group**: 
  - SSH (22)
  - Kubernetes API (6443)
  - NodePort range (30000-32767)

### Worker Node
- **Instance Type**: t3.small (2 vCPU, 2GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 20GB EBS
- **Security Group**: 
  - SSH (22)
  - NodePort range (30000-32767)

## Bước 1: Chuẩn bị EC2 Instances

### 1.1 Tạo EC2 Instances

```bash
# Tạo Security Group cho Master
aws ec2 create-security-group \
  --group-name k8s-master-sg \
  --description "Security group for Kubernetes master node"

# Tạo Security Group cho Worker
aws ec2 create-security-group \
  --group-name k8s-worker-sg \
  --description "Security group for Kubernetes worker node"

# Thêm rules cho Master Security Group
aws ec2 authorize-security-group-ingress \
  --group-name k8s-master-sg \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name k8s-master-sg \
  --protocol tcp \
  --port 6443 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name k8s-master-sg \
  --protocol tcp \
  --port 30000-32767 \
  --cidr 0.0.0.0/0

# Thêm rules cho Worker Security Group
aws ec2 authorize-security-group-ingress \
  --group-name k8s-worker-sg \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-name k8s-worker-sg \
  --protocol tcp \
  --port 30000-32767 \
  --cidr 0.0.0.0/0

# Tạo Master Node
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --count 1 \
  --instance-type t3.medium \
  --key-name your-key-pair \
  --security-group-ids k8s-master-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=k8s-master}]'

# Tạo Worker Node
aws ec2 run-instances \
  --image-id ami-0c02fb55956c7d316 \
  --count 1 \
  --instance-type t3.small \
  --key-name your-key-pair \
  --security-group-ids k8s-worker-sg \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=k8s-worker}]'
```

### 1.2 Ghi chú IP Addresses
```bash
# Lấy IP của Master node
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=k8s-master" \
  --query 'Reservations[].Instances[].PublicIpAddress' \
  --output text

# Lấy IP của Worker node
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=k8s-worker" \
  --query 'Reservations[].Instances[].PublicIpAddress' \
  --output text
```

## Bước 2: Cài đặt trên Master Node

### 2.1 SSH vào Master Node
```bash
ssh -i your-key.pem ubuntu@<master-ip>
```

### 2.2 Cập nhật hệ thống
```bash
sudo apt update && sudo apt upgrade -y
```

### 2.3 Tắt swap
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

### 2.4 Cấu hình network cho Kubernetes
```bash
# Load kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Cấu hình sysctl
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl changes
sudo sysctl --system
```

### 2.5 Cài đặt containerd
```bash
# Cài đặt dependencies
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Thêm Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Thêm Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cài đặt containerd
sudo apt update
sudo apt install -y containerd.io

# Cấu hình containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Cấu hình systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
```

### 2.5 Cài đặt Kubernetes components
```bash
# Thêm Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Thêm Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Cài đặt kubeadm, kubelet, kubectl
sudo apt update
sudo apt install -y kubelet kubeadm kubectl

# Hold version để tránh auto update
sudo apt-mark hold kubelet kubeadm kubectl
```

### 2.6 Cấu hình kubelet
```bash
# Cấu hình kubelet để sử dụng containerd
sudo mkdir -p /etc/systemd/system/kubelet.service.d
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/override.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF

# Reload systemd
sudo systemctl daemon-reload
```

### 2.7 Khởi tạo cluster
```bash
# Khởi tạo cluster với cấu hình tối thiểu
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) \
  --control-plane-endpoint=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) \
  --upload-certs \
  --ignore-preflight-errors=NumCPU

# Cấu hình kubectl cho user ubuntu
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Lưu join command cho worker node
kubeadm token create --print-join-command > /tmp/join-command.txt
```

### 2.8 Cài đặt Calico CNI
```bash
# Cài đặt Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Kiểm tra pods
kubectl get pods --all-namespaces
```

## Bước 3: Cài đặt trên Worker Node

### 3.1 SSH vào Worker Node
```bash
ssh -i your-key.pem ubuntu@<worker-ip>
```

### 3.2 Thực hiện các bước tương tự Master (bước 2.2 - 2.6)
```bash
# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Tắt swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Cấu hình network cho Kubernetes (tương tự bước 2.4)
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Cài đặt containerd (tương tự bước 2.5)
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y containerd.io
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Cài đặt Kubernetes components (tương tự bước 2.5)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Cấu hình kubelet (tương tự bước 2.6)
sudo mkdir -p /etc/systemd/system/kubelet.service.d
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/override.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF
sudo systemctl daemon-reload
```

### 3.3 Join cluster
```bash
# Copy join command từ Master node
# Hoặc chạy lệnh sau trên Master để lấy join command
# kubeadm token create --print-join-command

# Thực hiện join command (thay thế bằng command thực tế từ Master)
sudo kubeadm join <master-ip>:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

## Bước 4: Kiểm tra cluster

### 4.1 Trên Master Node
```bash
# Kiểm tra nodes
kubectl get nodes

# Kiểm tra pods trong tất cả namespaces
kubectl get pods --all-namespaces

# Kiểm tra services
kubectl get services --all-namespaces

# Kiểm tra cluster info
kubectl cluster-info

# Kiểm tra component status
kubectl get componentstatuses
```

### 4.2 Test cluster với ứng dụng đơn giản
```bash
# Tạo namespace test
kubectl create namespace test

# Deploy nginx
kubectl run nginx --image=nginx --port=80 -n test

# Expose service
kubectl expose pod nginx --port=80 --target-port=80 --type=NodePort -n test

# Kiểm tra service
kubectl get svc -n test

# Test access (thay thế <worker-ip> và <nodeport>)
curl http://<worker-ip>:<nodeport>
```

## Bước 5: Cấu hình bổ sung

### 5.1 Cấu hình kubectl cho remote access
```bash
# Trên máy local, tạo kubeconfig
mkdir -p ~/.kube
scp -i your-key.pem ubuntu@<master-ip>:/home/ubuntu/.kube/config ~/.kube/config

# Test kết nối
kubectl get nodes
```

### 5.2 Cấu hình metrics server (tùy chọn)
```bash
# Cài đặt metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Patch để bỏ qua TLS verification (cho lab)
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# Kiểm tra
kubectl top nodes
kubectl top pods --all-namespaces
```

### 5.3 Cấu hình dashboard (tùy chọn)
```bash
# Cài đặt dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Tạo service account
kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin

# Lấy token
kubectl -n kubernetes-dashboard create token dashboard-admin

# Port forward để access
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443
```

## Bước 6: Monitoring và Troubleshooting

### 6.1 Kiểm tra logs
```bash
# Kiểm tra kubelet logs
sudo journalctl -u kubelet -f

# Kiểm tra containerd logs
sudo journalctl -u containerd -f

# Kiểm tra kubeadm logs
sudo journalctl -u kubeadm -f
```

### 6.2 Kiểm tra cluster health
```bash
# Kiểm tra cluster components
kubectl get componentstatuses

# Kiểm tra nodes
kubectl describe nodes

# Kiểm tra pods
kubectl get pods --all-namespaces -o wide

# Kiểm tra events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### 6.3 Reset cluster (nếu cần)
```bash
# Trên Master node
sudo kubeadm reset
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config

# Trên Worker node
sudo kubeadm reset
sudo rm -rf /etc/cni/net.d
```

## Lưu ý quan trọng cho CKA

1. **Kubeadm Commands**: Hiểu rõ các lệnh kubeadm init, join, reset
2. **Container Runtime**: Hiểu cách cấu hình containerd
3. **CNI**: Hiểu cách cài đặt và cấu hình network plugin
4. **Troubleshooting**: Biết cách debug các vấn đề thường gặp
5. **Security**: Hiểu về certificates, tokens, và security groups
6. **Networking**: Hiểu về pod network CIDR và service networking

## Practice Commands

```bash
# Khởi tạo cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Join worker node
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Kiểm tra cluster
kubectl get nodes
kubectl get pods --all-namespaces

# Reset cluster
sudo kubeadm reset

# Cài đặt CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Kiểm tra logs
sudo journalctl -u kubelet -f
sudo journalctl -u containerd -f
```

## Tài liệu tham khảo

- [Kubernetes Documentation - Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
- [Calico Documentation](https://docs.projectcalico.org/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Containerd Documentation](https://containerd.io/docs/) 