# ArgoCD Configuration

Cấu hình ArgoCD cho dự án AI Agent EKS với kiến trúc multi-tenant, multi-repo.

## Cấu trúc

```
argocd/
├── projects/
│   └── ai-agent-project.yaml      # AppProject định nghĩa repos và permissions
├── applications/
│   ├── customer-a/                # Applications cho Customer A
│   │   ├── frontend-app.yaml
│   │   ├── backend-app.yaml
│   │   └── data-manager.yaml
│   ├── customer-b/                # Applications cho Customer B
│   │   ├── frontend-app.yaml
│   │   ├── backend-app.yaml
│   │   └── data-manager.yaml
│   └── ingress-apps.yaml         # Ingress configurations
├── repositories/
│   └── github-repo-secret.yaml   # GitHub repo credentials (nếu private)
├── values.yaml                    # Helm values cho ArgoCD installation
└── README.md
```

## Kiến trúc

- **AppProject**: `ai-agent` - Quản lý tất cả applications
- **Mỗi Customer**: Có namespace riêng với 3 services:
  - Frontend (repo riêng)
  - Backend (repo riêng)
  - Data Manager (repo riêng)
- **Ingress**: Quản lý ingress configurations từ main repo

## Deployment

```bash
# 1. Apply AppProject
kubectl apply -f projects/ai-agent-project.yaml

# 2. Apply Repository Secret (nếu private repos)
kubectl apply -f repositories/github-repo-secret.yaml

# 3. Apply Applications
kubectl apply -f applications/
```

## Cấu hình

- **Sync Policy**: Automated với prune và selfHeal
- **Namespace**: Tự động tạo nếu chưa tồn tại
- **Repos**: Mỗi service có repo riêng, được khai báo trong AppProject
