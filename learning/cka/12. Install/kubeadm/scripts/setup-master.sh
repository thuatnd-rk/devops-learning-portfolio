#!/bin/bash

# Script cài đặt Master Node cho Kubernetes Cluster
# Sử dụng cho Ubuntu 22.04 LTS

set -e

echo "=== Bắt đầu cài đặt Master Node ==="

# Cập nhật hệ thống
echo "Cập nhật hệ thống..."
sudo apt update && sudo apt upgrade -y

# Tắt swap
echo "Tắt swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

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

# Khởi tạo cluster
echo "Khởi tạo cluster..."
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) \
  --control-plane-endpoint=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) \
  --upload-certs \
  --ignore-preflight-errors=NumCPU

# Cấu hình kubectl
echo "Cấu hình kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Tạo join command
echo "Tạo join command..."
kubeadm token create --print-join-command > /tmp/join-command.txt
echo "Join command đã được lưu tại /tmp/join-command.txt"

# Cài đặt Calico CNI
echo "Cài đặt Calico CNI..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

echo "=== Cài đặt Master Node hoàn tất ==="
echo "Kiểm tra cluster: kubectl get nodes"
echo "Kiểm tra pods: kubectl get pods --all-namespaces" 