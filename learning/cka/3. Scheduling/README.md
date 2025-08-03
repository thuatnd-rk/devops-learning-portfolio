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
- **Cơ chế:** Pull-based (kéo) - Pod "kéo" node phù hợp

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

**Ưu điểm:**
- Đơn giản, dễ hiểu
- Hiệu suất cao
- Ít overhead

**Nhược điểm:**
- Chỉ hỗ trợ exact match
- Không có operators phức tạp
- Không có soft requirements

### 4. Node Affinity
- Cung cấp cách linh hoạt hơn để control scheduling
- Có 2 loại: `requiredDuringSchedulingIgnoredDuringExecution` và `preferredDuringSchedulingIgnoredDuringExecution`
- **Cơ chế:** Pull-based (kéo) - Pod "kéo" node phù hợp với điều kiện phức tạp

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

**Operators có sẵn:**
- `In`: Giá trị phải nằm trong danh sách
- `NotIn`: Giá trị không được nằm trong danh sách
- `Exists`: Label phải tồn tại
- `DoesNotExist`: Label không được tồn tại
- `Gt`: Giá trị lớn hơn (cho số)
- `Lt`: Giá trị nhỏ hơn (cho số)

**Ưu điểm so với Node Selector:**
- Hỗ trợ operators phức tạp
- Có soft requirements (preferred)
- Có thể kết hợp nhiều điều kiện
- Hỗ trợ weights cho scoring

### 5. Taints và Tolerations
- **Taints:** Mark nodes để pods không thể schedule lên (trừ khi có toleration)
- **Tolerations:** Cho phép pod chạy trên tainted nodes
- **Cơ chế:** Push-based (đẩy) - Node "đẩy" pods không mong muốn ra khỏi node

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
- `NoSchedule`: Pod không schedule lên node (hard requirement)
- `PreferNoSchedule`: Pod cố gắng không schedule lên node (soft requirement)
- `NoExecute`: Pod bị evict nếu đã chạy trên node

**Built-in Taints:**
```bash
# Master node taint
node-role.kubernetes.io/control-plane:NoSchedule

# Node với vấn đề
node.kubernetes.io/not-ready:NoExecute
node.kubernetes.io/unreachable:NoExecute
node.kubernetes.io/memory-pressure:NoSchedule
node.kubernetes.io/disk-pressure:NoSchedule
node.kubernetes.io/pid-pressure:NoSchedule
```

**So sánh với Node Selector/Affinity:**
- **Node Selector/Affinity:** Pull-based, Pod "kéo" node phù hợp
- **Taints/Tolerations:** Push-based, Node "đẩy" pods không mong muốn
- **Use case:** Taints thường dùng để isolate nodes (master, GPU, dedicated workloads)

### 6. Pod Affinity và Anti-Affinity
- **Pod Affinity:** Pod muốn chạy cùng với pods khác
- **Pod Anti-Affinity:** Pod không muốn chạy cùng với pods khác
- **Cơ chế:** Pod-to-Pod relationship dựa trên labels và topology

#### 6.1 Pod Affinity (Hard Requirement)

**Ví dụ thực tế:** Database và application cần chạy cùng node để giảm latency

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
  labels:
    app: web
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - database
        topologyKey: kubernetes.io/hostname
  containers:
  - name: web
    image: nginx:latest
```

#### 6.2 Pod Affinity (Soft Requirement)

**Ví dụ thực tế:** Cache server ưu tiên chạy cùng node với application

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cache-server
  labels:
    app: cache
spec:
  affinity:
    podAffinity:
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
  - name: redis
    image: redis:latest
```

#### 6.3 Pod Anti-Affinity (Hard Requirement)

**Ví dụ thực tế:** High availability - đảm bảo pods không chạy cùng node

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app-1
  labels:
    app: web
    tier: frontend
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - web
          - key: tier
            operator: In
            values:
            - frontend
        topologyKey: kubernetes.io/hostname
  containers:
  - name: web
    image: nginx:latest
```

#### 6.4 Pod Anti-Affinity (Soft Requirement)

**Ví dụ thực tế:** Ưu tiên tách các pods để tránh resource contention

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: monitoring-agent
  labels:
    app: monitoring
spec:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 50
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
            - monitoring
          topologyKey: kubernetes.io/hostname
  containers:
  - name: prometheus
    image: prom/prometheus:latest
```

#### 6.5 Topology Keys

```yaml
# Các topology key phổ biến
- kubernetes.io/hostname: Node level
- kubernetes.io/zone: Zone level  
- kubernetes.io/region: Region level
- failure-domain.beta.kubernetes.io/zone: Zone (legacy)
```

**Use cases thực tế:**
- **Hostname:** Đảm bảo pods chạy cùng/tách node
- **Zone:** Đảm bảo pods chạy cùng/tách zone (high availability)
- **Region:** Đảm bảo pods chạy cùng/tách region (disaster recovery)

