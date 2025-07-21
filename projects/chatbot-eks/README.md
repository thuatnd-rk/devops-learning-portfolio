# EKS Deployment Guide

## Tổng quan

Dự án này triển khai một hệ thống microservices trên Amazon EKS với các thành phần chính:
- **Cagent**: Service chính (port 3000) - AI Agent service
- **S3 Explorer**: Service quản lý S3 (port 3001) - Document storage và management
- **PostgreSQL 16**: Database chính (port 5432) - Persistent data storage
- **Redis**: Cache database (port 6379) - Session và cache storage
- **AWS Load Balancer Controller**: Quản lý ALB/NLB

## Cấu trúc thư mục

```
chatbot-eks/
├── aws-configs/           # AWS IAM policies và configurations
├── ci-cd/                 # CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins)
├── docs/                  # Documentation
├── helm/                  # Helm charts cho từng service
│   ├── cagent/
│   ├── redis/
│   └── s3-explorer/
├── manifests/             # Kubernetes manifests
│   ├── configmaps/        # Configuration maps
│   ├── deployments/       # Deployment configurations
│   ├── ingress/          # Ingress rules
│   ├── monitoring/       # Monitoring stack
│   ├── namespaces/       # Namespace definitions
│   ├── rbac/            # RBAC configurations
│   ├── secrets/         # Kubernetes secrets
│   ├── service-accounts/ # Service accounts với IAM roles
│   └── services/        # Service definitions
├── scripts/              # Deployment scripts
├── security/             # Security configurations
│   ├── network-policies/ # Network policies
│   ├── pod-security-policies/
│   └── security-contexts/
├── terraform/            # Infrastructure as Code
│   ├── environments/     # Environment-specific configs
│   └── modules/         # Reusable Terraform modules
└── tools/               # Development tools và kubectl plugins
```

## Prerequisites

### 1. AWS CLI và kubectl
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

### 2. Helm
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 3. Terraform
```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

## Triển khai EKS Cluster

### Bước 1: Tạo EKS Cluster

```bash
# Tạo cluster với eksctl
eksctl create cluster \
  --name ndthuat \
  --region ap-southeast-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed
```

### Bước 2: Setup OIDC Provider

```bash
# Tạo OIDC provider cho cluster
eksctl utils associate-iam-oidc-provider \
  --cluster=ndthuat \
  --region=ap-southeast-1 \
  --approve
```

### Bước 3: Setup AWS Load Balancer Controller

```bash
# Tạo IAM Service Account cho ALB Controller
eksctl create iamserviceaccount \
  --cluster=ndthuat \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::187091248012:policy/AWSLoadBalancerControllerIAMPolicy \
  --region=ap-southeast-1 \
  --approve

# Install ALB Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=ndthuat \
  --set region=ap-southeast-1 \
  --set vpcId=vpc-00d91f6eba8934759 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --version 1.13.0
```

## Triển khai Applications

### Bước 1: Tạo Namespace

```bash
kubectl apply -f manifests/namespaces/vpcp-namespace.yaml
```

### Bước 2: Tạo ConfigMaps và Secrets

```bash
# Apply ConfigMaps
kubectl apply -f manifests/configmaps/

# Apply Secrets
kubectl apply -f manifests/secrets/
```

### Bước 3: Tạo Service Accounts với IAM Roles

```bash
# Tạo IAM Service Account cho Cagent (Bedrock và S3 access)
eksctl create iamserviceaccount \
  --cluster=ndthuat \
  --namespace=vpcp-app \
  --name=cagent-sa \
  --attach-policy-arn=arn:aws:iam::187091248012:policy/ndthuatCagentKnowledgebaseAccessPolicy \
  --region=ap-southeast-1 \
  --approve

# Tạo IAM Service Account cho S3 Explorer
eksctl create iamserviceaccount \
  --cluster=ndthuat \
  --namespace=vpcp-app \
  --name=s3-explorer-sa \
  --attach-policy-arn=arn:aws:iam::187091248012:policy/ndthuatCagentS3ExplorerS3AccessPolicy \
  --region=ap-southeast-1 \
  --approve
```

### Bước 4: Deploy Services

```bash
# Deploy PostgreSQL 16
kubectl apply -f manifests/deployments/postgres-deployment.yaml
kubectl apply -f manifests/services/postgres-service.yaml

# Deploy Redis
kubectl apply -f manifests/deployments/redis-deployment.yaml
kubectl apply -f manifests/services/redis-service.yaml

# Deploy S3 Explorer
kubectl apply -f manifests/deployments/s3-explorer-deployment.yaml
kubectl apply -f manifests/services/s3-explorer-service.yaml

