# EKS Cluster Setup Checklist

## 📋 Pre-requisites (Trước khi bắt đầu)

### IAM & Permissions
- [ ] AWS account có đủ quyền tạo EKS, EC2, VPC, IAM
- [ ] Tạo IAM role cho EKS Cluster (use case: EKS - Cluster)
  - [ ] Role có policy: `AmazonEKSClusterPolicy`
  - [ ] Ghi lại ARN của role: `_________________`
- [ ] Tạo IAM role cho Node Group (use case: EKS - Nodegroup)
  - [ ] Role có policies: `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`
  - [ ] Ghi lại ARN của role: `_________________`
- [ ] (Optional) Tạo IAM roles cho các add-ons cần thiết:
  - [ ] CloudWatch Agent role
  - [ ] AWS Load Balancer Controller role
  - [ ] EBS CSI Driver role
  - [ ] EFS CSI Driver role (nếu cần)
  - [ ] Cluster Autoscaler role (nếu cần)

### Network Planning
- [ ] Quyết định Region: `_________________`
- [ ] Quyết định VPC strategy:
  - [ ] Tạo VPC mới (AWS tự động tạo)
  - [ ] Sử dụng VPC hiện có
- [ ] Nếu dùng VPC hiện có:
  - [ ] VPC có ít nhất 2 subnet ở 2 AZ khác nhau
  - [ ] Subnet có đủ IP addresses (khuyến nghị: /19 hoặc lớn hơn)
  - [ ] NAT Gateway hoặc Internet Gateway đã cấu hình
  - [ ] Security Groups đã được chuẩn bị

### Tools & Access
- [ ] AWS CLI đã cài đặt và cấu hình (`aws --version`)
- [ ] kubectl đã cài đặt (`kubectl version --client`)
- [ ] (Optional) eksctl đã cài đặt (`eksctl version`)
- [ ] AWS credentials đã được cấu hình (`aws configure`)

---

## 🚀 Cluster Creation (Tạo Cluster)

### Step 1: Configure Cluster
- [ ] Vào AWS Console → EKS → Create cluster
- [ ] **Cluster configuration:**
  - [ ] Cluster name: `_________________`
  - [ ] Kubernetes version: `_________________` (khuyến nghị: latest stable)
  - [ ] Cluster service role: Chọn role đã tạo ở pre-requisites
- [ ] **Secrets encryption (Optional):**
  - [ ] Enable secrets encryption: Yes/No
  - [ ] KMS key ARN (nếu enable): `_________________`

### Step 2: Networking
- [ ] **VPC configuration:**
  - [ ] VPC: Chọn VPC (mới hoặc hiện có)
  - [ ] Subnets: Chọn ít nhất 2 subnet ở 2 AZ khác nhau
  - [ ] Security group: Chọn hoặc để AWS tự tạo
- [ ] **Cluster endpoint access:**
  - [ ] Public endpoint: Enable/Disable
  - [ ] Private endpoint: Enable/Disable
  - [ ] (Nếu Public) Whitelist IP addresses: `_________________`

### Step 3: Logging
- [ ] Enable control plane logging:
  - [ ] API server
  - [ ] Audit
  - [ ] Authenticator
  - [ ] Controller manager
  - [ ] Scheduler
- [ ] CloudWatch log group: `_________________`

### Step 4: Add-ons (Tại thời điểm tạo cluster)
- [ ] **Core add-ons (thường tự động cài):**
  - [ ] VPC CNI
  - [ ] CoreDNS
  - [ ] kube-proxy
- [ ] **Essential add-ons:**
  - [ ] Amazon EBS CSI driver (nếu cần persistent volumes)
  - [ ] AWS Load Balancer Controller (nếu cần ALB/NLB)
  - [ ] Metrics Server (cho monitoring)
