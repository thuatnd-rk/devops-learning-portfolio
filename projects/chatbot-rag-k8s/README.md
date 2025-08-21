# Chatbot RAG Kubernetes Deployment

## 🚀 Tổng quan

Dự án này triển khai một hệ thống chatbot thông minh với khả năng RAG (Retrieval-Augmented Generation) trên Kubernetes. Hệ thống được thiết kế để cung cấp trải nghiệm chat thông minh với khả năng truy xuất và xử lý thông tin từ cơ sở dữ liệu vector.

## 🏗️ Kiến trúc hệ thống

### Core Services

#### 1. **cagent-backend** (Port: 3000)
- **Vai trò**: Service chính xử lý logic nghiệp vụ của ứng dụng C-Agent
- **Endpoint**: Public access cho người dùng và admin
- **Chức năng**:
  - Xử lý các cuộc hội thoại với người dùng
  - Quản lý phiên đăng nhập và xác thực
  - Tích hợp với các service khác để xử lý dữ liệu
  - API endpoints cho frontend và mobile apps
  - Document store management và vector processing
  - Meilisearch integration cho semantic search

#### 2. **s3-explorer-api** (Port: 3001)
- **Vai trò**: Service quản lý dữ liệu thô trên AWS S3
- **Chức năng**:
  - Upload/download files từ S3 bucket
  - Quản lý metadata của documents
  - Xử lý các loại file khác nhau (PDF, DOC, TXT, etc.)
  - Tích hợp với cagent-backend để truy xuất dữ liệu
  - S3 bucket operations và file management

#### 3. **Redis**
- **Vai trò**: In-memory database cho session management
- **Chức năng**:
  - Lưu trữ context của cuộc hội thoại
  - Cache các câu trả lời thường xuyên
  - Session management cho người dùng
  - Temporary storage cho vector embeddings

#### 4. **PostgreSQL**
- **Vai trò**: Primary database lưu trữ thông tin ứng dụng
- **Chức năng**:
  - User management và authentication
  - Conversation history
  - Application settings và configurations
  - Analytics và reporting data

### Data Flow

```
User Request → cagent-backend → [Redis (context) + PostgreSQL (user data)]
                ↓
            s3-explorer-api (document retrieval)
                ↓
            Vector Processing → Response Generation
                ↓
            Redis (context update) + PostgreSQL (log)
```

## ✨ Tính năng chính

- **RAG Capabilities**: Truy xuất thông tin từ documents và tạo câu trả lời chính xác
- **Context Awareness**: Duy trì ngữ cảnh cuộc hội thoại qua Redis
- **Document Management**: Quản lý và xử lý nhiều loại document khác nhau
- **Scalable Architecture**: Thiết kế microservices có thể mở rộng
- **Multi-tenant Support**: Hỗ trợ nhiều tổ chức/workspace

## 🛠️ Công nghệ sử dụng

- **Backend**: Node.js/Python với FastAPI
- **Database**: PostgreSQL, Redis
- **Storage**: AWS S3
- **Container**: Docker
- **Orchestration**: Kubernetes
- **Secrets Management**: External Secrets Operator với AWS Secrets Manager
- **Image Registry**: AWS ECR (Elastic Container Registry)
- **Monitoring**: Prometheus, Grafana, Alertmanager
- **CI/CD**: GitHub Actions, GitLab CI, Jenkins
- **Infrastructure**: Terraform
- **Search Engine**: Meilisearch

## 📁 Cấu trúc dự án

```
chatbot-rag-k8s/
├── manifests/           # Kubernetes manifests
│   ├── external-secrets/  # External Secrets Operator manifests
│   ├── deployments/       # Application deployments
│   ├── services/          # Service definitions
│   └── ...               # Other manifests
├── helm/               # Helm charts
├── terraform/          # Infrastructure as Code
├── ci-cd/              # CI/CD pipelines
├── docs/               # Documentation
├── scripts/            # Deployment scripts
└── tests/              # Testing configurations
```

## 🚀 Triển khai

### Yêu cầu hệ thống
- Kubernetes cluster (v1.24+) trên EC2 instances
- Helm 3.x
- kubectl
- AWS CLI
- Terraform (cho infrastructure)

