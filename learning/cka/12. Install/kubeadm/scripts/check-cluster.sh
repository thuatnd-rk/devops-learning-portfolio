#!/bin/bash

# Script kiểm tra trạng thái Kubernetes Cluster

echo "=== Kiểm tra trạng thái Kubernetes Cluster ==="

echo ""
echo "1. Kiểm tra nodes:"
kubectl get nodes -o wide

echo ""
echo "2. Kiểm tra pods trong tất cả namespaces:"
kubectl get pods --all-namespaces

echo ""
echo "3. Kiểm tra services:"
kubectl get services --all-namespaces

echo ""
echo "4. Kiểm tra cluster info:"
kubectl cluster-info

echo ""
echo "5. Kiểm tra component status:"
kubectl get componentstatuses

echo ""
echo "6. Kiểm tra events (10 events gần nhất):"
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -10

echo ""
echo "7. Kiểm tra system pods:"
kubectl get pods -n kube-system -o wide

echo ""
echo "8. Kiểm tra Calico pods:"
kubectl get pods -n kube-system | grep calico

echo ""
echo "9. Kiểm tra kubelet status:"
sudo systemctl status kubelet --no-pager -l

echo ""
echo "10. Kiểm tra containerd status:"
sudo systemctl status containerd --no-pager -l

echo ""
echo "=== Kiểm tra hoàn tất ===" 