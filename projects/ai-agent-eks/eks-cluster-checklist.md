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

## 🏗️ Node Group Strategy (Chiến lược Node Groups theo Layer)

### Tổng quan
- [ ] Quyết định số lượng node groups cần thiết
- [ ] Xác định các layer workloads:
  - [ ] System/Infrastructure layer
  - [ ] Application layer
  - [ ] Data layer
  - [ ] AI/ML layer
  - [ ] Batch/Jobs layer (nếu cần)

### Node Group 1: System/Infrastructure Layer
- [ ] **Mục đích:** System pods (CoreDNS, Metrics Server, VPC CNI, kube-proxy)
- [ ] **Configuration:**
  - [ ] Name: `system-nodegroup` hoặc `infra-nodegroup`
  - [ ] Instance type: `t3.small`, `t3.medium`
  - [ ] Capacity type: On-Demand
  - [ ] Scaling: 2-3 nodes (fixed)
  - [ ] Disk size: 20 GiB
- [ ] **Labels:**
  - [ ] `node-role=system`
  - [ ] `workload-type=system`
  - [ ] `tier=infrastructure`
- [ ] **Taints:** (None hoặc taint nhẹ)
- [ ] **Subnets:** Chọn 2+ subnet ở 2+ AZ
- [ ] **Update strategy:** Default, Max unavailable: 1 node

### Node Group 2: Application Layer
- [ ] **Mục đích:** Web apps, APIs, microservices (stateless)
- [ ] **Configuration:**
  - [ ] Name: `app-nodegroup` hoặc `application-nodegroup`
  - [ ] Instance type: `t3.large`, `m5.large`, `m5.xlarge` (chọn nhiều types)
  - [ ] Capacity type: Mixed (On-Demand baseline + Spot scale-out)
  - [ ] **On-Demand Node Group:**
    - [ ] Name: `app-nodegroup-ondemand`
    - [ ] Scaling: 2-5 nodes (baseline)
  - [ ] **Spot Node Group:**
    - [ ] Name: `app-nodegroup-spot`
    - [ ] Scaling: 0-20 nodes (scale-out)
  - [ ] Disk size: 20-50 GiB
- [ ] **Labels:**
  - [ ] `node-role=application`
  - [ ] `workload-type=application`
  - [ ] `tier=web` hoặc `tier=api`
  - [ ] `capacity-type=ondemand` (cho On-Demand group)
  - [ ] `capacity-type=spot` (cho Spot group)
- [ ] **Taints:** (None)
- [ ] **Subnets:** Chọn 2+ subnet ở 2+ AZ
- [ ] **Update strategy:** Default, Max unavailable: 1 node hoặc 10-20%

### Node Group 3: Data Layer
- [ ] **Mục đích:** Databases, StatefulSets, persistent workloads
- [ ] **Configuration:**
  - [ ] Name: `data-nodegroup` hoặc `database-nodegroup`
  - [ ] Instance type: `m5.xlarge`, `r5.xlarge`, `i3.xlarge` (nếu cần NVMe)
  - [ ] Capacity type: On-Demand only (không dùng Spot)
  - [ ] Scaling: 3-5 nodes (fixed, quorum)
  - [ ] Disk size: 50-100 GiB (hoặc lớn hơn tùy workload)
- [ ] **Labels:**
  - [ ] `node-role=data`
  - [ ] `workload-type=database`
  - [ ] `tier=data`
  - [ ] `capacity-type=ondemand`
- [ ] **Taints:**
  - [ ] `workload-type=database:NoSchedule` (bảo vệ nodes)
- [ ] **Subnets:** Chọn 2+ subnet ở 2+ AZ (quan trọng cho HA)
- [ ] **Update strategy:** Minimal, Max unavailable: 1 node
- [ ] **Lưu ý:** Đảm bảo có quorum (3 nodes cho quorum, 5 nodes cho better HA)

### Node Group 4: AI/ML Layer
- [ ] **Mục đích:** Training jobs, inference, GPU workloads
- [ ] **Configuration:**
  - [ ] Name: `ai-nodegroup` hoặc `ml-nodegroup`
  - [ ] Instance type: `g4dn.xlarge`, `p3.2xlarge`, `p4d.24xlarge` (GPU instances)
  - [ ] Capacity type: Spot instances (cost optimization)
  - [ ] Scaling: 0-20 nodes (auto-scaling, có thể scale về 0)
  - [ ] Disk size: 50-100 GiB (hoặc lớn hơn cho datasets)
- [ ] **Labels:**
  - [ ] `node-role=ai`
  - [ ] `workload-type=ml`
  - [ ] `accelerator=gpu`
  - [ ] `capacity-type=spot`
- [ ] **Taints:**
  - [ ] `workload-type=ml:NoSchedule` (chỉ ML workloads)
  - [ ] `accelerator=gpu:NoSchedule` (nếu cần)
- [ ] **Subnets:** Chọn 2+ subnet ở 2+ AZ
- [ ] **Update strategy:** Default, Max unavailable: 1 node
- [ ] **Lưu ý:** 
  - [ ] Chọn nhiều GPU instance types để tăng Spot availability
  - [ ] Có thể cần On-Demand fallback node group cho critical ML workloads

### Node Group 5: Batch/Jobs Layer (Optional)
- [ ] **Mục đích:** Cron jobs, batch processing, one-off tasks
- [ ] **Configuration:**
  - [ ] Name: `batch-nodegroup` hoặc `jobs-nodegroup`
  - [ ] Instance type: `t3.medium`, `m5.large`
  - [ ] Capacity type: Spot instances
  - [ ] Scaling: 0-50 nodes (auto-scaling, có thể scale về 0)
  - [ ] Disk size: 20-50 GiB
