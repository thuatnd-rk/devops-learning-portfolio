# 4. Logging & Monitoring

## Tổng quan
Phần này bao gồm các khái niệm về logging và monitoring trong Kubernetes, cách thu thập và phân tích logs, metrics của cluster và applications.

## Nội dung chính

### 1. Kubernetes Logging Architecture
- **Container Logs:** Logs từ applications chạy trong containers
- **System Logs:** Logs từ Kubernetes components (kubelet, kube-proxy, etc.)
- **Node Logs:** Logs từ operating system và system services

**Các loại logs:**
- Application logs (stdout/stderr)
- System component logs
- Node-level logs
- Audit logs

### 2. Container Logging
- Containers ghi logs ra stdout/stderr
- Kubelet thu thập logs và lưu trữ locally
- Logs được rotate để tránh disk space issues

**Câu lệnh quan trọng:**
```bash
# Xem logs của pod
kubectl logs <pod-name>

# Xem logs với timestamps
kubectl logs <pod-name> --timestamps

# Xem logs của container cụ thể trong multi-container pod
kubectl logs <pod-name> -c <container-name>

# Follow logs (real-time)
kubectl logs <pod-name> -f

# Xem logs với số dòng cụ thể
kubectl logs <pod-name> --tail=100

# Xem logs từ thời điểm cụ thể
kubectl logs <pod-name> --since=1h

# Xem logs của tất cả pods với label
kubectl logs -l app=my-app
```

### 3. System Component Logs
- **Control Plane Components:**
  - kube-apiserver
  - etcd
  - kube-scheduler
  - kube-controller-manager

- **Node Components:**
  - kubelet
  - kube-proxy
  - container runtime

**Xem system component logs:**
```bash
# Xem kube-apiserver logs
kubectl logs -n kube-system kube-apiserver-<node-name>

# Xem scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name>

# Xem controller-manager logs
kubectl logs -n kube-system kube-controller-manager-<node-name>

# Xem kubelet logs (trên node)
sudo journalctl -u kubelet -f

# Xem kube-proxy logs
kubectl logs -n kube-system kube-proxy-<node-name>
```

### 4. Node Logs
- Operating system logs
- System service logs
- Hardware logs

**Câu lệnh quan trọng:**
```bash
# Xem system logs
sudo journalctl -f

# Xem kernel logs
sudo dmesg

# Xem systemd logs
sudo journalctl -u kubelet

# Xem container runtime logs
sudo journalctl -u containerd
```

### 5. Monitoring Cluster Components
- **Control Plane Monitoring:**
  - API server health
  - etcd health
  - Scheduler performance
  - Controller manager status

**Kiểm tra control plane health:**
```bash
# Kiểm tra API server
kubectl get --raw='/readyz?verbose'

# Kiểm tra etcd health
kubectl get --raw='/healthz/etcd'

# Kiểm tra scheduler
kubectl get --raw='/healthz/scheduler'

# Kiểm tra controller manager
kubectl get --raw='/healthz/controller-manager'

# Xem component status
kubectl get componentstatuses
kubectl get cs
```

### 6. Monitoring Nodes
- **Node Health:**
  - Node status
  - Resource usage
  - Network connectivity
  - Disk space

**Câu lệnh quan trọng:**
```bash
# Xem node status
kubectl get nodes
kubectl describe node <node-name>

# Xem node capacity và allocatable
kubectl get nodes -o jsonpath='{.items[*].status.capacity}'

# Xem node conditions
kubectl get nodes -o jsonpath='{.items[*].status.conditions}'

# Xem node taints
kubectl get nodes -o jsonpath='{.items[*].spec.taints}'

# Xem node labels
kubectl get nodes --show-labels
```

### 7. Monitoring Pods và Applications
- **Pod Health:**
  - Pod status
  - Container health
  - Resource usage
  - Restart count