### 7. Static Pods
- Pods được tạo trực tiếp bởi kubelet
- Thường dùng cho control plane components
- Được tạo từ manifest files trong `/etc/kubernetes/manifests/`
- **Khi nào cần dùng:** Khi cần đảm bảo pod luôn chạy trên node cụ thể, không phụ thuộc vào API server

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

**Use cases thực tế:**
1. **Control Plane Components:** etcd, kube-apiserver, kube-scheduler, kube-controller-manager
2. **Node-specific Services:** Monitoring agents, logging agents
3. **Bootstrap Scenarios:** Khi API server chưa sẵn sàng
4. **Debugging:** Khi cần chạy tools trên node cụ thể

**Câu lệnh quan trọng:**
```bash
# Xem static pods
kubectl get pods --all-namespaces | grep static

# Kiểm tra manifest directory
ls /etc/kubernetes/manifests/

# Tạo static pod
sudo cp pod.yaml /etc/kubernetes/manifests/

# Xem kubelet config
ps aux | grep kubelet
grep -i staticpod /var/lib/kubelet/config.yaml
```

**Lưu ý quan trọng:**
- Static pod name sẽ có prefix là node name
- Pod được tạo trực tiếp bởi kubelet, không qua API server
- Khi xóa manifest file, pod sẽ bị xóa
- Thường dùng cho control plane components để đảm bảo high availability

### 8. DaemonSets
- Đảm bảo tất cả (hoặc một số) nodes chạy một copy của pod
- Thường dùng cho monitoring, logging, storage
- **Lý do mỗi node cần 1 pod:** Để đảm bảo service chạy trên tất cả nodes, không bỏ sót node nào

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
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: monitoring-agent
        image: monitoring-agent:latest
```

**Use cases thực tế và lý do cần DaemonSet:**

1. **Monitoring Agents (Node Exporter, Prometheus):**
   - **Lý do:** Cần thu thập metrics từ tất cả nodes
   - **Ví dụ:** node-exporter để monitor CPU, memory, disk của mỗi node

2. **Logging Agents (Fluentd, Logstash):**
   - **Lý do:** Cần thu thập logs từ tất cả nodes
   - **Ví dụ:** fluentd để collect logs từ containers trên mỗi node

3. **Storage Agents (CSI drivers):**
   - **Lý do:** Cần quản lý storage trên tất cả nodes
   - **Ví dụ:** AWS EBS CSI driver để mount volumes

4. **Network Agents (Calico, Flannel):**
   - **Lý do:** Cần cấu hình networking trên tất cả nodes
   - **Ví dụ:** Calico CNI để quản lý network policies

5. **Security Agents:**
   - **Lý do:** Cần security scanning trên tất cả nodes
   - **Ví dụ:** Falco để detect security threats

**Ví dụ DaemonSet thực tế - Node Exporter:**
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      name: node-exporter
  template:
    metadata:
      labels:
        name: node-exporter
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: node-exporter
        image: prom/node-exporter:v1.3.1
        ports:
        - containerPort: 9100
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
        - name: root
          mountPath: /host/root
          readOnly: true
        args:
        - --path.procfs=/host/proc
        - --path.sysfs=/host/sys
        - --path.rootfs=/host/root
        - --web.listen-address=:9100
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      - name: root
        hostPath:
          path: /
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

# Rollback DaemonSet
kubectl rollout undo daemonset/monitoring-daemon

# Xem DaemonSet status
kubectl describe daemonset node-exporter
```

**Lưu ý quan trọng:**
- DaemonSet đảm bảo mỗi node có đúng 1 pod (trừ khi có nodeSelector)
- Pods của DaemonSet có thể chạy trên master nodes nếu có tolerations
- DaemonSet không có replicas field như Deployment
- Rolling update strategy khác với Deployment

## Lưu ý quan trọng cho CKA

### 1. Sự khác biệt giữa các cơ chế Scheduling

**Node Selector vs Node Affinity:**
- **Node Selector:** Pull-based, chỉ hỗ trợ exact match, đơn giản
- **Node Affinity:** Pull-based, hỗ trợ operators phức tạp, có soft/hard requirements

**Node Affinity vs Taints/Tolerations:**
- **Node Affinity:** Pull-based - Pod "kéo" node phù hợp
- **Taints/Tolerations:** Push-based - Node "đẩy" pods không mong muốn

### 2. Pod Affinity và Anti-Affinity

**Hard vs Soft Requirements:**
- **Hard (required):** Pod phải được schedule theo điều kiện, nếu không sẽ pending
- **Soft (preferred):** Pod ưu tiên được schedule theo điều kiện, nhưng vẫn có thể chạy nếu không thỏa mãn

**Use cases thực tế:**
- **Pod Affinity:** Database và application cùng node (giảm latency)
- **Pod Anti-Affinity:** High availability - pods tách node (tránh single point of failure)

