# Troubleshooting Kubernetes Cluster với kubeadm

## Các vấn đề thường gặp và cách khắc phục

### 0. Preflight checks failed

**Triệu chứng:**
```bash
error execution phase preflight: [preflight] Some fatal errors occurred:
        [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist
        [ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1
```

**Cách khắc phục:**
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

# Hoặc chạy script fix
chmod +x fix-network-config.sh
./fix-network-config.sh
```

### 1. Node không Ready

**Triệu chứng:**
```bash
kubectl get nodes
# Output: node-name   NotReady   worker   0   v1.28.0
```

**Nguyên nhân và cách khắc phục:**

#### 1.1 Kubelet không chạy
```bash
# Kiểm tra kubelet status
sudo systemctl status kubelet

# Khởi động kubelet nếu không chạy
sudo systemctl start kubelet
sudo systemctl enable kubelet

# Kiểm tra logs
sudo journalctl -u kubelet -f
```

#### 1.2 Container runtime không chạy
```bash
# Kiểm tra containerd status
sudo systemctl status containerd

# Khởi động containerd nếu không chạy
sudo systemctl start containerd
sudo systemctl enable containerd

# Kiểm tra logs
sudo journalctl -u containerd -f
```

#### 1.3 CNI không được cài đặt
```bash
# Kiểm tra CNI pods
kubectl get pods -n kube-system | grep calico

# Cài đặt lại Calico nếu cần
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### 2. Pod không thể tạo được

**Triệu chứng:**
```bash
kubectl get pods
# Output: pod-name   Pending   0/1   Pending
```

**Nguyên nhân và cách khắc phục:**

#### 2.1 Không có node nào available
```bash
# Kiểm tra nodes
kubectl get nodes

# Kiểm tra taints
kubectl describe nodes | grep Taints

# Xóa taint nếu cần
kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane:NoSchedule-
```

#### 2.2 Image pull error
```bash
# Kiểm tra pod events
kubectl describe pod <pod-name>

# Kiểm tra image pull secrets
kubectl get secrets

# Tạo image pull secret nếu cần
kubectl create secret docker-registry <secret-name> \
  --docker-server=<registry-server> \
  --docker-username=<username> \
  --docker-password=<password>
```

### 3. Service không accessible

**Triệu chứng:**
```bash
# Service không accessible từ bên ngoài
curl http://<service-ip>:<port>
# Connection refused
```

**Nguyên nhân và cách khắc phục:**

#### 3.1 Security Group không mở port
```bash
# Kiểm tra security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Thêm rule cho NodePort
aws ec2 authorize-security-group-ingress \
  --group-id <sg-id> \
  --protocol tcp \
  --port 30000-32767 \
  --cidr 0.0.0.0/0
```

#### 3.2 Service selector không match
```bash
# Kiểm tra service selector
kubectl get service <service-name> -o yaml

# Kiểm tra pod labels
kubectl get pods --show-labels

# Cập nhật service selector nếu cần
kubectl patch service <service-name> -p '{"spec":{"selector":{"app":"<correct-label>"}}}'
```

### 4. DNS không hoạt động

**Triệu chứng:**
```bash
# Pod không thể resolve DNS
kubectl exec -it <pod-name> -- nslookup kubernetes.default
# nslookup: can't resolve 'kubernetes.default'
```

**Nguyên nhân và cách khắc phục:**

#### 4.1 CoreDNS pods không chạy
```bash
# Kiểm tra CoreDNS pods
kubectl get pods -n kube-system | grep coredns

# Kiểm tra CoreDNS logs
kubectl logs -n kube-system coredns-<pod-name>

# Restart CoreDNS nếu cần
kubectl delete pod -n kube-system coredns-<pod-name>
```

#### 4.2 Kube-dns service không có endpoints
```bash
# Kiểm tra kube-dns service
kubectl get service kube-dns -n kube-system

# Kiểm tra endpoints
kubectl get endpoints kube-dns -n kube-system
```

### 5. Certificate issues

**Triệu chứng:**
```bash
# Certificate expired
kubectl get nodes
# error: You must be logged in to the server (the server has a client certificate that has expired)
```

**Cách khắc phục:**

#### 5.1 Renew certificates
```bash
# Renew certificates
sudo kubeadm certs renew all

# Restart kubelet
sudo systemctl restart kubelet
```

#### 5.2 Check certificate expiration
```bash
# Check certificate expiration dates
sudo kubeadm certs check-expiration
```

### 6. Network connectivity issues

