#!/bin/bash

# Script cài đặt Worker Node cho Kubernetes Cluster
# Sử dụng cho Ubuntu 22.04 LTS

set -e

echo "=== Bắt đầu cài đặt Worker Node ==="

# Kiểm tra tham số
if [ $# -eq 0 ]; then
    echo "Sử dụng: $0 <master-ip> <token> <discovery-token-ca-cert-hash>"
    echo "Ví dụ: $0 192.168.1.10 abcdef.1234567890abcdef sha256:1234567890abcdef..."
    exit 1
fi

MASTER_IP=$1
TOKEN=$2
DISCOVERY_TOKEN_CA_CERT_HASH=$3

echo "Master IP: $MASTER_IP"
echo "Token: $TOKEN"
echo "Discovery Token CA Cert Hash: $DISCOVERY_TOKEN_CA_CERT_HASH"

# Cập nhật hệ thống
echo "Cập nhật hệ thống..."
sudo apt update && sudo apt upgrade -y

# Tắt swap
echo "Tắt swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Cấu hình network cho Kubernetes
echo "Cấu hình network..."
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

# Cài đặt dependencies
echo "Cài đặt dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Cài đặt containerd
echo "Cài đặt containerd..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y containerd.io

# Cấu hình containerd
echo "Cấu hình containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Cài đặt Kubernetes components
echo "Cài đặt Kubernetes components..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Cấu hình kubelet
echo "Cấu hình kubelet..."
sudo mkdir -p /etc/systemd/system/kubelet.service.d
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/override.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF
sudo systemctl daemon-reload

# Join cluster
echo "Join cluster..."
sudo kubeadm join $MASTER_IP:6443 \
  --token $TOKEN \
  --discovery-token-ca-cert-hash $DISCOVERY_TOKEN_CA_CERT_HASH

echo "=== Cài đặt Worker Node hoàn tất ==="
echo "Kiểm tra trên master node: kubectl get nodes" 