### Prerequisites
- AWS ECR repository với images: `pvi/cagent:latest`, `pvi/s3:latest`
- AWS Secrets Manager secret: `ndthuat-k8s`
- IAM role cho EC2 instances với quyền truy cập ECR và Secrets Manager

### Quick Start
```bash
# Clone repository
git clone <repository-url>
cd chatbot-rag-k8s

# Tạo ECR secret để pull images
aws ecr get-login-password --region us-east-1 \
| kubectl create secret docker-registry ecr-secret \
  --docker-server=187091248012.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password-stdin

# Deploy to Kubernetes
kubectl apply -f manifests/namespaces/
kubectl apply -f manifests/external-secrets/
kubectl apply -f manifests/deployments/
kubectl apply -f manifests/services/
```

## 📊 Monitoring & Observability

- **Metrics**: Prometheus metrics collection
- **Logging**: Centralized logging với ELK stack
- **Alerting**: Alertmanager cho notifications
- **Dashboards**: Grafana dashboards cho visualization

## 🔒 Bảo mật

- **Network Policies**: Isolate services
- **RBAC**: Role-based access control
- **Secrets Management**: External Secrets Operator với AWS Secrets Manager
- **Image Security**: ECR image scanning và vulnerability assessment
- **Pod Security**: Security contexts và policies
- **ECR Authentication**: Docker registry secrets cho private images

## 🔐 External Secrets Operator

