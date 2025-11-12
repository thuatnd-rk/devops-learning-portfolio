# AWS Load Balancer Controller - Ingress Guide

Hướng dẫn tạo Ingress trên EKS sử dụng AWS Load Balancer Controller để tạo Application Load Balancer (ALB).

## Tổng quan

AWS Load Balancer Controller tự động tạo và quản lý AWS Application Load Balancer (ALB) hoặc Network Load Balancer (NLB) khi bạn tạo Ingress resource trong Kubernetes.

### Cách hoạt động

1. **Ingress Resource**: Bạn tạo Ingress với annotations đặc biệt
2. **AWS Load Balancer Controller**: Controller theo dõi Ingress và tạo ALB/NLB tương ứng
3. **ALB/NLB**: AWS Load Balancer được tạo tự động và route traffic vào cluster
4. **Target Groups**: Controller tự động tạo target groups và đăng ký pods

## Prerequisites

- AWS Load Balancer Controller đã được cài đặt (xem `scripts/setup/install-aws-lbc.sh`)
- Service và Deployment đã được tạo
- IngressClass `alb` đã tồn tại (tự động tạo khi cài controller)

## Kiểm tra IngressClass

kubectl get ingressclassBạn sẽ thấy `alb` class nếu controller đã được cài đặt đúng.

## Các Annotations quan trọng

### 1. Ingress Class
spec:
  ingressClassName: alb### 2. Load Balancer Type
metadata:
  annotations:
    alb.ingress.kubernetes.io/load-balancer-type: internet-facing  # hoặc internal### 3. Scheme (Internet-facing hoặc Internal)ml
metadata:
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing  # hoặc internal### 4. SSL/TLS Certificate
metadata:
  annotations:
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account:certificate/cert-id
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-2-2017-01
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'### 5. Health Check
metadata:
  annotations:
    alb.ingress.kubernetes.io/healthcheck-path: /health
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '3'### 6. Target Type
metadata:
  annotations:
    alb.ingress.kubernetes.io/target-type: ip  # hoặc instance### 7. Subnets (nếu cần chỉ định cụ thể)
metadata:
  annotations:
    alb.ingress.kubernetes.io/subnets: subnet-xxx,subnet-yyy### 8. Security Groups
metadata:
  annotations:
    alb.ingress.kubernetes.io/security-groups: sg-xxx,sg-yyy## Ví dụ

Xem các file ví dụ:
- `basic-ingress.yaml` - Ingress cơ bản
- `tls-ingress.yaml` - Ingress với SSL/TLS
- `path-based-ingress.yaml` - Path-based routing
- `host-based-ingress.yaml` - Host-based routing
- `advanced-ingress.yaml` - Cấu hình nâng cao

## Apply Ingress

kubectl apply -f kubernetes/ingress/basic-ingress.yaml## Kiểm tra Ingress

# Xem Ingress
kubectl get ingress

# Xem chi tiết
kubectl describe ingress <ingress-name>

# Xem ALB được tạo
aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`)].{Name:LoadBalancerName,DNS:DNSName,State:State.Code}'## Lấy ALB URL

# Từ Ingress status
kubectl get ingress <ingress-name> -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Hoặc từ AWS CLI
aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `k8s-<namespace>-<ingress-name>`)].DNSName' --output text## Troubleshooting

### Kiểm tra Controller logssh
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller### Kiểm tra Ingress eventssh
kubectl describe ingress <ingress-name>### Kiểm tra ALB trong AWS Console
- EC2 → Load Balancers → Tìm ALB có tên chứa `k8s-<namespace>-<ingress-name>`

## Tài liệu tham khảo

- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Ingress Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/guide/ingress/annotations/)
- [AWS EKS Ingress Guide](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
