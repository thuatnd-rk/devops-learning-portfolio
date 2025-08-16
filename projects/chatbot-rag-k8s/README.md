# Chatbot RAG Kubernetes Deployment

## 🚀 Tổng quan

Dự án này triển khai một hệ thống chatbot thông minh với khả năng RAG (Retrieval-Augmented Generation) trên Kubernetes. Hệ thống được thiết kế để cung cấp trải nghiệm chat thông minh với khả năng truy xuất và xử lý thông tin từ cơ sở dữ liệu vector.

## 🏗️ Kiến trúc hệ thống

### Core Services

#### 1. **chatbot-backend** (Port: 3000)
- **Vai trò**: Service chính xử lý logic nghiệp vụ của ứng dụng
- **Endpoint**: Public access cho người dùng và admin
- **Chức năng**:
  - Xử lý các cuộc hội thoại với người dùng
  - Quản lý phiên đăng nhập và xác thực
  - Tích hợp với các service khác để xử lý dữ liệu
  - API endpoints cho frontend và mobile apps

#### 2. **chatbot-s3**
- **Vai trò**: Service quản lý dữ liệu thô trên AWS S3
- **Chức năng**:
  - Upload/download files từ S3 bucket
  - Quản lý metadata của documents
  - Xử lý các loại file khác nhau (PDF, DOC, TXT, etc.)
  - Tích hợp với chatbot-backend để truy xuất dữ liệu

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
User Request → chatbot-backend → [Redis (context) + PostgreSQL (user data)]
                ↓
            chatbot-s3 (document retrieval)
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
- **Monitoring**: Prometheus, Grafana, Alertmanager
- **CI/CD**: GitHub Actions, GitLab CI, Jenkins
- **Infrastructure**: Terraform

## 📁 Cấu trúc dự án

```
chatbot-rag-k8s/
├── manifests/           # Kubernetes manifests
├── helm/               # Helm charts
├── terraform/          # Infrastructure as Code
├── ci-cd/              # CI/CD pipelines
├── docs/               # Documentation
├── scripts/            # Deployment scripts
└── tests/              # Testing configurations
```

## 🚀 Triển khai

### Yêu cầu hệ thống
- Kubernetes cluster (v1.24+)
- Helm 3.x
- kubectl
- Terraform (cho infrastructure)

### Quick Start
```bash
# Clone repository
git clone <repository-url>
cd chatbot-rag-k8s

# Deploy to Kubernetes
./scripts/deploy.sh
```

## 📊 Monitoring & Observability

- **Metrics**: Prometheus metrics collection
- **Logging**: Centralized logging với ELK stack
- **Alerting**: Alertmanager cho notifications
- **Dashboards**: Grafana dashboards cho visualization

## 🔒 Bảo mật

- **Network Policies**: Isolate services
- **RBAC**: Role-based access control
- **Secrets Management**: Kubernetes secrets
- **Pod Security**: Security contexts và policies

## 🤝 Đóng góp

Xem [CONTRIBUTING.md](CONTRIBUTING.md) để biết thêm chi tiết về cách đóng góp vào dự án.

## 📄 License

Dự án này được phân phối dưới giấy phép MIT. Xem [LICENSE](LICENSE) để biết thêm chi tiết.

## 📞 Liên hệ

- **Maintainer**: [Your Name]
- **Email**: [your.email@example.com]
- **Project**: [GitHub Repository URL]
