# 10. Helm

## Tổng quan
Helm là package manager cho Kubernetes, giúp đơn giản hóa việc deploy và quản lý applications trên Kubernetes cluster.

## Nội dung chính

### 1. Helm Architecture
- **Helm Client:** Command-line tool để tương tác với Helm
- **Helm Charts:** Package chứa Kubernetes resources
- **Tiller (Helm 2):** Server-side component (đã deprecated)
- **Helm 3:** Không cần Tiller, sử dụng Kubernetes API trực tiếp

**Helm Components:**
- **Chart:** Package chứa tất cả resource definitions
- **Release:** Instance của chart đang chạy trên cluster
- **Repository:** Nơi lưu trữ và chia sẻ charts

### 2. Helm Charts
- **Chart Structure:** Tổ chức files và directories
- **Chart.yaml:** Metadata của chart
- **values.yaml:** Default configuration values
- **templates/:** Kubernetes manifest templates

**Chart Structure:**
```
my-chart/
├── Chart.yaml
├── values.yaml
├── charts/
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── README.md
```

**Chart.yaml:**
```yaml
apiVersion: v2
name: my-application
description: A Helm chart for my application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

**values.yaml:**
```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: ""

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

resources: {}
nodeSelector: {}
tolerations: []
affinity: {}
```

### 3. Helm Templates
- **Template Engine:** Go template syntax
- **Variables:** Sử dụng values từ values.yaml
- **Functions:** Built-in functions cho template processing

**Template Variables:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-chart.fullname" . }}
  labels:
    {{- include "my-chart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

**Template Functions:**
```yaml
# Include template
{{ include "my-chart.fullname" . }}

# Default value
{{ .Values.image.tag | default "latest" }}

# Required value
{{ required "A valid image.repository is required" .Values.image.repository }}

# Quote string
{{ .Values.image.repository | quote }}

# Indent
{{- include "my-chart.labels" . | nindent 4 }}
```

### 4. Helm Commands
- **Install:** Deploy chart lên cluster
- **Upgrade:** Update existing release
- **Uninstall:** Remove release từ cluster
- **List:** Xem tất cả releases
- **Status:** Check release status

**Basic Commands:**
```bash
# Install chart
helm install my-release ./my-chart

# Install với custom values
helm install my-release ./my-chart --values custom-values.yaml

# Install với set values
helm install my-release ./my-chart --set replicaCount=3

# Upgrade release
helm upgrade my-release ./my-chart

# Uninstall release
helm uninstall my-release

# List releases
helm list

# Check release status
helm status my-release

# Get release values
helm get values my-release

# Get release manifest
helm get manifest my-release
```

**Repository Commands:**
```bash
# Add repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# List repositories
helm repo list

# Search charts
helm search repo nginx

# Install from repository
helm install my-nginx bitnami/nginx
```

### 5. Helm Values
- **Default Values:** values.yaml trong chart
- **Custom Values:** Override default values
- **Set Values:** Override individual values
- **Value Files:** External value files

**Custom Values File:**
```yaml
# custom-values.yaml
replicaCount: 3

image:
  repository: my-registry/nginx
  tag: "1.19"

service:
  type: LoadBalancer
  port: 80

ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
```

**Set Values:**
```bash
# Set single value
helm install my-release ./my-chart --set replicaCount=3

# Set nested value
helm install my-release ./my-chart --set image.repository=my-registry/nginx

# Set multiple values
helm install my-release ./my-chart \
  --set replicaCount=3 \
  --set image.repository=my-registry/nginx \
  --set service.type=LoadBalancer

# Set array values
helm install my-release ./my-chart \
  --set ingress.hosts[0].host=myapp.example.com
```

### 6. Helm Hooks
- **Pre-install:** Chạy trước khi install
- **Post-install:** Chạy sau khi install
- **Pre-upgrade:** Chạy trước khi upgrade
- **Post-upgrade:** Chạy sau khi upgrade
- **Pre-delete:** Chạy trước khi delete
- **Post-delete:** Chạy sau khi delete

**Hook Example:**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{.Release.Name}}-pre-install-job"
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      containers:
      - name: pre-install-job
        image: busybox
        command: ['sh', '-c', 'echo "Pre-install hook running"']
      restartPolicy: Never
  backoffLimit: 3
```

