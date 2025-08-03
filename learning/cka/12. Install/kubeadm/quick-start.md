# Quick Start - Cài đặt Kubernetes với kubeadm

## Tóm tắt các bước chính

### 1. Chuẩn bị EC2 Instances
```bash
# Tạo 2 EC2 instances:
# - Master: t3.medium (2 vCPU, 4GB RAM)
# - Worker: t3.small (2 vCPU, 2GB RAM)
# - OS: Ubuntu 22.04 LTS
# - Security Groups: SSH (22), NodePort (30000-32767), API (6443)
```

### 2. Cài đặt Master Node
```bash
# SSH vào master node
ssh -i your-key.pem ubuntu@<master-ip>

# Chạy script tự động
chmod +x setup-master.sh
./setup-master.sh

# Hoặc chạy từng bước thủ công:
# 1. sudo apt update && sudo apt upgrade -y
# 2. sudo swapoff -a
# 3. Cài đặt containerd
# 4. Cài đặt kubeadm, kubelet, kubectl
# 5. sudo kubeadm init --pod-network-cidr=10.244.0.0/16
# 6. kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### 3. Cài đặt Worker Node
```bash
# SSH vào worker node
ssh -i your-key.pem ubuntu@<worker-ip>

# Chạy script tự động
chmod +x setup-worker.sh
./setup-worker.sh <master-ip> <token> <discovery-token-ca-cert-hash>

# Hoặc chạy từng bước thủ công:
# 1. Cài đặt containerd và Kubernetes components (giống master)
# 2. sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### 4. Kiểm tra Cluster
```bash
# Trên master node
kubectl get nodes
kubectl get pods --all-namespaces

# Chạy script kiểm tra
chmod +x check-cluster.sh
./check-cluster.sh
```

### 5. Test Cluster
```bash
# Deploy ứng dụng test
kubectl create namespace test
kubectl run nginx --image=nginx --port=80 -n test
kubectl expose pod nginx --port=80 --target-port=80 --type=NodePort -n test

# Test access
kubectl get svc -n test
curl http://<worker-ip>:<nodeport>
```

## Các lệnh quan trọng

### Kubeadm Commands
```bash
# Khởi tạo cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Join worker node
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Tạo token mới
kubeadm token create --print-join-command

# Reset cluster
sudo kubeadm reset --force
```

### Kiểm tra Cluster
```bash
# Kiểm tra nodes
kubectl get nodes -o wide

# Kiểm tra pods
kubectl get pods --all-namespaces

# Kiểm tra services
kubectl get services --all-namespaces

# Kiểm tra events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### Troubleshooting
```bash
# Kiểm tra logs
sudo journalctl -u kubelet -f
sudo journalctl -u containerd -f

# Kiểm tra component status
kubectl get componentstatuses

# Kiểm tra node details
kubectl describe nodes
```

## Cấu hình Security Groups

### Master Node Security Group
- SSH (22): 0.0.0.0/0
- Kubernetes API (6443): 0.0.0.0/0
- NodePort range (30000-32767): 0.0.0.0/0

### Worker Node Security Group
- SSH (22): 0.0.0.0/0
- NodePort range (30000-32767): 0.0.0.0/0

## Lưu ý quan trọng

1. **IP Addresses**: Thay đổi IP addresses trong scripts và configs
2. **Security Groups**: Đảm bảo mở đúng ports
3. **Key Pair**: Sử dụng key pair có quyền SSH
4. **Region**: Chọn region phù hợp
5. **AMI**: Sử dụng Ubuntu 22.04 LTS AMI

## Troubleshooting nhanh

### Node không Ready
```bash
# Kiểm tra kubelet
sudo systemctl status kubelet
sudo systemctl start kubelet

# Kiểm tra containerd
sudo systemctl status containerd
sudo systemctl start containerd
```

### Pod không tạo được
```bash
# Kiểm tra nodes
kubectl get nodes

# Kiểm tra taints
kubectl describe nodes | grep Taints

# Xóa taint nếu cần
kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane:NoSchedule-
```

### Service không accessible
```bash
# Kiểm tra security group
aws ec2 describe-security-groups --group-ids <sg-id>

# Thêm NodePort rule
aws ec2 authorize-security-group-ingress --group-id <sg-id> --protocol tcp --port 30000-32767 --cidr 0.0.0.0/0
```

## Reset Cluster

```bash
# Trên tất cả nodes
sudo kubeadm reset --force
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# Trên master node, init lại
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
``` 