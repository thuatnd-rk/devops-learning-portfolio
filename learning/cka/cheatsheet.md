## Kubernetes (K8s) Cheatsheet

### Kubectl context
- Liệt kê context: `kubectl config get-contexts`
- Dùng context: `kubectl config use-context <ctx>`
- Đổi namespace mặc định: `kubectl config set-context --current --namespace <ns>`

### Namespace
- Liệt kê: `kubectl get ns`
- Tạo: `kubectl create ns <ns>`
- Xóa: `kubectl delete ns <ns>`

### Thông tin nhanh
- Tất cả tài nguyên: `kubectl get all -n <ns>`
- Mô tả tài nguyên: `kubectl describe <type>/<name> -n <ns>`
- Xuất YAML: `kubectl get <type>/<name> -n <ns> -o yaml`

### Pod
- Liệt kê: `kubectl get pods -n <ns> -o wide`
- Logs: `kubectl logs <pod> -n <ns> [-c <container>]`
- Theo dõi logs: `kubectl logs -f <pod> -n <ns>`
- Exec shell: `kubectl exec -it <pod> -n <ns> -- sh` (hoặc `-- bash`)
- Port-forward pod: `kubectl port-forward pod/<pod> 8080:80 -n <ns>`

### Deployment / ReplicaSet
- Liệt kê: `kubectl get deploy,rs -n <ns>`
- Tạo/áp dụng từ file: `kubectl apply -f deploy.yaml`
- Scale: `kubectl scale deploy/<name> --replicas=3 -n <ns>`
- Cập nhật image: `kubectl set image deploy/<name> <container>=<image>:<tag> -n <ns>`
- Rollout status: `kubectl rollout status deploy/<name> -n <ns>`
- Lịch sử: `kubectl rollout history deploy/<name> -n <ns>`
- Rollback: `kubectl rollout undo deploy/<name> [--to-revision=N] -n <ns>`

### Service / Endpoint / Ingress
- Liệt kê: `kubectl get svc,ep,ing -n <ns>`
- Port-forward Service: `kubectl port-forward svc/<svc> 8080:80 -n <ns>`
- Kiểm tra Ingress: `kubectl describe ing/<name> -n <ns>`

### ConfigMap / Secret
- Tạo ConfigMap từ file: `kubectl create configmap <name> --from-file=path=./file`
- Tạo ConfigMap từ literal: `kubectl create configmap <name> --from-literal=KEY=VALUE`
- Secret từ literal: `kubectl create secret generic <name> --from-literal=KEY=VALUE`
- Secret từ file: `kubectl create secret generic <name> --from-file=path=./file`
- Xem (decode) key: `kubectl get secret <name> -n <ns> -o jsonpath='{.data.KEY}' | base64 -d`

### Jobs / CronJobs
- Tạo Job: `kubectl create job <name> --image=<image> -- <cmd>`
- Tạo CronJob: `kubectl create cronjob <name> --image=<image> --schedule="*/5 * * * *" -- <cmd>`
- Liệt kê: `kubectl get jobs,cronjobs -n <ns>`

### Node / Cluster
- Nodes: `kubectl get nodes -o wide`
- Resource sử dụng node: `kubectl top node`
- Sự kiện toàn cụm: `kubectl get events -A --sort-by=.lastTimestamp`

### Labels / Selectors / Annotations
- Thêm label: `kubectl label <type>/<name> env=prod -n <ns>`
- Sửa label: `kubectl label <type>/<name> env=prod --overwrite -n <ns>`
- Chọn theo label: `kubectl get pods -l app=myapp -n <ns>`
- Annotation: `kubectl annotate <type>/<name> key=value --overwrite -n <ns>`

### Taints / Tolerations / Affinity
- Xem taints: `kubectl describe node <node> | grep -i taints -A1`
- Thêm taint: `kubectl taint nodes <node> key=value:NoSchedule`
- Xóa taint: `kubectl taint nodes <node> key-`

### Resource requests/limits (snippet)
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

### Health probes (snippet)
```yaml
livenessProbe:
  httpGet: { path: /healthz, port: 8080 }
  initialDelaySeconds: 10
  periodSeconds: 10
readinessProbe:
  httpGet: { path: /ready, port: 8080 }
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Storage
- Xem PV/PVC: `kubectl get pv,pvc -n <ns>`
- Mẫu PVC:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata: { name: data-pvc }
spec:
  accessModes: [ ReadWriteOnce ]
  resources: { requests: { storage: 10Gi } }
  storageClassName: standard
```

