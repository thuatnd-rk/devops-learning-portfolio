# WordPress + Nginx Deployment on Kubernetes (EKS)

A production-ready WordPress deployment on Amazon EKS with Nginx, MySQL, and AWS ALB Ingress.

## 🏗️ Architecture

```
                                    Internet
                                        │
                                        ▼
                            ┌───────────────────────┐
                            │      Route53          │
                            │ wordpress.rookie.click│
                            └───────────────────────┘
                                        │
                                        ▼
                            ┌───────────────────────┐
                            │   AWS ALB (HTTPS)     │
                            │   + ACM Certificate   │
                            └───────────────────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                    │                   │                   │
                    ▼                   ▼                   ▼
            ┌───────────────────────────────────────────────────┐
            │                  EKS Cluster                       │
            │  ┌─────────────────────────────────────────────┐  │
            │  │              Namespace: wordpress            │  │
            │  │                                              │  │
            │  │  ┌────────────┐       ┌─────────────────┐   │  │
            │  │  │ WordPress  │       │     MySQL       │   │  │
            │  │  │ Deployment │──────▶│   StatefulSet   │   │  │
            │  │  │ (Nginx+PHP)│ :3306 │                 │   │  │
            │  │  └────────────┘       └─────────────────┘   │  │
            │  │        │                      │              │  │
            │  │        ▼                      ▼              │  │
            │  │  ┌──────────┐          ┌──────────┐         │  │
            │  │  │   PVC    │          │   PVC    │         │  │
            │  │  │ (EBS gp2)│          │ (EBS gp2)│         │  │
            │  │  └──────────┘          └──────────┘         │  │
            │  └─────────────────────────────────────────────┘  │
            └───────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
wordpress-nginx-deployment/
├── Docker/                  # Custom Docker image files
│   ├── Dockerfile          # WordPress + Nginx + PHP-FPM image
│   ├── php.ini             # PHP configuration
│   ├── startup.sh          # Container startup script
│   ├── wordpress.conf      # Nginx server configuration
│   └── wp-config.php       # WordPress configuration
├── ingress.yaml            # AWS ALB Ingress configuration
├── mysql.yaml              # MySQL StatefulSet + Service
├── mysql-cm.yaml           # MySQL init script ConfigMap
├── networkpolicy.yaml      # Network security policies
├── nginx-cm.yaml           # Nginx configuration ConfigMap
├── secret.yaml             # Database credentials
├── wordpress.yaml          # WordPress Deployment + PVC + Service
└── README.md
```

## ✅ Prerequisites

- **AWS EKS Cluster** with kubectl configured
- **AWS Load Balancer Controller** installed
- **AWS EBS CSI Driver** for persistent volumes
- **ACM Certificate** for SSL/TLS
- **Route53 Hosted Zone** for DNS management
- **External DNS** (optional - for automatic DNS record creation)

### Verify Prerequisites

```bash
# Check EKS connection
kubectl get nodes

# Check AWS Load Balancer Controller
kubectl get pods -n kube-system | grep aws-load-balancer

# Check EBS CSI Driver
kubectl get pods -n kube-system | grep ebs-csi

# Check StorageClass
kubectl get storageclass
```

## 🚀 Deployment

### Step 1: Create Namespace

```bash
kubectl create namespace wordpress
```

### Step 2: Deploy in Order

```bash
# 1. Secrets (Database credentials)
kubectl apply -f secret.yaml

# 2. ConfigMaps
kubectl apply -f mysql-cm.yaml
kubectl apply -f nginx-cm.yaml

# 3. MySQL Database
kubectl apply -f mysql.yaml

# 4. Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l app=mysql -n wordpress --timeout=120s

# 5. WordPress Application
kubectl apply -f wordpress.yaml

# 6. Network Policy
kubectl apply -f networkpolicy.yaml

# 7. Ingress (ALB)
kubectl apply -f ingress.yaml
```

### Step 3: Verify Deployment

```bash
# Check all resources
kubectl get all -n wordpress

# Check PVCs
kubectl get pvc -n wordpress

# Check Ingress (get ALB DNS)
kubectl get ingress -n wordpress
```