- [ ] **Optional add-ons:**
  - [ ] Amazon EFS CSI driver (nếu cần shared storage)
  - [ ] CloudWatch Agent (cho logging)
  - [ ] ADOT (cho observability)
  - [ ] Cluster Autoscaler hoặc Karpenter
  - [ ] Amazon GuardDuty EKS Protection
- [ ] **IAM roles cho add-ons:**
  - [ ] Đã chọn đúng IAM role cho từng add-on cần role

### Step 5: Review & Create
- [ ] Review lại tất cả cấu hình
- [ ] Click "Create cluster"
- [ ] Đợi cluster status chuyển sang "Active" (~10-15 phút)
- [ ] Ghi lại Cluster ARN: `_________________`

---

## 👥 Node Group Creation (Tạo Worker Nodes)

### Step 1: Configure Node Group
- [ ] Vào tab "Compute" → "Add node group"
- [ ] **Node group configuration:**
  - [ ] Name: `_________________`
  - [ ] Node IAM role: Chọn role đã tạo ở pre-requisites
  - [ ] AMI type: Amazon Linux 2 (Managed)
  - [ ] Capacity type: On-Demand / Spot
  - [ ] Instance types: `_________________` (ví dụ: t3.medium, m5.large)
  - [ ] Disk size: `_________________` GB (mặc định: 20)

### Step 2: Scaling Configuration
- [ ] Desired size: `_________________` nodes
- [ ] Minimum size: `_________________` nodes
- [ ] Maximum size: `_________________` nodes

### Step 3: Networking
- [ ] Subnets: Chọn subnet (khuyến nghị: private subnet)
- [ ] Remote access (SSH):
  - [ ] Enable/Disable SSH access
  - [ ] EC2 Key Pair (nếu enable): `_________________`
  - [ ] Source security group: `_________________`

### Step 4: Labels & Taints (Optional)
- [ ] Node labels: `_________________`
- [ ] Node taints: `_________________`

### Step 5: Review & Create
- [ ] Review lại cấu hình
- [ ] Click "Create node group"
- [ ] Đợi node group status chuyển sang "Active" (~5-10 phút)
- [ ] Verify nodes đã join cluster

---

## ✅ Post-Creation Setup (Sau khi tạo cluster)

### kubectl Configuration
- [ ] Cấu hình kubeconfig:
  aws eks --region <region> update-kubeconfig --name <cluster-name>
  - [ ] Verify kết nối:
  kubectl get nodes
  kubectl get pods -A
  ### Verify Core Components
- [ ] Check nodes status: `kubectl get nodes`
- [ ] Check system pods: `kubectl get pods -n kube-system`
- [ ] Check CoreDNS: `kubectl get pods -n kube-system | grep coredns`
- [ ] Check VPC CNI: `kubectl get pods -n kube-system | grep aws-node`
- [ ] Check kube-proxy: `kubectl get pods -n kube-system | grep kube-proxy`

### Verify Add-ons
- [ ] EBS CSI Driver: `kubectl get pods -n kube-system | grep ebs-csi`
- [ ] Load Balancer Controller: `kubectl get pods -n kube-system | grep aws-load-balancer`
- [ ] Metrics Server: `kubectl get pods -n kube-system | grep metrics-server`
- [ ] CloudWatch Agent: `kubectl get pods -n amazon-cloudwatch`
- [ ] Verify add-ons hoạt động đúng (check logs nếu cần)

### Network Testing
- [ ] Test DNS resolution: `kubectl run -it --rm test-dns --image=busybox -- nslookup kubernetes.default`
- [ ] Test pod-to-pod communication
- [ ] Test service discovery

### Security Hardening (Production)
- [ ] Enable Pod Security Standards hoặc Pod Security Policies
- [ ] Cấu hình Network Policies (nếu cần)
- [ ] Enable encryption at rest cho EBS volumes
- [ ] Review Security Groups rules
- [ ] Enable AWS WAF (nếu expose services ra Internet)
- [ ] Cấu hình IAM Roles for Service Accounts (IRSA) hoặc EKS Pod Identity cho workloads