# Deploy Cagent
kubectl replace -f manifests/deployments/cagent-deployment.yaml
kubectl replace -f manifests/services/cagent-service.yaml
```

### Bước 5: Setup Ingress

```bash
# Apply Ingress
kubectl apply -f manifests/ingress/cagent-ingress.yaml
```

## Cấu hình Domain và SSL

### Bước 1: Tạo Route53 Record

1. **Lấy ALB DNS name:**
```bash
kubectl get ingress vpcp-ingress -n vpcp-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

2. **Tạo A record trong Route53:**
   - Record name: `cagent`
   - Record type: `A`
   - Alias: `Yes`
   - Route traffic to: `Application and Classic Load Balancer`
   - Region: `Asia Pacific (Singapore) ap-southeast-1`
   - Load balancer: [ALB DNS name từ bước 1]

### Bước 2: Cấu hình SSL Certificate

1. **Tạo certificate trong AWS Certificate Manager:**
   - Domain: `*.learnaws.click`
   - Validation: DNS validation

2. **Cập nhật certificate ARN trong ingress:**
```yaml
alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:ap-southeast-1:187091248012:certificate/e2fc0a1c-04eb-43d9-b235-cc3ee9f440a4
```

## Service Discovery và Networking

### Internal Service Communication

Các services giao tiếp với nhau thông qua Kubernetes DNS:

- **Cagent → S3 Explorer**: `http://s3-explorer-service.vpcp-app.svc.cluster.local:3001`
- **Cagent → PostgreSQL**: `postgres-service.vpcp-app.svc.cluster.local:5432`
- **S3 Explorer → PostgreSQL**: `postgres-service.vpcp-app.svc.cluster.local:5432`
- **S3 Explorer → Redis**: `redis-service.vpcp-app.svc.cluster.local:6379`

### External Services

- **AI Service**: `http://3.231.34.3:8001`
- **Trigger API**: `https://trigger.1882.studio.ai.vn`
- **Meilisearch**: `https://search.cmcts1.studio.ai.vn`
- **Firecrawl**: `https://firecrawl.1882.studio.ai.vn`

## Environment Variables

### Cagent Service
```yaml
# Basic Configuration
NODE_ENV: "production"
PORT: "3000"
CORS_ORIGINS: "*"
IFRAME_ORIGINS: "*"

# Database Configuration
DATABASE_TYPE: "postgres"
DATABASE_PORT: "5432"
DATABASE_HOST: "postgres-service.vpcp-app.svc.cluster.local"
DATABASE_NAME: "cagent"
DATABASE_USER: "cagent_app"
DATABASE_PASSWORD: "[from secret]"

# Authentication
LOGIN_TYPE: "token"
ACCESS_TOKEN_SECRET: "[configured]"
REFRESH_TOKEN_SECRET: "[configured]"

# Document Store
VITE_DOCUMENT_STORE_TYPE: "s3"
VITE_DOCUMENT_STORE_BASE_URL: "http://s3-explorer-service.vpcp-app.svc.cluster.local:3001"

# S3 Configuration
S3_STORAGE_REGION: "us-east-1"
S3_STORAGE_BUCKET_NAME: "vpcp-cagent-poc-docs"

# Performance
CLUSTER_RATELIMIT_POINTS: "60"
NODE_OPTIONS: "--expose-gc --max-old-space-size=4096"
FORCE_GC: "true"
```

### S3 Explorer Service
```yaml
# Basic Configuration
NODE_ENV: "production"
PORT: "3001"

# S3 Configuration
S3_STORAGE_BUCKET_NAME: "vpcp-cagent-poc-docs"
S3_STORAGE_REGION: "us-east-1"
AWS_REGION: "us-east-1"

# Database Configuration
DATABASE_TYPE: "postgres"
DATABASE_PORT: "5432"
DATABASE_HOST: "postgres-service.vpcp-app.svc.cluster.local"
DATABASE_NAME: "cagent"
DATABASE_USER: "cagent_app"
DATABASE_PASSWORD: "[from secret]"

# Redis Configuration
REDIS_HOST: "redis-service.vpcp-app.svc.cluster.local"
REDIS_PORT: "6379"
REDIS_PASSWORD: "[from secret]"

# External Services
BASE_URL: "http://3.231.34.3:8001"
X_AUTH_SECRET_KEY: "[configured]"
TRIGGER_SECRET_KEY: "[configured]"
TRIGGER_API_URL: "https://trigger.1882.studio.ai.vn"

# AWS OpenSearch
COLLECTION_ARN: "arn:aws:aoss:us-east-1:187091248012:collection/hjrorw4a5fdfg1fwhg28"
BUCKET_OWNER_ACCOUNT_ID: "187091248012"
ROLE_ARN: "arn:aws:iam::187091248012:role/VPCPCAgentBedrock"
```