### Networking
- DNS nội bộ: `<service>.<namespace>.svc.cluster.local`
- Kiểm tra DNS: `kubectl run -it dnsutils --image=busybox:1.36 --restart=Never -- nslookup <svc>`
- NetworkPolicy (allow intra-namespace):
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: { name: allow-same-ns }
spec:
  podSelector: {}
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector: {}
```

### Debug nhanh
- Pod debug ephemeral (1.22+): `kubectl debug pod/<pod> -it --image=nicolaka/netshoot -n <ns>`
- Pod tạm: `kubectl run tmp --rm -it --image=busybox:1.36 -- sh -n <ns>`
- Sự kiện: `kubectl get events -n <ns> --sort-by=.lastTimestamp`
- Mô tả pod: `kubectl describe pod/<pod> -n <ns>`

### Apply / Kustomize
- Apply thư mục kustomize: `kubectl apply -k ./overlays/prod`
- Dry-run: `kubectl apply -f file.yaml --server-side --dry-run=client -o yaml`
- Xem diff: `kubectl diff -f file.yaml`

### RBAC nhanh
```yaml
apiVersion: v1
kind: ServiceAccount
metadata: { name: reader, namespace: demo }
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: { name: reader, namespace: demo }
rules:
  - apiGroups: [""]
    resources: ["pods","services"]
    verbs: ["get","list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata: { name: reader-binding, namespace: demo }
subjects:
  - kind: ServiceAccount
    name: reader
roleRef:
  kind: Role
  name: reader
  apiGroup: rbac.authorization.k8s.io
```

### Helm cơ bản
#### Repository
- Thêm repo: `helm repo add bitnami https://charts.bitnami.com/bitnami`
- Liệt kê repos: `helm repo list`
- Cập nhật repo: `helm repo update`
- Xóa repo: `helm repo remove <repo-name>`
- Tìm kiếm chart: `helm search repo <keyword>`

#### Cài đặt & Quản lý Release
- Cài đặt: `helm install <release> <chart> -n <ns>`
- Cài đặt với values file: `helm install <release> <chart> -n <ns> -f values.yaml`
- Upgrade/Install (idempotent): `helm upgrade --install <release> <chart> -n <ns> -f values.yaml`
- Upgrade release: `helm upgrade <release> <chart> -n <ns> -f values.yaml`
- Liệt kê releases: `helm list -n <ns>` hoặc `helm ls -n <ns>`
- Xem tất cả releases (kể cả failed): `helm list -a -n <ns>`
- Xem trạng thái release: `helm status <release> -n <ns>`
- Xem lịch sử release: `helm history <release> -n <ns>`
- Rollback release: `helm rollback <release> [revision] -n <ns>`
- Xóa release: `helm uninstall <release> -n <ns>`

#### Xem thông tin Chart
- Xem values mặc định: `helm show values <chart>`
- Xem chart info: `helm show chart <chart>`
- Xem tất cả thông tin: `helm show all <chart>`
- Template chart (dry-run): `helm template <release> <chart> -n <ns> -f values.yaml`
- Template với debug: `helm template <release> <chart> -n <ns> -f values.yaml --debug`

#### Kiểm tra & Package
- Lint chart: `helm lint <chart-path>`
- Package chart: `helm package <chart-path>`
- Test release: `helm test <release> -n <ns>`

#### One-liners hữu ích
- Cài đặt với nhiều values files: `helm install <release> <chart> -f values.yaml -f values-prod.yaml -n <ns>`
- Cài đặt với set values: `helm install <release> <chart> --set key=value --set key2=value2 -n <ns>`
- Xem manifest đã deploy: `helm get manifest <release> -n <ns>`
- Xem values đã dùng: `helm get values <release> -n <ns>`
- Xem notes: `helm get notes <release> -n <ns>`

### Autoscaling
- Tạo HPA: `kubectl autoscale deploy/<name> --min=2 --max=10 --cpu-percent=80 -n <ns>`
- Xem HPA: `kubectl get hpa -n <ns>`

### Thay đổi nhanh bằng kubectl
- Sửa YAML trực tiếp: `kubectl edit <type>/<name> -n <ns>`
- Patch JSON: `kubectl patch deploy <name> -p '{"spec":{"replicas":3}}' -n <ns>`
- Set env: `kubectl set env deploy/<name> KEY=VALUE -n <ns>`

### One-liners hữu ích
- Pod không chạy: `kubectl get pods -n <ns> | grep -vE 'Running|Completed'`
- Pod theo node: `kubectl get pods -o wide --sort-by=.spec.nodeName -n <ns>`
- Top pod: `kubectl top pod -n <ns>`
- Di chuyển pod: `kubectl drain <node> --ignore-daemonsets --delete-emptydir-data`
- Hủy drain: `kubectl uncordon <node>`

### Templates nhanh
- Tạo deploy + svc nhanh:
  - `kubectl create deploy web --image=nginx:1.27 --dry-run=client -o yaml > deploy.yaml`
  - `kubectl expose deploy web --port=80 --target-port=80 --type=ClusterIP --dry-run=client -o yaml > svc.yaml`

### Best practices tóm tắt
- Dùng `readinessProbe` và `livenessProbe`
- Thiết lập `resources.requests/limits`
- Dùng tag version hoặc digest bất biến cho image
- Cấu hình qua `ConfigMap`/`Secret`, tránh hardcode
- Thiết lập `ResourceQuota` và `LimitRange` theo namespace
- Ghi log ra stdout/stderr; thiết kế stateless khi có thể

### EKS Provisioning (AWS CLI)
#### Cluster
- Liệt kê clusters: `aws eks list-clusters --region <region>`
- Mô tả cluster: `aws eks describe-cluster --name <cluster-name> --region <region>`
- Tạo cluster:
  ```bash
  aws eks create-cluster \
    --name <cluster-name> \
    --version 1.28 \
    --role-arn <cluster-role-arn> \
    --resources-vpc-config subnetIds=<subnet-1>,<subnet-2>,securityGroupIds=<sg-id> \
    --region <region>
  ```
- Xóa cluster: `aws eks delete-cluster --name <cluster-name> --region <region>`
- Cập nhật kubeconfig: `aws eks update-kubeconfig --name <cluster-name> --region <region>`
- Cập nhật kubeconfig với profile: `aws eks update-kubeconfig --name <cluster-name> --region <region> --profile <profile>`

#### Node Group
- Liệt kê node groups: `aws eks list-nodegroups --cluster-name <cluster-name> --region <region>`
- Mô tả node group: `aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name> --region <region>`
- Tạo managed node group:
  ```bash
  aws eks create-nodegroup \
    --cluster-name <cluster-name> \
    --nodegroup-name <nodegroup-name> \
    --node-role <node-role-arn> \
    --subnets <subnet-1> <subnet-2> \
    --instance-types t3.medium \
    --ami-type AL2_x86_64 \
    --capacity-type ON_DEMAND \
    --scaling-config minSize=1,maxSize=3,desiredSize=2 \
    --region <region>
  ```
- Cập nhật node group (scale): `aws eks update-nodegroup-config --cluster-name <cluster-name> --nodegroup-name <nodegroup-name> --scaling-config minSize=2,maxSize=5,desiredSize=3 --region <region>`
- Cập nhật version: `aws eks update-nodegroup-version --cluster-name <cluster-name> --nodegroup-name <nodegroup-name> --region <region>`
- Xóa node group: `aws eks delete-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name> --region <region>`

#### Fargate Profile
- Liệt kê Fargate profiles: `aws eks list-fargate-profiles --cluster-name <cluster-name> --region <region>`
- Tạo Fargate profile:
  ```bash
  aws eks create-fargate-profile \
    --cluster-name <cluster-name> \
    --fargate-profile-name <profile-name> \
    --pod-execution-role-arn <execution-role-arn> \
    --subnets <subnet-1> <subnet-2> \
    --selectors namespace=default,labels={fargate=enabled} \
    --region <region>
  ```
- Xóa Fargate profile: `aws eks delete-fargate-profile --cluster-name <cluster-name> --fargate-profile-name <profile-name> --region <region>`

#### Add-ons
- Liệt kê add-ons: `aws eks list-addons --cluster-name <cluster-name> --region <region>`
- Cài đặt add-on (VD: VPC CNI): `aws eks create-addon --cluster-name <cluster-name> --addon-name vpc-cni --region <region>`
- Cập nhật add-on: `aws eks update-addon --cluster-name <cluster-name> --addon-name vpc-cni --region <region>`
- Xóa add-on: `aws eks delete-addon --cluster-name <cluster-name> --addon-name vpc-cni --region <region>`

#### IAM Roles & Policies
- Tạo IAM role cho cluster:
  ```bash
  aws iam create-role \
    --role-name eks-cluster-role \
    --assume-role-policy-document file://cluster-trust-policy.json
  ```
- Gắn policy: `aws iam attach-role-policy --role-name eks-cluster-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy`
- Tạo IAM role cho node group:
  ```bash
  aws iam create-role \
    --role-name eks-nodegroup-role \
    --assume-role-policy-document file://node-trust-policy.json
  ```
- Gắn policies cho node: 
  - `aws iam attach-role-policy --role-name eks-nodegroup-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy`
  - `aws iam attach-role-policy --role-name eks-nodegroup-role --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy`
  - `aws iam attach-role-policy --role-name eks-nodegroup-role --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly`

#### Kiểm tra trạng thái
- Trạng thái cluster: `aws eks describe-cluster --name <cluster-name> --region <region> --query 'cluster.status'`
- Logs CloudWatch: `aws logs tail /aws/eks/<cluster-name>/cluster --follow --region <region>`
- Kiểm tra node group health: `aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name> --region <region> --query 'nodegroup.health'`

#### One-liners hữu ích
- Xem tất cả clusters: `aws eks list-clusters --region <region> --output table`
- Xem tất cả node groups: `aws eks list-nodegroups --cluster-name <cluster-name> --region <region> --output table`
- Lấy endpoint: `aws eks describe-cluster --name <cluster-name> --region <region> --query 'cluster.endpoint' --output text`
- Lấy CA certificate: `aws eks describe-cluster --name <cluster-name> --region <region> --query 'cluster.certificateAuthority.data' --output text | base64 -d`
- Xem version: `aws eks describe-cluster --name <cluster-name> --region <region> --query 'cluster.version' --output text`


