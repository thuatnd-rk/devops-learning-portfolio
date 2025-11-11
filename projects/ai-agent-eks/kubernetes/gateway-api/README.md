# Nginx Gateway Fabric - Gateway API Implementation

File này mô tả về cách cài đặt Nginx Gateway Fabric và cấu hình Gateway, HTTPRoute cơ bản trên EKS cluster.

## Tổng quan về Nginx Gateway Fabric

Nginx Gateway Fabric (NGF) là một implementation của Kubernetes Gateway API, cung cấp khả năng quản lý traffic ingress cho các ứng dụng trong cluster. NGF sử dụng NGINX như data plane để xử lý và định tuyến traffic.

### Cách Nginx Gateway Fabric hoạt động

1. **Control Plane (Controller)**: 
   - Quản lý Gateway và HTTPRoute resources
   - Theo dõi các thay đổi và cập nhật cấu hình NGINX
   - Tự động tạo và quản lý NGINX data plane pods

2. **Data Plane (NGINX)**:
   - Chạy NGINX instances để xử lý traffic thực tế
   - Nhận cấu hình từ Controller
   - Expose qua Kubernetes Service (LoadBalancer/NodePort/ClusterIP)

3. **Gateway API Resources**:
   - `Gateway`: Định nghĩa điểm vào (entry point) cho traffic
   - `HTTPRoute`: Định nghĩa routing rules cho HTTP traffic
   - `GatewayClass`: Định nghĩa loại Gateway implementation

## Cài đặt

### 1. Install Nginx Gateway Fabric

Sử dụng script để cài đặt:

```bash
./projects/ai-agent-eks/scripts/setup/install-ngf.sh
```

Hoặc cài đặt thủ công:

```bash
# I. Install Gateway API CRDs
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.2.0" | kubectl apply -f -

# II. Install Nginx Gateway Fabric Controller
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --create-namespace -n nginx-gateway \
  --set nginx.service.type=LoadBalancer
```

#### Các thành phần được cài đặt:

1. **Gateway API CRDs**:
   - `gateways.gateway.networking.k8s.io`: Định nghĩa Gateway resource
   - `httproutes.gateway.networking.k8s.io`: Định nghĩa HTTPRoute resource
   - `gatewayclasses.gateway.networking.k8s.io`: Định nghĩa GatewayClass resource
   - Các CRDs khác liên quan đến Gateway API standard

2. **Nginx Gateway Fabric Controller**:
   - Deployment: `nginx-gateway-fabric` trong namespace `nginx-gateway`
   - Service: `ngf-nginx-gateway-fabric` (type: LoadBalancer)
   - ConfigMap: Chứa cấu hình NGINX
   - ServiceAccount: Quyền để quản lý resources

3. **GatewayClass**:
   - Tự động tạo `GatewayClass` tên `nginx`
   - Được sử dụng bởi Gateway resources để chỉ định implementation

### 2. Verify Installation

Kiểm tra các thành phần đã được cài đặt:

```bash
# Kiểm tra CRDs
kubectl get crd | grep gateway

# Kiểm tra Controller pods
kubectl get pod -n nginx-gateway

# Kiểm tra Service
kubectl get svc -n nginx-gateway

# Kiểm tra GatewayClass
kubectl get gatewayclass
```

## Cấu hình

### 3. Tạo Gateway

Gateway định nghĩa điểm vào cho traffic vào cluster:

```bash
kubectl apply -f gateway.yaml
```

**Cấu trúc Gateway**:
- `name`: main-gateway
- `namespace`: nginx-gateway
- `gatewayClassName`: nginx (tham chiếu đến GatewayClass)
- `listeners`: 
  - Port 80, protocol HTTP
  - Cho phép Routes từ mọi namespace (`from: All`)

**Verify Gateway**:
```bash
kubectl get gateway -n nginx-gateway
kubectl describe gateway main-gateway -n nginx-gateway
```

### 4. Cấu hình HTTPRoute

HTTPRoute định nghĩa routing rules cho HTTP traffic:

```bash
kubectl apply -f httproute.yaml
```

**Cấu trúc HTTPRoute**:
- `parentRefs`: Tham chiếu đến Gateway (main-gateway)
- `rules`: 
  - `matches`: Điều kiện match (path prefix `/coffee` hoặc `/tea`)
  - `filters`: URL rewrite để loại bỏ prefix
  - `backendRefs`: Service backend để forward traffic

**Verify HTTPRoute**:
```bash
kubectl get httproute -A
kubectl describe httproute coffee-routes -n default
kubectl describe httproute tea-routes -n default
```

## Kiểm tra và Testing

### Lấy LoadBalancer Address

```bash
# Lấy External IP/Endpoint
kubectl get svc -n nginx-gateway ngf-nginx-gateway-fabric

# Hoặc từ Gateway status
kubectl get gateway main-gateway -n nginx-gateway -o jsonpath='{.status.addresses[0].value}'
```

### Test Traffic Routing

```bash
# Test coffee service
curl http://<LOADBALANCER_IP>/coffee

# Test tea service
curl http://<LOADBALANCER_IP>/tea
```

## Troubleshooting

### Kiểm tra Controller logs

```bash
kubectl logs -n nginx-gateway -l app=nginx-gateway-fabric
```

### Kiểm tra NGINX data plane logs

```bash
kubectl logs -n nginx-gateway -l app=nginx-gateway-fabric-dataplane
```

### Kiểm tra Gateway status

```bash
kubectl get gateway main-gateway -n nginx-gateway -o yaml
```

### Kiểm tra HTTPRoute status

```bash
kubectl get httproute -A -o yaml
```

## Xóa resources

### Xóa Gateway và HTTPRoute

```bash
kubectl delete -f httproute.yaml
kubectl delete -f gateway.yaml
```

### Xóa Nginx Gateway Fabric

```bash
# Uninstall Helm chart
helm uninstall ngf -n nginx-gateway

# Xóa CRDs (cẩn thận - có thể ảnh hưởng đến các Gateway khác)
kubectl delete -f <(kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.2.0")
```

## Tài liệu tham khảo

- [Nginx Gateway Fabric Documentation](https://docs.nginx.com/nginx-gateway-fabric/)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)
- [Installation Guide](https://docs.nginx.com/nginx-gateway-fabric/install/helm/)
