# AI Agent EKS Deployment

## 📋 Tổng quan dự án

Dự án triển khai ứng dụng **AI Agent** (Chatbot) trên Amazon EKS với kiến trúc multi-tenant, hỗ trợ nhiều khách hàng trên cùng một cluster.

## 🏗️ Kiến trúc ứng dụng

### Services

Ứng dụng bao gồm các services sau:

- **Frontend**: Giao diện người dùng
- **Backend**: API và business logic
- **Data Manager**: Quản lý dữ liệu chatbot
- **Redis**: Cache và session management (self-managed)
- **PostgreSQL**: Database (self-managed)

### Multi-Tenant Architecture

Triển khai cho **3 khách hàng**:

- **Customer A**
- **Customer B**
- **Customer C**

Mỗi khách hàng được triển khai trong một **namespace riêng biệt**, đảm bảo:
- Tách biệt tài nguyên (resources isolation)
- Tách biệt dữ liệu (data isolation)
- Bảo mật và compliance

## 🖥️ Hạ tầng Worker Nodes

Cluster được cấu hình với các node groups theo layer:

### Data Layer
- **Labels**: `workload-type=data`
- **Taints**: `workload-type=data:NoSchedule`
- **Mục đích**: Chỉ cho phép các thành phần data truy cập
- **Workloads**: PostgreSQL, Redis

### Application Layer
- **Labels**: `workload-type=application`
- **Taints**: (None)
- **Mục đích**: Cho phép các thành phần application truy cập
- **Workloads**: Frontend, Backend, Data Manager

## 📁 Cấu trúc dự án

```
ai-agent-eks/
├── terraform/              # Infrastructure as Code
├── helm/                   # Helm charts
│   └── ai-agent/          # Application Helm chart
├── kubernetes/            # Kubernetes manifests
│   ├── apps/             # Application manifests
│   └── monitoring/       # Monitoring resources
├── argocd/               # ArgoCD configurations
│   ├── applications/     # ArgoCD Application manifests
│   └── projects/         # ArgoCD Projects
├── cicd/                 # CI/CD configurations
│   └── .github/         # GitHub Actions workflows
├── scripts/              # Utility scripts
│   ├── setup/           # Setup scripts
│   ├── deploy/          # Deployment scripts
│   └── utils/           # Utility scripts
├── configs/             # Configuration files
├── docs/                # Documentation
├── eks-cluster-checklist.md  # EKS setup checklist
└── README.md            # This file
```

## 🚀 Quick Start

*(Sẽ được bổ sung trong quá trình phát triển)*

## 🔧 Công nghệ sử dụng

- **Kubernetes**: Amazon EKS
- **Infrastructure as Code**: Terraform
- **Package Management**: Helm
- **GitOps**: ArgoCD
- **CI/CD**: GitHub Actions
- **Container Registry**: *(sẽ bổ sung)*

## 📚 Tài liệu

- [EKS Cluster Setup Checklist](eks-cluster-checklist.md)
- [Architecture Documentation](docs/architecture.md) *(coming soon)*
- [Deployment Guide](docs/deployment.md) *(coming soon)*
- [Troubleshooting Guide](docs/troubleshooting.md) *(coming soon)*

## 📝 Ghi chú phát triển

*(Khu vực này sẽ được cập nhật trong quá trình phát triển)*

---

**Last updated**: 2025-11-08
