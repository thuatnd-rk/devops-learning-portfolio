# 3. Scheduling

## Tổng quan
Phần này bao gồm các khái niệm về scheduling trong Kubernetes, cách Kubernetes quyết định pod nào chạy trên node nào.

## Nội dung chính

### 1. Kubernetes Scheduler
- **kube-scheduler:** Component chịu trách nhiệm scheduling pods lên nodes
- **Scheduling Process:**
  1. Filtering: Lọc ra các nodes có thể chạy pod
  2. Scoring: Tính điểm cho các nodes còn lại
  3. Binding: Chọn node có điểm cao nhất

**Kiểm tra scheduler:**
```bash
# Xem scheduler pods
kubectl get pods -n kube-system | grep scheduler

# Xem scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name>

# Xem scheduler configuration
kubectl get configmap -n kube-system kube-scheduler -o yaml
```

### 2. Manual Scheduling
- Có thể manually schedule pod bằng cách set `nodeName` trong pod spec
- Bỏ qua scheduler process

**Cú pháp Manual Scheduling:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: manual-pod
spec:
  nodeName: worker-node-1  # Chỉ định node cụ thể
  containers:
  - name: nginx
    image: nginx:latest
```

**Câu lệnh quan trọng:**
```bash
# Tạo pod với nodeName
kubectl run manual-pod --image=nginx --overrides='{"spec":{"nodeName":"worker-node-1"}}'

# Xem pod được schedule ở đâu
kubectl get pod <pod-name> -o wide

# Xem node information
kubectl describe node <node-name>
```

### 3. Node Selectors
- Đơn giản nhất để control scheduling
- Pod chỉ chạy trên nodes có labels match với nodeSelector

**Cú pháp Node Selector:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-pod
spec:
  nodeSelector:
    disk: ssd
    environment: production
  containers:
  - name: nginx
    image: nginx:latest
```

**Câu lệnh quan trọng:**
```bash
# Label node
kubectl label node <node-name> disk=ssd environment=production

# Xem node labels
kubectl get nodes --show-labels

# Xóa label
kubectl label node <node-name> disk-
```

### 4. Node Affinity
- Cung cấp cách linh hoạt hơn để control scheduling
- Có 2 loại: `requiredDuringSchedulingIgnoredDuringExecution` và `preferredDuringSchedulingIgnoredDuringExecution`

**Cú pháp Node Affinity:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/os
            operator: In
            values:
            - linux
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disk
            operator: In
            values:
            - ssd
  containers:
  - name: nginx
    image: nginx:latest
```

### 5. Taints và Tolerations
- **Taints:** Mark nodes để pods không thể schedule lên (trừ khi có toleration)
- **Tolerations:** Cho phép pod chạy trên tainted nodes

**Cú pháp Taint:**
```bash
# Tạo taint
kubectl taint nodes <node-name> key=value:NoSchedule

# Xóa taint
kubectl taint nodes <node-name> key:NoSchedule-
```

**Cú pháp Tolerations:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toleration-pod
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx:latest
```

**Các effect types:**
- `NoSchedule`: Pod không schedule lên node
- `PreferNoSchedule`: Pod cố gắng không schedule lên node
- `NoExecute`: Pod bị evict nếu đã chạy trên node

### 6. Pod Affinity và Anti-Affinity
- **Pod Affinity:** Pod muốn chạy cùng với pods khác
- **Pod Anti-Affinity:** Pod không muốn chạy cùng với pods khác

**Cú pháp Pod Affinity:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - web
        topologyKey: kubernetes.io/hostname
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - web
          topologyKey: kubernetes.io/hostname
  containers:
  - name: nginx
    image: nginx:latest
```

### 7. Static Pods
- Pods được tạo trực tiếp bởi kubelet
- Thường dùng cho control plane components
- Được tạo từ manifest files trong `/etc/kubernetes/manifests/`

**Cú pháp Static Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-pod
  annotations:
    kubernetes.io/config.source: "file"
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

**Câu lệnh quan trọng:**
```bash
# Xem static pods
kubectl get pods --all-namespaces | grep static

# Kiểm tra manifest directory
ls /etc/kubernetes/manifests/

# Tạo static pod
sudo cp pod.yaml /etc/kubernetes/manifests/
```

### 8. DaemonSets
- Đảm bảo tất cả (hoặc một số) nodes chạy một copy của pod
- Thường dùng cho monitoring, logging, storage

**Cú pháp DaemonSet:**
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-daemon
spec:
  selector:
    matchLabels:
      name: monitoring-agent
  template:
    metadata:
      labels:
        name: monitoring-agent
    spec:
      containers:
      - name: monitoring-agent
        image: monitoring-agent:latest
```

**Câu lệnh quan trọng:**
```bash
# Tạo DaemonSet
kubectl apply -f daemonset.yaml

# Xem DaemonSets
kubectl get daemonsets

# Xem pods của DaemonSet
kubectl get pods -l name=monitoring-agent

# Update DaemonSet
kubectl set image daemonset/monitoring-daemon monitoring-agent=monitoring-agent:v2
```

## Lưu ý quan trọng cho CKA
1. **Scheduler Process:** Hiểu rõ 3 bước: Filtering, Scoring, Binding
2. **Manual Scheduling:** Khi nào và cách dùng nodeName
3. **Node Selectors:** Cách đơn giản nhất để control scheduling
4. **Node Affinity:** Cách linh hoạt hơn với operators và weights
5. **Taints/Tolerations:** Cách isolate nodes và control pod placement
6. **Pod Affinity/Anti-Affinity:** Cách control pod placement dựa trên pods khác
7. **Static Pods:** Cách kubelet tạo pods trực tiếp
8. **DaemonSets:** Cách deploy pods trên tất cả nodes

## Practice Commands
```bash
# Tạo node với taint
kubectl taint nodes <node-name> dedicated=special:NoSchedule

# Tạo pod với toleration
kubectl run toleration-pod --image=nginx --overrides='{"spec":{"tolerations":[{"key":"dedicated","operator":"Equal","value":"special","effect":"NoSchedule"}]}}'

# Xem scheduling events
kubectl get events --sort-by=.metadata.creationTimestamp | grep -i schedule

# Debug scheduling issues
kubectl describe pod <pending-pod-name>

# Xem node capacity và allocatable
kubectl describe node <node-name> | grep -A 5 "Capacity\|Allocatable"
``` 