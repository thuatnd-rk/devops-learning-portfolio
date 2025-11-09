# EKS Cluster Setup Checklist

## Prerequisites
- [ ] AWS CLI, kubectl, Helm 3.0+, eksctl đã cài đặt
- [ ] EKS cluster đã được provision
- [ ] Node groups đã được tạo và nodes đang Ready
- [ ] kubeconfig đã được cấu hình

## Installation Steps

1. [ ] Associate IAM OIDC Provider với cluster
   - `eksctl utils associate-iam-oidc-provider --region=<region> --cluster=<cluster-name> --approve`

2. [ ] Cài AWS Load Balancer Controller
   - Script: `scripts/setup/install-aws-load-balancer-controller.sh`
   - Tài liệu: https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

3. [ ] Cài Gateway API CRDs
   - `kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml`

4. [ ] Cài NGINX Gateway Fabric
   - Script: `scripts/setup/install-nginx-gateway-fabric.sh`

5. [ ] Tạo Gateway Resource
   - File: `kubernetes/ingress/gateway.yaml`
   - Apply: `kubectl apply -f kubernetes/ingress/gateway.yaml`

6. [ ] Cài ArgoCD
   - Script: `scripts/setup/install-argocd.sh`

## Verification
- [ ] Verify tất cả pods đang Running
- [ ] Verify Gateway đã có ALB address
- [ ] Verify ArgoCD có thể truy cập