### 7. Helm Testing
- **Test Hooks:** Kiểm tra release functionality
- **Test Commands:** Chạy test pods
- **Test Results:** Verify test success

**Test Job:**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{.Release.Name}}-test"
  annotations:
    "helm.sh/hook": test
spec:
  template:
    spec:
      containers:
      - name: test
        image: busybox
        command: ['sh', '-c', 'wget -qO- http://{{.Release.Name}}-service:80']
      restartPolicy: Never
  backoffLimit: 0
```

**Run Tests:**
```bash
# Run tests
helm test my-release

# Delete test pods
helm test --cleanup my-release
```

### 8. Helm Plugins
- **Plugin System:** Extend Helm functionality
- **Popular Plugins:** diff, secrets, push
- **Custom Plugins:** Tạo plugin riêng

**Install Plugins:**
```bash
# Install diff plugin
helm plugin install https://github.com/databus23/helm-diff

# Install secrets plugin
helm plugin install https://github.com/jkroepke/helm-secrets

# List plugins
helm plugin list
```

**Use Plugins:**
```bash
# Diff changes
helm diff upgrade my-release ./my-chart

# Use secrets
helm secrets install my-release ./my-chart -f secrets.yaml
```

### 9. Helm Best Practices
- **Chart Structure:** Tổ chức chart đúng cách
- **Values Management:** Quản lý values hiệu quả
- **Security:** Secure sensitive data
- **Documentation:** Viết documentation đầy đủ

**Chart Structure Best Practices:**
```
my-chart/
├── Chart.yaml
├── values.yaml
├── values-production.yaml
├── values-staging.yaml
├── charts/
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   └── tests/
│       └── test-connection.yaml
├── .helmignore
└── README.md
```

**Security Best Practices:**
```yaml
# Use secrets cho sensitive data
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "my-chart.fullname" . }}-secret
type: Opaque
data:
  password: {{ .Values.database.password | b64enc }}
  api-key: {{ .Values.api.key | b64enc }}
```

### 10. Troubleshooting Helm
- **Install Issues:** Problems với chart installation
- **Template Issues:** Template syntax errors
- **Value Issues:** Problems với values
- **Release Issues:** Release management problems

**Troubleshoot Commands:**
```bash
# Validate chart
helm lint ./my-chart

# Dry run install
helm install my-release ./my-chart --dry-run

# Debug template rendering
helm template my-release ./my-chart

# Check release history
helm history my-release

# Rollback release
helm rollback my-release 1

# Get release notes
helm get notes my-release
```

**Common Issues:**
```bash
# Fix template syntax
helm lint ./my-chart

# Check values
helm get values my-release

# Debug template
helm template my-release ./my-chart --debug

# Check release status
helm status my-release
```

## Lưu ý quan trọng cho CKA
1. **Chart Structure:** Hiểu cấu trúc chart và tổ chức files
2. **Templates:** Sử dụng Go template syntax và functions
3. **Values:** Quản lý values và override mechanisms
4. **Commands:** Sử dụng Helm commands để manage releases
5. **Hooks:** Implement pre/post hooks cho automation
6. **Testing:** Tạo và chạy test jobs
7. **Security:** Secure sensitive data với secrets
8. **Troubleshooting:** Debug và fix common issues

## Practice Commands
```bash
# Create new chart
helm create my-chart

# Install chart
helm install my-release ./my-chart

# Upgrade chart
helm upgrade my-release ./my-chart

# Uninstall chart
helm uninstall my-release

# List releases
helm list

# Get release status
helm status my-release

# Validate chart
helm lint ./my-chart

# Template chart
helm template my-release ./my-chart

# Test release
helm test my-release

# Rollback release
helm rollback my-release 1
``` 