### Tổng quan
Dự án sử dụng [External Secrets Operator](https://external-secrets.io/latest/provider/aws-secrets-manager/) để quản lý secrets một cách an toàn và tự động từ AWS Secrets Manager thay vì lưu trữ trực tiếp trong Kubernetes manifests.

### Kiến trúc Secrets Management

```
AWS Secrets Manager → External Secrets Operator → Kubernetes Secret → Application Pods
```

### Các thành phần chính

#### 1. **SecretStore**
- **Vai trò**: Định nghĩa kết nối đến AWS Secrets Manager
- **Authentication**: Sử dụng IAM role của EC2 instances (Pod Identity)
- **Region**: us-east-1 (có thể tùy chỉnh theo môi trường)

#### 2. **ExternalSecret**
- **Vai trò**: Định nghĩa quy tắc lấy secrets từ AWS Secrets Manager
- **Refresh**: Tự động cập nhật mỗi 1 giờ
- **Mapping**: Map secrets từ AWS sang Kubernetes với key names tùy chỉnh

### Secrets được quản lý

#### **Redis Secret**
- **AWS Secret Name**: `ndthuat-k8s`
- **Property**: `redis_password`
- **Kubernetes Secret**: `redis-secret`
- **Usage**: Redis authentication và connection

#### **PostgreSQL Secret**
- **AWS Secret Name**: `ndthuat-k8s`
- **Properties**: `postgres_password`, `postgres_username`, `postgres_database`
- **Kubernetes Secret**: `postgres-secret`
- **Usage**: Database connection và authentication

#### **AWS S3 Secret**
- **AWS Secret Name**: `ndthuat-k8s`
- **Properties**: `aws_access_key_id`, `aws_secret_access_key`, `s3_bucket_name`
- **Kubernetes Secret**: `s3-secret`
- **Usage**: S3 bucket access và file operations

### Triển khai

#### **Cài đặt External Secrets Operator**
```bash
# Thêm Helm repository
helm repo add external-secrets https://charts.external-secrets.io

# Cài đặt operator
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets \
  --create-namespace
```

#### **Áp dụng SecretStore và ExternalSecrets**
```bash
# Áp dụng SecretStore trước
kubectl apply -f manifests/external-secrets/secretstore-aws.yaml

# Áp dụng ExternalSecrets
kubectl apply -f manifests/external-secrets/externalsecret-redis.yaml
kubectl apply -f manifests/external-secrets/externalsecret-postgres.yaml
# kubectl apply -f manifests/external-secrets/externalsecret-s3.yaml
```

#### **Kiểm tra trạng thái**
```bash
# Kiểm tra SecretStore
kubectl get secretstore -n chatbot

# Kiểm tra ExternalSecrets
kubectl get externalsecret -n chatbot

# Kiểm tra secrets được tạo
kubectl get secret -n chatbot
```

### IAM Policy cần thiết

EC2 instances cần có IAM role với policy sau để truy cập AWS Secrets Manager và ECR:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:*:secret:ndthuat-k8s*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
```

### Ưu điểm

- **🔐 Bảo mật cao**: Không lưu trữ credentials trong Kubernetes manifests
- **🔄 Tự động sync**: Secrets được cập nhật tự động từ AWS Secrets Manager
- **🎯 Centralized management**: Quản lý tập trung tất cả secrets
- **📝 Audit trail**: Theo dõi truy cập qua CloudTrail
- **🚀 Zero downtime**: Không cần restart pods khi secrets thay đổi
- **🏷️ Version control**: Hỗ trợ versioning và rollback secrets

### Monitoring và Troubleshooting

#### **Kiểm tra logs**
```bash
# Logs của External Secrets Operator
kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets

# Events của ExternalSecret
kubectl describe externalsecret redis-secret -n chatbot
```

#### **Trạng thái sync**
```bash
# Kiểm tra sync status
kubectl get externalsecret redis-secret -n chatbot -o yaml | grep -A 5 status
```

### Best Practices

1. **Namespace Isolation**: Mỗi namespace có SecretStore riêng
2. **Least Privilege**: IAM role chỉ có quyền cần thiết
3. **Secret Naming**: Sử dụng consistent naming convention
4. **Refresh Interval**: Cân bằng giữa security và performance
5. **Monitoring**: Theo dõi sync status và errors
6. **Backup**: Backup AWS Secrets Manager secrets định kỳ

## 🚀 Services Status & Configuration

### Current Deployed Services

#### **cagent-backend**
- **Status**: ✅ Deployed
- **Image**: `187091248012.dkr.ecr.us-east-1.amazonaws.com/pvi/cagent:latest`
- **Port**: 3000
- **Resources**: 1Gi request, 4Gi limit
- **Environment**: Production
- **Database**: PostgreSQL (via postgres-secret)
- **Features**: 
  - Document store management
  - Meilisearch integration
  - S3 integration via s3-explorer-api

#### **s3-explorer-api**
- **Status**: ✅ Deployed
- **Image**: `187091248012.dkr.ecr.us-east-1.amazonaws.com/pvi/s3:latest`
- **Port**: 3001
- **Resources**: 128Mi request, 512Mi limit
- **S3 Bucket**: `ndthuat-lab`
- **Region**: `ap-southeast-1`

#### **PostgreSQL**
- **Status**: ✅ Deployed
- **Port**: 5432
- **Credentials**: Managed via AWS Secrets Manager
- **Connection**: Internal service name `postgres`

#### **Redis**
- **Status**: ✅ Deployed
- **Port**: 6379
- **Password**: Managed via AWS Secrets Manager
- **Connection**: Internal service name `redis`

### Service Dependencies

```
cagent-backend (3000) ←→ s3-explorer-api (3001)
       ↓                           ↓
  PostgreSQL (5432)           Redis (6379)
       ↓                           ↓
  AWS Secrets Manager      AWS Secrets Manager
```

### Network Configuration

- **Namespace**: `chatbot`
- **Service Type**: `ClusterIP` (internal communication)
- **Image Pull**: `ecr-secret` for ECR authentication
- **Health Checks**: TCP probes on respective ports

### Public Access Configuration

#### **cagent-backend Public Access**
- **Current Status**: Internal only (ClusterIP)
- **Public Access Options**:
  1. **LoadBalancer Service**: Direct public exposure
  2. **Ingress + ALB**: Recommended approach with HTTPS support
  3. **NodePort + NLB**: Alternative for specific use cases

#### **Ingress Configuration (Recommended)**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cagent-backend
  namespace: chatbot
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    external-dns.alpha.kubernetes.io/hostname: api.your-domain.com
spec:
  rules:
  - host: api.your-domain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cagent-backend
            port:
              number: 3000
```

#### **Prerequisites for Public Access**
- AWS Load Balancer Controller installed
- IAM permissions for ALB/NLB creation
- Route53 hosted zone configured
- ACM certificate (for HTTPS)