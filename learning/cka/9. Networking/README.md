# 9. Networking

## Tổng quan
Phần này bao gồm các khái niệm về networking trong Kubernetes, bao gồm services, ingress, network policies, và DNS.

## Nội dung chính

### 1. Kubernetes Networking Model
- **Pod Network:** Mỗi pod có unique IP address
- **Service Network:** Virtual IP cho services
- **Cluster Network:** Internal cluster communication
- **External Network:** External access

**Network Requirements:**
- Pods có thể communicate với tất cả pods khác
- Nodes có thể communicate với tất cả pods
- Pods có thể communicate với tất cả nodes

### 2. Services
- **Services:** Expose applications running on pods
- **Service Types:**
  - ClusterIP (default)
  - NodePort
  - LoadBalancer
  - ExternalName

**ClusterIP Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
  type: ClusterIP
```

**NodePort Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
    nodePort: 30007
```

**LoadBalancer Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```

**ExternalName Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ExternalName
  externalName: api.example.com
```

**Câu lệnh quan trọng:**
```bash
# Tạo service
kubectl apply -f service.yaml

# Xem services
kubectl get services

# Xem service endpoints
kubectl get endpoints <service-name>

# Xem service details
kubectl describe service <service-name>

# Port forward service
kubectl port-forward service/<service-name> 8080:80

# Expose deployment as service
kubectl expose deployment <deployment-name> --port=80 --target-port=8080

# Xem service logs
kubectl logs -l app=<app-label>
```

### 3. Ingress
- **Ingress:** HTTP/HTTPS traffic routing
- **Ingress Controllers:** Implement ingress rules
- **TLS Termination:** SSL/TLS termination

**Ingress Resource:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        pathType: Prefix
        backend:
          service:
            name: service1
            port:
              number: 4200
      - path: /bar
        pathType: Prefix
        backend:
          service:
            name: service2
            port:
              number: 8080
```

**Ingress với TLS:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  tls:
  - hosts:
    - sslexample.foo.com
    secretName: testsecret-tls
  rules:
  - host: sslexample.foo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service1
            port:
              number: 80
```

**TLS Secret:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: testsecret-tls
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
```

**Câu lệnh quan trọng:**
```bash
# Tạo ingress
kubectl apply -f ingress.yaml

# Xem ingress
kubectl get ingress

# Xem ingress details
kubectl describe ingress <ingress-name>

# Check ingress status
kubectl get ingress <ingress-name> -o yaml

# Test ingress
curl -H "Host: foo.bar.com" http://<ingress-ip>/foo
```

### 4. Network Policies
- **Network Policies:** Control traffic flow giữa pods
- **Default Behavior:** Allow all traffic nếu không có network policy

**Default Deny Policy:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress: []
  egress: []
```

**Allow Specific Traffic:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nginx
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
```

**Allow DNS Traffic:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to: []
    ports:
    - protocol: UDP
      port: 53
```

**Câu lệnh quan trọng:**
```bash
# Tạo network policy
kubectl apply -f network-policy.yaml

# Xem network policies
kubectl get networkpolicies

# Xem network policy details
kubectl describe networkpolicy <policy-name>

# Test network connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- <service-name>:<port>
```

### 5. DNS và Service Discovery
- **CoreDNS:** DNS server trong Kubernetes
- **Service Discovery:** Automatic DNS resolution cho services

**DNS Records:**
- `<service-name>.<namespace>.svc.cluster.local`
- `<service-name>.<namespace>.svc`
- `<service-name>`

**CoreDNS Configuration:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           upstream
           fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
```

**Câu lệnh quan trọng:**
```bash
# Check DNS resolution
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Check CoreDNS pods
kubectl get pods -n kube-system | grep coredns

# Check CoreDNS logs
kubectl logs -n kube-system coredns-<pod-name>