### Monitoring & Logging
- [ ] Verify CloudWatch logs đang được gửi
- [ ] Cấu hình CloudWatch dashboards (nếu cần)
- [ ] Cài đặt Prometheus/Grafana (nếu cần)
- [ ] Cấu hình alerting rules

### Backup & Disaster Recovery
- [ ] Cấu hình Velero hoặc tool backup khác (nếu cần)
- [ ] Document cluster configuration
- [ ] Lưu trữ kubeconfig ở nơi an toàn
- [ ] Tạo runbook cho disaster recovery

---

## 📝 Documentation

- [ ] Ghi lại thông tin cluster:
  - [ ] Cluster name: `_________________`
  - [ ] Cluster ARN: `_________________`
  - [ ] Region: `_________________`
  - [ ] VPC ID: `_________________`
  - [ ] Subnet IDs: `_________________`
  - [ ] Security Group IDs: `_________________`
  - [ ] IAM Role ARNs: `_________________`
- [ ] Document node group configuration
- [ ] Document add-ons đã cài đặt
- [ ] Document network architecture
- [ ] Tạo diagram network topology (nếu cần)

---

## 🔧 Optional Enhancements

### GitOps Setup
- [ ] Cài đặt ArgoCD hoặc Flux
- [ ] Cấu hình Git repository cho manifests
- [ ] Setup CI/CD pipeline

### Service Mesh
- [ ] Cài đặt Istio/Linkerd/AWS App Mesh (nếu cần)

### Ingress Controller
- [ ] Cài đặt NGINX Ingress Controller hoặc AWS Load Balancer Controller
- [ ] Cấu hình SSL/TLS certificates

### Storage
- [ ] Cấu hình StorageClass cho EBS
- [ ] Cấu hình StorageClass cho EFS (nếu cần)
- [ ] Test PVC creation

### Autoscaling
- [ ] Cấu hình Horizontal Pod Autoscaler (HPA)
- [ ] Cấu hình Vertical Pod Autoscaler (VPA) (nếu cần)
- [ ] Verify Cluster Autoscaler hoặc Karpenter hoạt động

---

## 🧪 Testing Checklist

- [ ] Deploy test application:
  kubectl create deployment nginx --image=nginx
  kubectl expose deployment nginx --port=80 --type=LoadBalancer
  - [ ] Verify pod scheduling: `kubectl get pods -o wide`
- [ ] Test service connectivity
- [ ] Test persistent volume (nếu đã cài EBS CSI)
- [ ] Test load balancer (nếu đã cài Load Balancer Controller)
- [ ] Test logging (nếu đã cài CloudWatch Agent)
- [ ] Test metrics collection (nếu đã cài Metrics Server)

---

## 🚨 Troubleshooting Notes

- [ ] Document common issues và solutions
- [ ] Ghi lại commands hữu ích:h
  # Check cluster status
  aws eks describe-cluster --name <cluster-name>
  
  # Check node group status
  aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name>
  
  # Get cluster logs
  aws logs tail /aws/eks/<cluster-name>/cluster --follow
  ---

## ✅ Final Verification

- [ ] Tất cả nodes đang ở trạng thái "Ready"
- [ ] Tất cả system pods đang chạy
- [ ] Add-ons hoạt động đúng
- [ ] Network connectivity OK
- [ ] Security configurations đã được áp dụng
- [ ] Monitoring và logging đang hoạt động
- [ ] Documentation đã được cập nhật

---

## 📅 Maintenance Schedule

- [ ] Lên lịch update Kubernetes version (quarterly)
- [ ] Lên lịch update node AMI (monthly)
- [ ] Lên lịch review security groups và IAM policies (quarterly)
- [ ] Lên lịch review costs và optimize (monthly)

---

**Created:** `_________________`  
**Created by:** `_________________`  
**Last updated:** `_________________`