- [ ] **Labels:**
  - [ ] `node-role=batch`
  - [ ] `workload-type=batch`
  - [ ] `tier=batch`
  - [ ] `capacity-type=spot`
- [ ] **Taints:**
  - [ ] `workload-type=batch:NoSchedule` (tránh long-running pods)
- [ ] **Subnets:** Chọn 2+ subnet ở 2+ AZ
- [ ] **Update strategy:** Default, Max unavailable: 20-30%

---

## 📋 Node Group Configuration Examples

### Example 1: Application Layer (On-Demand + Spot)

#### On-Demand Node Group
```yaml
Name: app-nodegroup-ondemand
IAM Role: eks-nodegroup-role
AMI: Amazon Linux 2023
Capacity Type: On-Demand
Instance Types: t3.large, m5.large
Disk Size: 20 GiB
Scaling:
  Desired: 2
  Min: 2
  Max: 5
Subnets: subnet-app-1a, subnet-app-1b
Labels:
  node-role: application
  workload-type: application
  tier: web
  capacity-type: ondemand
Taints: (None)
Update Strategy: Default
Max Unavailable: 1 node
```

#### Spot Node Group
```yaml
Name: app-nodegroup-spot
IAM Role: eks-nodegroup-role
AMI: Amazon Linux 2023
Capacity Type: Spot
Instance Types: t3.medium, t3.large, m5.large, m5.xlarge
Disk Size: 20 GiB
Scaling:
  Desired: 0
  Min: 0
  Max: 20
Subnets: subnet-app-1a, subnet-app-1b
Labels:
  node-role: application
  workload-type: application
  tier: web
  capacity-type: spot
Taints: (None hoặc capacity-type=spot:PreferNoSchedule)
Update Strategy: Default
Max Unavailable: 20%
```

### Example 2: Data Layer (On-Demand Only)

```yaml
Name: data-nodegroup
IAM Role: eks-nodegroup-role
AMI: Amazon Linux 2023
Capacity Type: On-Demand
Instance Types: r5.xlarge, m5.xlarge
Disk Size: 100 GiB
Scaling:
  Desired: 3
  Min: 3
  Max: 5
Subnets: subnet-data-1a, subnet-data-1b
Labels:
  node-role: data
  workload-type: database
  tier: data
  capacity-type: ondemand
Taints:
  - key: workload-type
    value: database
    effect: NoSchedule
Update Strategy: Minimal
Max Unavailable: 1 node
```

### Example 3: AI/ML Layer (Spot Instances)

```yaml
Name: ml-nodegroup
IAM Role: eks-nodegroup-role
AMI: Amazon Linux 2023 (GPU optimized)
Capacity Type: Spot
Instance Types: g4dn.xlarge, g4dn.2xlarge, p3.2xlarge
Disk Size: 100 GiB
Scaling:
  Desired: 0
  Min: 0
  Max: 20
Subnets: subnet-ml-1a, subnet-ml-1b
Labels:
  node-role: ai
  workload-type: ml
  accelerator: gpu
  capacity-type: spot
Taints:
  - key: workload-type
    value: ml
    effect: NoSchedule
  - key: accelerator
    value: gpu
    effect: NoSchedule
Update Strategy: Default
Max Unavailable: 1 node
```

---

## 🎯 Pod Configuration Examples cho từng Layer

### Application Layer Pods

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 5
  template:
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          # Ưu tiên On-Demand cho baseline
          - weight: 100
            preference:
              matchExpressions:
              - key: capacity-type
                operator: In
                values: ["ondemand"]
          # Fallback sang Spot khi scale
          - weight: 50
            preference:
              matchExpressions:
              - key: capacity-type
                operator: In
                values: ["spot"]
      tolerations:
      - key: capacity-type
        operator: Equal
        value: spot
        effect: PreferNoSchedule
      containers:
      - name: app
        image: nginx
```

### Data Layer Pods

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  replicas: 3
  template:
    spec:
      nodeSelector:
        workload-type: database
      tolerations:
      - key: workload-type
        operator: Equal
        value: database
        effect: NoSchedule
      containers:
      - name: postgres
        image: postgres:14
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: gp3
      resources:
        requests:
          storage: 100Gi
```

### AI/ML Layer Pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: training-job
spec:
  nodeSelector:
    accelerator: gpu
  tolerations:
  - key: workload-type
    operator: Equal
    value: ml
    effect: NoSchedule
  - key: accelerator
    operator: Equal
    value: gpu
    effect: NoSchedule
  containers:
  - name: trainer
    image: pytorch/pytorch:latest
    resources:
      limits:
        nvidia.com/gpu: 1
      requests:
        nvidia.com/gpu: 1
```

---

## ✅ Verification Checklist cho Multi-Layer Setup

### Verify Node Distribution
- [ ] Check nodes phân bổ đúng AZ: `kubectl get nodes -o wide`
- [ ] Verify node labels: `kubectl get nodes --show-labels`
- [ ] Check node taints: `kubectl describe nodes | grep Taints`

### Verify Pod Scheduling
- [ ] Application pods schedule đúng node group: `kubectl get pods -o wide`
- [ ] Database pods chỉ schedule lên data nodes
- [ ] ML pods chỉ schedule lên AI nodes
- [ ] Verify pod distribution across AZs

### Verify Scaling
- [ ] Test scale application pods → Spot nodes được tạo
- [ ] Test scale database pods → Không tạo Spot nodes
- [ ] Test scale ML jobs → GPU Spot nodes được tạo
- [ ] Verify Cluster Autoscaler hoặc Karpenter hoạt động đúng

### Verify Isolation
- [ ] Application pods không schedule lên data nodes
- [ ] Non-ML pods không schedule lên AI nodes
- [ ] Verify taints và tolerations hoạt động đúng

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