## ⚙️ Configuration Details

### Database Credentials (secret.yaml)

Credentials are base64 encoded:

| Key | Description |
|-----|-------------|
| `admin-password` | MySQL root password |
| `username` | WordPress DB user |
| `password` | WordPress DB password |
| `db-name` | Database name |

**To encode your own values:**
```bash
echo -n 'your-password' | base64
```

### Ingress Annotations

| Annotation | Value | Description |
|------------|-------|-------------|
| `alb.ingress.kubernetes.io/scheme` | `internet-facing` | Public ALB |
| `alb.ingress.kubernetes.io/target-type` | `ip` | Direct to Pod IP |
| `alb.ingress.kubernetes.io/certificate-arn` | `arn:aws:acm:...` | ACM SSL cert |
| `alb.ingress.kubernetes.io/ssl-redirect` | `443` | HTTP → HTTPS redirect |
| `alb.ingress.kubernetes.io/success-codes` | `200,302` | Health check codes |

### Resource Limits

| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|----------------|--------------|
| WordPress | 100m | 200m | 256Mi | 512Mi |
| MySQL | 100m | 200m | 256Mi | 512Mi |

### Storage

| Component | Size | StorageClass | Access Mode |
|-----------|------|--------------|-------------|
| WordPress PVC | 2Gi | gp2 | ReadWriteOnce |
| MySQL PVC | 2Gi | gp2 | ReadWriteOnce |

## 🔐 Security

### Network Policy

MySQL is protected by NetworkPolicy:
- **Ingress**: Only allows connections from WordPress pods on port 3306
- **Egress**: Allows all outbound traffic

```yaml
# Only WordPress can access MySQL
ingress:
  - from:
      - podSelector:
          matchLabels:
            app: wordpress
    ports:
      - port: 3306
```

## 🔧 Customization

### Change Domain

1. Update `nginx-cm.yaml`:
   ```yaml
   server_name your-domain.com;
   ```

2. Update `ingress.yaml`:
   ```yaml
   external-dns.alpha.kubernetes.io/hostname: your-domain.com
   rules:
     - host: your-domain.com
   ```

### Update ACM Certificate

```yaml
alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:<region>:<account>:certificate/<cert-id>
```

### Scale WordPress

```bash
kubectl scale deployment wordpress -n wordpress --replicas=3
```

## 🐛 Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n wordpress
kubectl describe pod <pod-name> -n wordpress
kubectl logs <pod-name> -n wordpress
```

### Check PVC Binding
```bash
kubectl get pvc -n wordpress
kubectl describe pvc <pvc-name> -n wordpress
```

### Test Service Connectivity
```bash
# Create debug pod
kubectl run debug --rm -it --image=curlimages/curl -n wordpress -- sh

# Test WordPress service
curl -I http://wordpress-service/

# Test MySQL connectivity
nc -zv mysql-service 3306
```

### Check ALB Health
```bash
# Get Ingress events
kubectl describe ingress wordpress-ingress -n wordpress

# Check AWS Load Balancer Controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| PVC Pending | No StorageClass | Add `storageClassName: gp2` |
| ALB Unhealthy | Health check fails | Add `success-codes: "200,302"` |
| 502 Bad Gateway | Pod not ready | Check readiness probe |
| MySQL connection refused | NetworkPolicy | Verify WordPress pod labels |

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete -f ingress.yaml
kubectl delete -f wordpress.yaml
kubectl delete -f networkpolicy.yaml
kubectl delete -f mysql.yaml
kubectl delete -f nginx-cm.yaml
kubectl delete -f mysql-cm.yaml
kubectl delete -f secret.yaml

# Delete PVCs (this deletes data!)
kubectl delete pvc --all -n wordpress

# Delete namespace
kubectl delete namespace wordpress
```

## 📚 References

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Amazon EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [Kubernetes NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [WordPress on Kubernetes](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/)

---

**Domain:** `wordpress.rookie.click`  
**Author:** Andy  
**Last Updated:** November 2025

