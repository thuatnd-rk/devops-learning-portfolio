# 6. Maintenance

## Tổng quan
Phần này bao gồm các khái niệm về bảo trì cluster Kubernetes, bao gồm backup, restore, upgrades, và troubleshooting.

## Nội dung chính

### 1. Backup và Restore
- **Backup:** Sao lưu cluster state và data
- **Restore:** Khôi phục cluster từ backup
- **Components cần backup:**
  - etcd data
  - Static pod manifests
  - Configuration files
  - Certificates

**Backup etcd:**
```bash
# Backup etcd
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /backup/etcd-snapshot.db

# Restore etcd
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot restore /backup/etcd-snapshot.db
```

**Backup static pod manifests:**
```bash
# Backup manifests
sudo cp -r /etc/kubernetes/manifests/ /backup/manifests/

# Restore manifests
sudo cp -r /backup/manifests/ /etc/kubernetes/
```

**Backup certificates:**
```bash
# Backup certificates
sudo cp -r /etc/kubernetes/pki/ /backup/pki/

# Restore certificates
sudo cp -r /backup/pki/ /etc/kubernetes/
```

### 2. Cluster Upgrades
- **Upgrade Process:**
  1. Backup cluster
  2. Upgrade control plane
  3. Upgrade worker nodes
  4. Verify cluster health

**Upgrade kubeadm:**
```bash
# Upgrade kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.24.0-00

# Plan upgrade
sudo kubeadm upgrade plan

# Upgrade control plane
sudo kubeadm upgrade apply v1.24.0

# Upgrade kubelet và kubectl
sudo apt-get install -y kubelet=1.24.0-00 kubectl=1.24.0-00

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

**Upgrade worker nodes:**
```bash
# Drain node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Upgrade kubeadm, kubelet, kubectl
sudo apt-get update
sudo apt-get install -y kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00

# Upgrade node
sudo kubeadm upgrade node

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Uncordon node
kubectl uncordon <node-name>
```

### 3. OS Upgrades
- **Upgrade Process:**
  1. Drain node
  2. Upgrade OS
  3. Reboot node
  4. Verify node health
  5. Uncordon node

**Drain node:**
```bash
# Drain node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Check node status
kubectl get nodes

# Uncordon node
kubectl uncordon <node-name>
```

**Verify node health:**
```bash
# Check node status
kubectl get nodes

# Check node conditions
kubectl describe node <node-name>

# Check kubelet status
sudo systemctl status kubelet

# Check container runtime
sudo systemctl status containerd
```

### 4. Certificate Management
- **Certificate Rotation:** Thay đổi certificates định kỳ
- **Certificate Expiry:** Kiểm tra certificates sắp hết hạn

**Check certificate expiry:**
```bash
# Check certificate expiry
sudo kubeadm certs check-expiration

# Renew certificates
sudo kubeadm certs renew all

# Check specific certificate
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -A 2 "Validity"
```

**Manual certificate renewal:**
```bash
# Renew specific certificate
sudo kubeadm certs renew apiserver

# Renew all certificates
sudo kubeadm certs renew all

# Restart components
sudo systemctl restart kubelet
```

### 5. Resource Management
- **Resource Requests/Limits:** Quản lý CPU và memory
- **Resource Quotas:** Giới hạn resource usage
- **Limit Ranges:** Set default limits

**Resource Quotas:**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
```

**Limit Ranges:**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
      cpu: 500m
    defaultRequest:
      memory: 256Mi
      cpu: 250m
    type: Container
```

**Câu lệnh quan trọng:**
```bash
# Xem resource quotas
kubectl get resourcequota

# Xem limit ranges
kubectl get limitrange

# Xem resource usage
kubectl top nodes
kubectl top pods

# Xem resource requests/limits
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU_REQ:.spec.containers[0].resources.requests.cpu,CPU_LIMIT:.spec.containers[0].resources.limits.cpu,MEM_REQ:.spec.containers[0].resources.requests.memory,MEM_LIMIT:.spec.containers[0].resources.limits.memory
```

### 6. Troubleshooting
- **Node Issues:** Node not ready, kubelet problems
- **Pod Issues:** Pod not starting, container crashes
- **Network Issues:** Service connectivity, DNS problems

**Troubleshoot node issues:**
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check kubelet logs
sudo journalctl -u kubelet -f

# Check kubelet configuration
sudo cat /var/lib/kubelet/config.yaml

# Check kubelet health
curl -k https://localhost:10250/healthz
```

**Troubleshoot pod issues:**
```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>

# Check pod events
kubectl get events --field-selector involvedObject.name=<pod-name>

# Exec into pod
kubectl exec -it <pod-name> -- /bin/bash
```

**Troubleshoot network issues:**
```bash
# Check service endpoints
kubectl get endpoints <service-name>

# Check service connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup <service-name>

# Check DNS
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Check network policies
kubectl get networkpolicies
```

### 7. Monitoring và Alerting
- **Cluster Health:** Monitor cluster components
- **Resource Usage:** Monitor CPU, memory, disk
- **Application Health:** Monitor applications

**Monitor cluster components:**
```bash
# Check component status
kubectl get componentstatuses

# Check API server health
kubectl get --raw='/readyz?verbose'

# Check etcd health
kubectl get --raw='/healthz/etcd'

# Check scheduler
kubectl get --raw='/healthz/scheduler'
```

**Monitor resource usage:**
```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods

# Check disk usage
kubectl get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="DiskPressure")]}'
```

### 8. Security Maintenance
- **RBAC:** Role-based access control
- **Network Policies:** Network security
- **Pod Security Policies:** Pod security standards

**Check RBAC:**
```bash
# Check roles
kubectl get roles --all-namespaces

# Check role bindings
kubectl get rolebindings --all-namespaces

# Check cluster roles
kubectl get clusterroles

# Check cluster role bindings
kubectl get clusterrolebindings
```

**Check network policies:**
```bash
# Check network policies
kubectl get networkpolicies --all-namespaces

# Check pod security policies
kubectl get podsecuritypolicies
```

### 9. Performance Tuning
- **Scheduler Tuning:** Optimize scheduler performance
- **kubelet Tuning:** Optimize kubelet performance
- **API Server Tuning:** Optimize API server performance

**Scheduler tuning:**
```yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: /etc/kubernetes/scheduler.conf
profiles:
- schedulerName: default-scheduler
  plugins:
    score:
      enabled:
      - name: NodeResourcesBalancedAllocation
      - name: NodePreferAvoidPods
      disabled:
      - name: "*"
```

**kubelet tuning:**
```yaml
# /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 110
kubeReserved:
  cpu: 100m
  memory: 100Mi
systemReserved:
  cpu: 100m
  memory: 100Mi
evictionHard:
  memory.available: "100Mi"
  nodefs.available: "10%"
```

## Lưu ý quan trọng cho CKA
1. **Backup Strategy:** Hiểu cách backup và restore cluster
2. **Upgrade Process:** Cách upgrade cluster an toàn
3. **Certificate Management:** Cách quản lý certificates
4. **Resource Management:** Cách quản lý resource usage
5. **Troubleshooting:** Các techniques để troubleshoot issues
6. **Monitoring:** Cách monitor cluster health
7. **Security:** Cách maintain security của cluster
8. **Performance:** Cách tune performance

## Practice Commands
```bash
# Backup etcd
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /backup/etcd-snapshot.db

# Check certificate expiry
sudo kubeadm certs check-expiration

# Drain node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check component status
kubectl get componentstatuses

# Check resource usage
kubectl top nodes
kubectl top pods

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check logs
kubectl logs <pod-name>
sudo journalctl -u kubelet -f
``` 