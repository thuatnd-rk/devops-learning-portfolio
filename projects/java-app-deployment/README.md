# Spring PetClinic - Kubernetes Deployment

Triển khai ứng dụng Spring PetClinic trên Kubernetes (EKS) với MySQL database.

## 📋 Tổng quan

Dự án này triển khai [Spring PetClinic](https://github.com/spring-projects/spring-petclinic) - một ứng dụng mẫu của Spring Framework, bao gồm:

- **Java Application**: Spring Boot web application
- **MySQL Database**: Backend database với schema và sample data
- **AWS ALB Ingress**: Expose ứng dụng ra internet qua AWS Application Load Balancer

## 🏗️ Kiến trúc

```
                    ┌─────────────────────────────────────────────────┐
                    │                   Internet                       │
                    └─────────────────────┬───────────────────────────┘
                                          │
                    ┌─────────────────────▼───────────────────────────┐
                    │          AWS Application Load Balancer           │
                    │          (petclinic.rookie.click:443)            │
                    └─────────────────────┬───────────────────────────┘
                                          │
┌─────────────────────────────────────────┼─────────────────────────────────────────┐
│                                   EKS Cluster                                      │
│                                                                                    │
│  ┌──────────────────────────────────────┼──────────────────────────────────────┐  │
│  │                    Namespace: pet-clinic-app                                 │  │
│  │                                      │                                       │  │
│  │   ┌─────────────┐    ┌───────────────▼───────────────┐    ┌──────────────┐  │  │
│  │   │     HPA     │───▶│         Deployment            │◀───│  ConfigMap   │  │  │
│  │   │  (1-3 pods) │    │         java-app              │    │ (app config) │  │  │
│  │   └─────────────┘    │      Port: 8080               │    └──────────────┘  │  │
│  │                      └───────────────┬───────────────┘                       │  │
│  │                                      │                                       │  │
│  │                      ┌───────────────▼───────────────┐                       │  │
│  │                      │          Service              │                       │  │
│  │                      │      java-app-service         │                       │  │
│  │                      └───────────────┬───────────────┘                       │  │
│  └──────────────────────────────────────┼───────────────────────────────────────┘  │
│                                         │                                          │
│  ┌──────────────────────────────────────┼───────────────────────────────────────┐  │
│  │                    Namespace: pet-clinic-db                                   │  │
│  │                                      │                                        │  │
│  │   ┌──────────────┐   ┌───────────────▼───────────────┐   ┌───────────────┐   │  │
│  │   │  ConfigMap   │──▶│        StatefulSet            │◀──│    Secret     │   │  │
│  │   │  (init.sql)  │   │          mysql                │   │ (mysql-cred)  │   │  │
│  │   └──────────────┘   │       Port: 3306              │   └───────────────┘   │  │
│  │                      └───────────────┬───────────────┘                        │  │
│  │                                      │                                        │  │
│  │                      ┌───────────────▼───────────────┐                        │  │
│  │                      │          Service              │                        │  │
│  │                      │       mysql-service           │                        │  │
│  │                      └───────────────────────────────┘                        │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────────────────┘
```

## 📁 Cấu trúc thư mục

```
java-app-deployment/
├── java-app/
│   ├── java.yml          # Deployment + Service
│   ├── configmap.yml     # Application properties
│   ├── hpa.yml           # Horizontal Pod Autoscaler
│   └── ingress.yml       # AWS ALB Ingress
├── mysql/
│   ├── mysql.yml         # StatefulSet + Service
│   └── configmap.yml     # Database init script
├── secret.yml            # Database credentials
└── README.md
```

## 🔧 Cấu hình chi tiết

### Java Application

| Resource | Giá trị |
|----------|---------|
| Image | `techiescamp/kube-petclinic-app:3.0.0` |
| Port | 8080 |
| CPU Request/Limit | 100m / 200m |
| Memory Request/Limit | 256Mi / 512Mi |
| Health Check | `/actuator/health` |
| Replicas (HPA) | 1-3 pods (target CPU: 50%) |

### MySQL Database

| Resource | Giá trị |
|----------|---------|
| Image | `mysql:latest` |
| Port | 3306 |
| Database | `petclinic` |
| CPU Request/Limit | 100m / 200m |
| Memory Request/Limit | 256Mi / 512Mi |

### Namespaces

- `pet-clinic-app`: Java application
- `pet-clinic-db`: MySQL database

## 🚀 Hướng dẫn triển khai

### Prerequisites

- Kubernetes cluster (EKS)
- kubectl configured
- AWS Load Balancer Controller installed
- ACM certificate (cho HTTPS)

### Bước 1: Tạo Namespaces

```bash
kubectl create namespace pet-clinic-app
kubectl create namespace pet-clinic-db
```

### Bước 2: Tạo Secret

```bash
# Secret cần tồn tại ở CẢ HAI namespaces
kubectl apply -f secret.yml

# Copy secret sang namespace pet-clinic-db
kubectl get secret mysql-cred -n pet-clinic-app -o yaml | \
  sed 's/namespace: pet-clinic-app/namespace: pet-clinic-db/' | \
  kubectl apply -f -
```

### Bước 3: Deploy MySQL

```bash
kubectl apply -f mysql/configmap.yml
kubectl apply -f mysql/mysql.yml

# Kiểm tra MySQL đã ready
kubectl get pods -n pet-clinic-db -w
```

### Bước 4: Deploy Java Application

```bash
kubectl apply -f java-app/configmap.yml
kubectl apply -f java-app/java.yml
kubectl apply -f java-app/hpa.yml

# Kiểm tra application đã ready
kubectl get pods -n pet-clinic-app -w
```

### Bước 5: Deploy Ingress (EKS)

```bash
# Cập nhật certificate ARN trong ingress.yml trước khi apply
kubectl apply -f java-app/ingress.yml

# Lấy ALB DNS name
kubectl get ingress -n pet-clinic-app
```

### Bước 6: Cấu hình Route53

1. Lấy ALB DNS name từ Ingress
2. Tạo A record (Alias) trong Route53 trỏ đến ALB

## 🔍 Kiểm tra & Debug

```bash
# Xem tất cả resources
kubectl get all -n pet-clinic-app
kubectl get all -n pet-clinic-db

# Xem logs
kubectl logs -f deployment/java-app -n pet-clinic-app
kubectl logs -f statefulset/mysql -n pet-clinic-db

# Xem HPA status
kubectl get hpa -n pet-clinic-app

# Xem Ingress status
kubectl describe ingress java-app-ingress -n pet-clinic-app

# Test database connection từ Java app
kubectl exec -it deployment/java-app -n pet-clinic-app -- \
  curl localhost:8080/actuator/health
```

## ⚠️ Lưu ý quan trọng

1. **Secret namespace**: Secret `mysql-cred` cần tồn tại ở **cả hai** namespaces (`pet-clinic-app` và `pet-clinic-db`)

2. **Certificate ARN**: Cập nhật `alb.ingress.kubernetes.io/certificate-arn` trong `ingress.yml` với ARN certificate thực tế

3. **Domain**: Thay `petclinic.rookie.click` bằng domain của bạn

4. **MySQL Storage**: Cấu hình hiện tại không có PersistentVolume, data sẽ mất khi Pod restart. Để production, thêm `volumeClaimTemplates` cho StatefulSet

5. **Startup Time**: Java app cần ~3 phút để khởi động (startupProbe có `initialDelaySeconds: 180`)

## 🔐 Thông tin đăng nhập mặc định

| Key | Value (base64 decoded) |
|-----|------------------------|
| username | crunchops |
| password | crunchops@1234 |

## 📚 Tài liệu tham khảo

- [Spring PetClinic](https://github.com/spring-projects/spring-petclinic)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Kubernetes Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