### PostgreSQL 16
```yaml
# Database Configuration
POSTGRES_DB: "cagent"
POSTGRES_USER: "cagent_app"
POSTGRES_PASSWORD: "[from secret]"
PGDATA: "/var/lib/postgresql/data/pgdata"

# Performance Tuning
POSTGRES_SHARED_BUFFERS: "256MB"
POSTGRES_EFFECTIVE_CACHE_SIZE: "1GB"
POSTGRES_MAINTENANCE_WORK_MEM: "64MB"
POSTGRES_MAX_CONNECTIONS: "100"
```

### Redis
```yaml
# Redis Configuration
REDIS_PASSWORD: "[from secret]"
REDIS_MAXMEMORY: "1gb"
REDIS_MAXMEMORY_POLICY: "allkeys-lru"
```

## IAM Roles và Permissions

### Cagent Service Account
- **Role ARN**: `arn:aws:iam::187091248012:role/CagentKnowledgebaseAccessTaskRole`
- **Permissions**: Bedrock access, S3 access, CloudWatch logs, ECR pull

### S3 Explorer Service Account
- **Role ARN**: `arn:aws:iam::187091248012:role/CagentS3ExplorerS3AccessRole`
- **Permissions**: S3 bucket access, Bedrock access, SSM managed instance core

## Monitoring và Logging

### Prometheus và Grafana

```bash
# Install Prometheus Operator
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

### CloudWatch Logs

```bash
# Install CloudWatch Agent
kubectl apply -f manifests/monitoring/cloudwatch/
```

## Security

### Network Policies

```bash
# Apply network policies
kubectl apply -f security/network-policies/
```

### RBAC

```bash
# Apply RBAC configurations
kubectl apply -f manifests/rbac/
```

## CI/CD

### GitHub Actions

```bash
# Setup GitHub Actions secrets
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# EKS_CLUSTER_NAME
# EKS_REGION
```

### GitLab CI

```bash
# Setup GitLab CI variables
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# EKS_CLUSTER_NAME
# EKS_REGION
```

## Troubleshooting

### Kiểm tra cluster status

```bash
# Kiểm tra nodes
kubectl get nodes

# Kiểm tra pods
kubectl get pods -n vpcp-app

# Kiểm tra services
kubectl get services -n vpcp-app

# Kiểm tra ingress
kubectl get ingress -n vpcp-app
```

### Debug pods

```bash
# Xem logs của pod
kubectl logs <pod-name> -n vpcp-app

# Describe pod
kubectl describe pod <pod-name> -n vpcp-app

# Exec vào pod
kubectl exec -it <pod-name> -n vpcp-app -- /bin/bash
```

### Debug database connection

```bash
# Test PostgreSQL connection
kubectl exec -it <postgres-pod-name> -n vpcp-app -- psql -U cagent_app -d cagent

# Check environment variables
kubectl exec -it <cagent-pod-name> -n vpcp-app -- env | grep DATABASE_
kubectl exec -it <s3-pod-name> -n vpcp-app -- env | grep DATABASE_
```

### Debug ALB Controller

```bash
# Kiểm tra ALB Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Kiểm tra ingress events
kubectl describe ingress vpcp-ingress -n vpcp-app
```

## Cleanup

### Xóa toàn bộ resources

```bash
# Xóa applications
kubectl delete namespace vpcp-app

# Xóa ALB Controller
helm uninstall aws-load-balancer-controller -n kube-system

# Xóa cluster
eksctl delete cluster --name ndthuat --region ap-southeast-1
```

## Best Practices

### 1. Security
- Sử dụng IAM roles cho service accounts (IRSA)
- Implement network policies
- Regular security updates
- Encrypt secrets at rest
- Use Kubernetes secrets for sensitive data

### 2. Monitoring
- Setup comprehensive logging
- Monitor resource usage
- Alert on critical events
- Regular backup procedures
- Health checks for all services

### 3. Scaling
- Use Horizontal Pod Autoscaler
- Monitor resource limits
- Implement proper health checks
- Use node groups for different workloads
- Database connection pooling

### 4. Cost Optimization
- Use spot instances where possible
- Monitor resource usage
- Implement proper resource limits
- Regular cleanup of unused resources
- Use appropriate instance types

### 5. Database Management
- Regular backups
- Connection pooling
- Performance monitoring
- Proper indexing
- Resource limits

## Support

Để được hỗ trợ, vui lòng:
1. Kiểm tra [troubleshooting guide](docs/troubleshooting.md)
2. Xem [deployment guide](docs/deployment-guide.md)
3. Tham khảo [architecture documentation](docs/architecture.md)
4. Liên hệ team DevOps

---

**Lưu ý**: 
- Đảm bảo thay đổi các giá trị như AWS account ID, domain names, và certificate ARNs theo environment của bạn
- Các sensitive data được lưu trong Kubernetes Secrets
- Service discovery sử dụng Kubernetes DNS
- PostgreSQL 16 được sử dụng làm database chính
- Tất cả services đều có health checks và resource limits