**Triệu chứng:**
```bash
# Pods không thể communicate với nhau
kubectl exec -it <pod-1> -- ping <pod-2-ip>
# Destination Host Unreachable
```

**Nguyên nhân và cách khắc phục:**

#### 6.1 CNI không được cấu hình đúng
```bash
# Kiểm tra CNI config
ls -la /etc/cni/net.d/

# Kiểm tra CNI binaries
ls -la /opt/cni/bin/

# Restart CNI pods
kubectl delete pods -n kube-system -l k8s-app=calico-node
```

#### 6.2 Network policies blocking traffic
```bash
# Kiểm tra network policies
kubectl get networkpolicies --all-namespaces

# Xóa network policy nếu cần
kubectl delete networkpolicy <policy-name> -n <namespace>
```

### 7. Resource issues

**Triệu chứng:**
```bash
# Pod bị evicted
kubectl get pods
# Output: pod-name   Evicted   0/1   Evicted
```

**Nguyên nhân và cách khắc phục:**

#### 7.1 Insufficient memory/CPU
```bash
# Kiểm tra node resources
kubectl top nodes

# Kiểm tra pod resources
kubectl top pods

# Scale down hoặc tăng resources
kubectl scale deployment <deployment-name> --replicas=1
```

#### 7.2 Disk pressure
```bash
# Kiểm tra disk usage
df -h

# Clean up unused images
sudo ctr images prune -a

# Clean up unused containers
sudo ctr containers prune
```

### 8. Logs và Debugging

#### 8.1 Kubelet logs
```bash
# Xem kubelet logs
sudo journalctl -u kubelet -f

# Xem kubelet logs với timestamp
sudo journalctl -u kubelet --since="1 hour ago"
```

#### 8.2 Container runtime logs
```bash
# Xem containerd logs
sudo journalctl -u containerd -f

# Xem containerd logs với timestamp
sudo journalctl -u containerd --since="1 hour ago"
```

#### 8.3 API server logs
```bash
# Xem API server logs
sudo journalctl -u kube-apiserver -f

# Hoặc nếu chạy trong container
kubectl logs -n kube-system kube-apiserver-<node-name>
```

#### 8.4 Scheduler logs
```bash
# Xem scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name>
```

#### 8.5 Controller manager logs
```bash
# Xem controller manager logs
kubectl logs -n kube-system kube-controller-manager-<node-name>
```

### 9. Health check commands

```bash
# Kiểm tra cluster health
kubectl get componentstatuses

# Kiểm tra node health
kubectl describe nodes

# Kiểm tra pod health
kubectl get pods --all-namespaces -o wide

# Kiểm tra service health
kubectl get services --all-namespaces

# Kiểm tra events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### 10. Reset và Recovery

#### 10.1 Reset single node
```bash
# Reset node
sudo kubeadm reset --force

# Clean up
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
```

#### 10.2 Reset entire cluster
```bash
# Trên tất cả nodes
sudo kubeadm reset --force
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# Trên master node, init lại
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

### 11. Performance tuning

#### 11.1 Kubelet configuration
```bash
# Tăng max pods per node
sudo sed -i 's/maxPods: 110/maxPods: 200/' /var/lib/kubelet/config.yaml
sudo systemctl restart kubelet
```

#### 11.2 Container runtime tuning
```bash
# Tăng max concurrent downloads
sudo sed -i 's/max_concurrent_downloads = 3/max_concurrent_downloads = 10/' /etc/containerd/config.toml
sudo systemctl restart containerd
```

### 12. Security issues

#### 12.1 Certificate rotation
```bash
# Rotate certificates
sudo kubeadm certs renew all

# Restart services
sudo systemctl restart kubelet
```

#### 12.2 RBAC issues
```bash
# Kiểm tra RBAC
kubectl auth can-i get pods
kubectl auth can-i create deployments

# Tạo service account nếu cần
kubectl create serviceaccount <service-account-name>
kubectl create clusterrolebinding <binding-name> --clusterrole=<role> --serviceaccount=<namespace>:<service-account-name>
```

## Lưu ý quan trọng cho CKA

1. **Logs**: Biết cách đọc và phân tích logs từ các components
2. **Events**: Hiểu cách sử dụng `kubectl get events` để debug
3. **Describe**: Sử dụng `kubectl describe` để xem chi tiết resources
4. **Network**: Hiểu cách debug network connectivity issues
5. **Certificates**: Biết cách renew và manage certificates
6. **Resources**: Hiểu cách monitor và manage resource usage
7. **Security**: Biết cách troubleshoot RBAC và security issues 