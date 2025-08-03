#!/bin/bash

# Script fix cấu hình network cho Kubernetes
# Chạy script này nếu gặp lỗi preflight checks

set -e

echo "=== Fix cấu hình network cho Kubernetes ==="

# Load kernel modules
echo "Loading kernel modules..."
sudo modprobe overlay
sudo modprobe br_netfilter

# Cấu hình sysctl
echo "Cấu hình sysctl..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl changes
echo "Applying sysctl changes..."
sudo sysctl --system

# Kiểm tra cấu hình
echo "Kiểm tra cấu hình..."
echo "net.bridge.bridge-nf-call-iptables: $(cat /proc/sys/net/bridge/bridge-nf-call-iptables)"
echo "net.bridge.bridge-nf-call-ip6tables: $(cat /proc/sys/net/bridge/bridge-nf-call-ip6tables)"
echo "net.ipv4.ip_forward: $(cat /proc/sys/net/ipv4/ip_forward)"

echo "=== Fix cấu hình network hoàn tất ==="
echo "Bây giờ có thể chạy lại kubeadm init" 