# Test service DNS
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup <service-name>
```

### 6. CNI (Container Network Interface)
- **CNI:** Standard interface cho network plugins
- **Popular CNI Plugins:**
  - Calico
  - Flannel
  - Weave Net
  - Cilium

**Calico Installation:**
```bash
# Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Check Calico pods
kubectl get pods -n kube-system | grep calico

# Check Calico status
kubectl get nodes -o wide
```

**Flannel Installation:**
```bash
# Install Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Check Flannel pods
kubectl get pods -n kube-system | grep flannel
```

**Câu lệnh quan trọng:**
```bash
# Check CNI configuration
cat /etc/cni/net.d/*

# Check network interfaces
ip addr show

# Check routing table
ip route show

# Check CNI plugins
ls /opt/cni/bin/
```

### 7. Load Balancing
- **Load Balancing:** Distribute traffic across pods
- **Session Affinity:** Sticky sessions
- **Health Checks:** Service health monitoring

**Service với Session Affinity:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

**Health Check Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```

### 8. Troubleshooting Networking
- **Connectivity Issues:** Pods không thể communicate
- **DNS Issues:** DNS resolution problems
- **Service Issues:** Service không accessible

**Troubleshoot Pod Connectivity:**
```bash
# Check pod network
kubectl exec -it <pod-name> -- ip addr show

# Check pod routing
kubectl exec -it <pod-name> -- ip route show

# Test connectivity
kubectl exec -it <pod-name> -- ping <target-pod-ip>

# Check DNS resolution
kubectl exec -it <pod-name> -- nslookup <service-name>
```

**Troubleshoot Service Issues:**
```bash
# Check service endpoints
kubectl get endpoints <service-name>

# Check service selector
kubectl get pods -l <selector>

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- <service-name>:<port>

# Check service logs
kubectl logs -l app=<app-label>
```

**Troubleshoot DNS Issues:**
```bash
# Check CoreDNS pods
kubectl get pods -n kube-system | grep coredns

# Check CoreDNS logs
kubectl logs -n kube-system coredns-<pod-name>

# Test DNS resolution
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Check DNS configuration
kubectl get configmap coredns -n kube-system -o yaml
```

### 9. Network Security
- **Network Policies:** Control traffic flow
- **TLS Termination:** SSL/TLS termination at ingress
- **mTLS:** Mutual TLS authentication

**Network Policy với Namespace Isolation:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-namespace
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress: []
  egress: []
```

**Ingress với TLS:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - example.com
    secretName: example-tls
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### 10. Advanced Networking
- **Service Mesh:** Istio, Linkerd
- **API Gateway:** Kong, Ambassador
- **Load Balancer Controllers:** AWS ALB, GCP Load Balancer

**Istio Installation:**
```bash
# Install Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.16.0
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y

# Check Istio components
kubectl get pods -n istio-system
```

**AWS Load Balancer Controller:**
```bash
# Install AWS Load Balancer Controller
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

## Lưu ý quan trọng cho CKA
1. **Service Types:** Hiểu các loại services và khi nào dùng
2. **Ingress:** Cách configure ingress và TLS
3. **Network Policies:** Cách control traffic flow
4. **DNS:** Cách service discovery hoạt động
5. **CNI:** Cách network plugins hoạt động
6. **Load Balancing:** Cách load balancing hoạt động
7. **Troubleshooting:** Cách debug network issues
8. **Security:** Cách secure network traffic

## Practice Commands
```bash
# Tạo service
kubectl expose deployment nginx --port=80 --target-port=80

# Tạo ingress
kubectl apply -f ingress.yaml

# Tạo network policy
kubectl apply -f network-policy.yaml

# Test connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- <service-name>:<port>

# Check DNS
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup <service-name>

# Check network policies
kubectl get networkpolicies --all-namespaces

# Check services
kubectl get services --all-namespaces

# Check ingress
kubectl get ingress --all-namespaces

# Debug network issues
kubectl describe pod <pod-name>
kubectl logs -n kube-system coredns-<pod-name>
``` 