#!/bin/bash

# Script reset Kubernetes Cluster

echo "=== Reset Kubernetes Cluster ==="

echo "Cảnh báo: Script này sẽ xóa toàn bộ cluster!"
read -p "Bạn có chắc chắn muốn tiếp tục? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Hủy bỏ reset cluster."
    exit 1
fi

echo "Bắt đầu reset cluster..."

# Reset kubeadm
echo "Reset kubeadm..."
sudo kubeadm reset --force

# Xóa CNI config
echo "Xóa CNI config..."
sudo rm -rf /etc/cni/net.d

# Xóa kubeconfig
echo "Xóa kubeconfig..."
rm -rf $HOME/.kube/config

# Xóa iptables rules
echo "Xóa iptables rules..."
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# Xóa IPVS rules
echo "Xóa IPVS rules..."
sudo ipvsadm -C

# Restart containerd
echo "Restart containerd..."
sudo systemctl restart containerd

echo "=== Reset cluster hoàn tất ==="
echo "Để cài đặt lại, chạy: sudo kubeadm init" 