**Câu lệnh quan trọng:**
```bash
# Xem pod status
kubectl get pods
kubectl describe pod <pod-name>

# Xem pod resource usage
kubectl top pods

# Xem pod events
kubectl get events --field-selector involvedObject.name=<pod-name>

# Xem pod metrics
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU:.spec.containers[0].resources.requests.cpu,MEMORY:.spec.containers[0].resources.requests.memory
```

### 8. Metrics Server
- Cung cấp resource usage metrics
- Cần cài đặt riêng (không có sẵn trong cluster)

**Cài đặt Metrics Server:**
```bash
# Cài đặt metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Kiểm tra metrics server
kubectl get pods -n kube-system | grep metrics-server

# Test metrics
kubectl top nodes
kubectl top pods
```

### 9. Prometheus và Grafana
- **Prometheus:** Time-series database cho metrics
- **Grafana:** Visualization platform

**Cài đặt Prometheus:**
```bash
# Tạo namespace
kubectl create namespace monitoring

# Cài đặt Prometheus Operator
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/setup/0-namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/setup/
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/
```

### 10. Log Aggregation
- **ELK Stack:** Elasticsearch, Logstash, Kibana
- **Fluentd/Fluent Bit:** Log collection và forwarding
- **Loki:** Log aggregation từ Grafana

**Cài đặt Fluentd:**
```bash
# Cài đặt Fluentd DaemonSet
kubectl apply -f https://raw.githubusercontent.com/fluent/fluentd-kubernetes-daemonset/master/fluentd-daemonset-elasticsearch.yaml
```

### 11. Health Checks
- **Liveness Probes:** Kiểm tra application có đang chạy không
- **Readiness Probes:** Kiểm tra application có sẵn sàng nhận traffic không
- **Startup Probes:** Kiểm tra application đã start hoàn toàn chưa

**Cú pháp Health Checks:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: health-check-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 30
      periodSeconds: 10
```

### 12. Debugging Techniques
- **kubectl describe:** Xem chi tiết resource
- **kubectl logs:** Xem logs
- **kubectl exec:** Exec vào container
- **kubectl port-forward:** Port forward để debug

**Câu lệnh debugging:**
```bash
# Debug pod issues
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/bash

# Debug service issues
kubectl describe service <service-name>
kubectl get endpoints <service-name>

# Debug node issues
kubectl describe node <node-name>
kubectl get events --field-selector involvedObject.name=<node-name>

# Port forward để debug
kubectl port-forward pod/<pod-name> 8080:80
kubectl port-forward service/<service-name> 8080:80
```

## Lưu ý quan trọng cho CKA
1. **Log Locations:** Hiểu logs được lưu ở đâu và cách access
2. **Log Rotation:** Cách Kubernetes handle log rotation
3. **Health Checks:** Cách implement và troubleshoot health checks
4. **Metrics Collection:** Cách cài đặt và sử dụng metrics server
5. **Monitoring Stack:** Cách setup Prometheus, Grafana
6. **Debugging:** Các techniques để debug issues
7. **System Components:** Cách monitor control plane và node components
8. **Resource Monitoring:** Cách monitor CPU, memory, disk usage

## Practice Commands
```bash
# Tạo pod với health checks
kubectl run health-check-pod --image=nginx --port=80 --overrides='{"spec":{"containers":[{"name":"nginx","image":"nginx:latest","ports":[{"containerPort":80}],"livenessProbe":{"httpGet":{"path":"/","port":80},"initialDelaySeconds":30,"periodSeconds":10},"readinessProbe":{"httpGet":{"path":"/","port":80},"initialDelaySeconds":5,"periodSeconds":5}}]}}'

# Xem resource usage
kubectl top nodes
kubectl top pods

# Xem events
kubectl get events --sort-by=.metadata.creationTimestamp

# Debug network issues
kubectl run debug-pod --image=busybox --rm -it --restart=Never -- nslookup <service-name>

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- <service-name>:<port>
``` 