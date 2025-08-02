# 2. Core Concepts

## Tổng quan
Phần này bao gồm các khái niệm cơ bản của Kubernetes mà mọi administrator cần nắm vững.

## Nội dung chính

### 1. Kubernetes Architecture
- **Control Plane Components:**
  - kube-apiserver: API server, điểm vào chính cho tất cả requests
  - etcd: Distributed key-value store, lưu trữ cluster state
  - kube-scheduler: Quyết định pod nào chạy trên node nào
  - kube-controller-manager: Chạy các controller processes

- **Worker Node Components:**
  - kubelet: Agent chạy trên mỗi node, đảm bảo containers chạy trong pod
  - kube-proxy: Network proxy, duy trì network rules
  - Container Runtime: Docker, containerd, CRI-O

### 2. Pods
- Pod là đơn vị nhỏ nhất trong Kubernetes
- Một pod có thể chứa một hoặc nhiều containers
- Pods có lifecycle riêng biệt

**Cú pháp tạo Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx:latest
    ports:
    - containerPort: 80
```

**Câu lệnh quan trọng:**
```bash
# Tạo pod từ file
kubectl apply -f pod.yaml

# Xem pods
kubectl get pods

# Xem chi tiết pod
kubectl describe pod <pod-name>

# Xem logs của pod
kubectl logs <pod-name>

# Exec vào pod
kubectl exec -it <pod-name> -- /bin/bash

# Xóa pod
kubectl delete pod <pod-name>
```

### 3. Services
- Services cung cấp network connectivity cho pods
- Các loại services:
  - ClusterIP (default): Chỉ accessible từ cluster
  - NodePort: Expose service trên port của node
  - LoadBalancer: Expose service qua cloud load balancer
  - ExternalName: Map service tới external DNS name

**Cú pháp Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
```

**Câu lệnh quan trọng:**
```bash
# Tạo service
kubectl apply -f service.yaml

# Xem services
kubectl get services

# Xem endpoints của service
kubectl get endpoints <service-name>

# Port forward service
kubectl port-forward service/<service-name> 8080:80
```

### 4. Docker vs Containerd
- **Docker:** Container runtime phổ biến, có nhiều features
- **Containerd:** Lightweight container runtime, được Kubernetes khuyến nghị
- **CRI (Container Runtime Interface):** Standard interface cho container runtimes

**Kiểm tra container runtime:**
```bash
# Xem container runtime
kubectl get nodes -o wide

# Kiểm tra CRI version
kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}'
```

### 5. Namespaces
- Namespaces cung cấp cơ chế isolation cho resources
- Default namespaces: default, kube-system, kube-public, kube-node-lease

**Câu lệnh quan trọng:**
```bash
# Tạo namespace
kubectl create namespace <namespace-name>

# Xem namespaces
kubectl get namespaces

# Chuyển context sang namespace
kubectl config set-context --current --namespace=<namespace-name>

# Xem resources trong namespace
kubectl get all -n <namespace-name>
```

### 6. Labels và Selectors
- Labels: Key-value pairs để identify objects
- Selectors: Cách để select objects dựa trên labels

**Cú pháp Labels:**
```yaml
metadata:
  labels:
    app: my-app
    tier: frontend
    environment: production
```

**Câu lệnh quan trọng:**
```bash
# Label resource
kubectl label pod <pod-name> app=my-app

# Xem resources với label selector
kubectl get pods -l app=my-app

# Xóa label
kubectl label pod <pod-name> app-
```

### 7. Annotations
- Annotations: Metadata không được dùng để identify objects
- Thường dùng để store non-identifying information

**Cú pháp Annotations:**
```yaml
metadata:
  annotations:
    description: "This is a test pod"
    contact: "admin@example.com"
```

## Lưu ý quan trọng cho CKA
1. **Pod Lifecycle:** Hiểu rõ các phases: Pending, Running, Succeeded, Failed, Unknown
2. **Pod Status:** Ready, ContainersReady, PodScheduled
3. **Service Types:** Khi nào dùng loại service nào
4. **Namespaces:** Cách quản lý và isolate resources
5. **Labels/Selectors:** Cách organize và select resources
6. **Container Runtime:** Hiểu sự khác biệt giữa Docker và Containerd

## Practice Commands
```bash
# Tạo pod với multiple containers
kubectl run multi-container-pod --image=nginx --dry-run=client -o yaml > multi-pod.yaml

# Tạo service cho pod
kubectl expose pod <pod-name> --port=80 --target-port=8080

# Xem events
kubectl get events --sort-by=.metadata.creationTimestamp

# Debug pod issues
kubectl describe pod <pod-name>
kubectl logs <pod-name> -c <container-name>
``` 