### 3. Static Pods

**Khi nào cần dùng:**
- Control plane components (etcd, kube-apiserver, etc.)
- Node-specific services (monitoring, logging)
- Bootstrap scenarios
- Debugging tools

**Đặc điểm quan trọng:**
- Tạo trực tiếp bởi kubelet, không qua API server
- Pod name có prefix là node name
- Manifest file trong `/etc/kubernetes/manifests/`

### 4. DaemonSets

**Lý do mỗi node cần 1 pod:**
- **Monitoring:** Thu thập metrics từ tất cả nodes
- **Logging:** Collect logs từ tất cả nodes  
- **Storage:** Quản lý storage trên tất cả nodes
- **Networking:** Cấu hình network trên tất cả nodes
- **Security:** Security scanning trên tất cả nodes

**Đặc điểm quan trọng:**
- Không có replicas field
- Pods có thể chạy trên master nodes với tolerations
- Rolling update strategy khác Deployment

### 5. Troubleshooting Scheduling Issues

**Common Issues:**
1. **Pod Pending - No nodes available:** Kiểm tra nodeSelector, nodeAffinity, taints
2. **Pod Pending - Insufficient resources:** Kiểm tra node capacity, pod requests/limits
3. **Pod Pending - PodAffinity/AntiAffinity:** Kiểm tra topology, labels

**Debug Commands:**
```bash
kubectl describe pod <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl describe node <node-name>
kubectl get nodes --show-labels
```

## Practice Commands

### Node Selector và Node Affinity
```bash
# Tạo node labels
kubectl label nodes worker-1 disk=ssd environment=production
kubectl label nodes worker-2 disk=hdd environment=staging

# Xem node labels
kubectl get nodes --show-labels

# Tạo pod với nodeSelector
kubectl run nginx --image=nginx --overrides='{"spec":{"nodeSelector":{"disk":"ssd"}}}'

# Tạo pod với nodeAffinity
kubectl run nginx --image=nginx --overrides='{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"disk","operator":"In","values":["ssd"]}]}]}}}}'
```

### Taints và Tolerations
```bash
# Tạo taint trên node
kubectl taint nodes worker-1 dedicated=special:NoSchedule

# Xem taints
kubectl describe node worker-1 | grep Taints

# Tạo pod với toleration
kubectl run nginx --image=nginx --overrides='{"spec":{"tolerations":[{"key":"dedicated","operator":"Equal","value":"special","effect":"NoSchedule"}]}}'

# Xóa taint
kubectl taint nodes worker-1 dedicated:NoSchedule-
```

### Pod Affinity và Anti-Affinity
```bash
# Tạo deployment với pod anti-affinity (hard)
kubectl create deployment web --image=nginx --replicas=3 --overrides='{"spec":{"template":{"spec":{"affinity":{"podAntiAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":[{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["web"]}]},"topologyKey":"kubernetes.io/hostname"}]}}}}}}'

# Tạo deployment với pod anti-affinity (soft)
kubectl create deployment cache --image=redis --replicas=3 --overrides='{"spec":{"template":{"spec":{"affinity":{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"weight":100,"podAffinityTerm":{"labelSelector":{"matchExpressions":[{"key":"app","operator":"In","values":["cache"]}]},"topologyKey":"kubernetes.io/hostname"}]}}}}}}'
```

### Static Pods
```bash
# Xem static pods
kubectl get pods --all-namespaces | grep static

# Kiểm tra manifest directory
ls /etc/kubernetes/manifests/

# Tạo static pod
sudo cp static-pod.yaml /etc/kubernetes/manifests/

# Xem kubelet config
ps aux | grep kubelet
grep -i staticpod /var/lib/kubelet/config.yaml
```

### DaemonSets
```bash
# Tạo DaemonSet
kubectl apply -f daemonset.yaml

# Xem DaemonSets
kubectl get daemonsets

# Xem pods của DaemonSet
kubectl get pods -l name=monitoring-agent

# Update DaemonSet
kubectl set image daemonset/monitoring-daemon monitoring-agent=monitoring-agent:v2

# Rollback DaemonSet
kubectl rollout undo daemonset/monitoring-daemon

# Xem DaemonSet status
kubectl describe daemonset node-exporter
```

### Troubleshooting
```bash
# Xem scheduling events
kubectl get events --sort-by=.metadata.creationTimestamp | grep -i schedule

# Debug scheduling issues
kubectl describe pod <pending-pod-name>

# Xem node capacity và allocatable
kubectl describe node <node-name> | grep -A 5 "Capacity\|Allocatable"

# Xem scheduler logs
kubectl logs -n kube-system kube-scheduler-<node-name>

# Kiểm tra node resources
kubectl top nodes

# Kiểm tra pod resources
kubectl top pods
``` 