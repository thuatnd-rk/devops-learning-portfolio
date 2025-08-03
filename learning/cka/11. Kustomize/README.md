# 11. Kustomize

## Tổng quan
Kustomize là native Kubernetes configuration management tool, cho phép customize Kubernetes manifests mà không cần template engine. Kustomize sử dụng overlay pattern để quản lý multiple environments.

## Nội dung chính

### 1. Kustomize Architecture
- **Base:** Base configuration với common resources
- **Overlay:** Environment-specific customizations
- **Patches:** Modifications cho base resources
- **Resources:** Kubernetes manifests

**Kustomize Structure:**
```
my-app/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── overlays/
    ├── development/
    │   ├── kustomization.yaml
    │   └── patches/
    ├── staging/
    │   ├── kustomization.yaml
    │   └── patches/
    └── production/
        ├── kustomization.yaml
        └── patches/
```

### 2. Base Configuration
- **Base Directory:** Chứa common resources
- **kustomization.yaml:** Base configuration file
- **Resources:** Kubernetes manifests

**Base kustomization.yaml:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- configmap.yaml

commonLabels:
  app: my-app
  version: v1.0.0

commonAnnotations:
  owner: devops-team
```

**Base deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:latest
        ports:
        - containerPort: 80
```

### 3. Overlays
- **Overlay Structure:** Environment-specific configurations
- **Patches:** Modifications cho base resources
- **Resources:** Additional resources cho environment

**Development Overlay:**
```yaml
# overlays/development/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../base

namespace: development

patches:
- path: patches/deployment.yaml
  target:
    kind: Deployment
    name: my-app

configMapGenerator:
- name: my-app-config
  literals:
  - ENVIRONMENT=development
  - LOG_LEVEL=debug

images:
- name: nginx
  newTag: 1.19
```

**Development Patch:**
```yaml
# overlays/development/patches/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: my-app
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### 4. Kustomize Commands
- **Build:** Generate final manifests
- **Edit:** Interactive editing
- **Diff:** Compare configurations
- **Apply:** Apply configurations

**Basic Commands:**
```bash
# Build configuration
kustomize build overlays/development

# Build và apply
kubectl apply -k overlays/development

# Build với output file
kustomize build overlays/development -o manifests.yaml

# Diff configurations
kustomize build overlays/development | kubectl diff -f -

# Edit configuration
kustomize edit add resource deployment.yaml
kustomize edit set image nginx=nginx:1.19
kustomize edit add label app=my-app
```

**Advanced Commands:**
```bash
# Build với multiple overlays
kustomize build overlays/development overlays/staging

# Build với validation
kustomize build overlays/development | kubectl apply --dry-run=client -f -

# Build với custom plugins
kustomize build --enable-alpha-plugins overlays/development

# Build với load restrictions
kustomize build --load-restrictor LoadRestrictionsNone overlays/development
```

### 5. Kustomize Features
- **Common Labels:** Apply labels to all resources
- **Common Annotations:** Apply annotations to all resources
- **Name Prefix/Suffix:** Modify resource names
- **Namespace:** Set namespace for all resources
- **Images:** Replace container images

**Common Labels và Annotations:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml

commonLabels:
  app: my-app
  environment: production
  team: backend

commonAnnotations:
  owner: devops-team
  cost-center: engineering
  backup: "true"
```

**Name Prefix/Suffix:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml

namePrefix: prod-
nameSuffix: -v2

namespace: production
```

**Image Replacement:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

images:
- name: nginx
  newName: my-registry/nginx
  newTag: 1.19.0
- name: redis
  newName: my-registry/redis
  newTag: 6.0.0
```

### 6. Patches
- **Strategic Merge Patches:** JSON patches
- **JSON Patches:** RFC 6902 JSON patches
- **Patches with Targets:** Target specific resources

**Strategic Merge Patch:**
```yaml
# patches/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: my-app
        resources:
          requests:
            memory: "128Mi"
            cpu: "500m"
          limits:
            memory: "256Mi"
            cpu: "1000m"
```

**JSON Patch:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

patches:
- target:
    kind: Deployment
    name: my-app
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
    - op: add
      path: /spec/template/spec/containers/0/env
      value:
      - name: ENVIRONMENT
        value: production
```

**Patches with Targets:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml

patches:
- path: patches/deployment-replicas.yaml
  target:
    kind: Deployment
    name: my-app
- path: patches/service-type.yaml
  target:
    kind: Service
    name: my-app
```

### 7. ConfigMap và Secret Generators
- **ConfigMapGenerator:** Generate ConfigMaps từ files/literals
- **SecretGenerator:** Generate Secrets từ files/literals
- **Behavior:** Create, replace, merge

**ConfigMap Generator:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

configMapGenerator:
- name: my-app-config
  literals:
  - ENVIRONMENT=production
  - LOG_LEVEL=info
  - API_URL=https://api.example.com
  files:
  - config/app.properties
  - config/database.properties
```

**Secret Generator:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

secretGenerator:
- name: my-app-secret
  literals:
  - DB_PASSWORD=secret123
  - API_KEY=abc123
  files:
  - secrets/database.key
  - secrets/api.crt
```

**Generator Behavior:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

configMapGenerator:
- name: my-app-config
  behavior: merge  # create, replace, merge
  literals:
  - ENVIRONMENT=production
```

### 8. Variables và References
- **Variables:** Define variables trong kustomization
- **References:** Reference variables trong resources
- **Substitution:** Variable substitution

**Variables:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

vars:
- name: APP_NAME
  objref:
    kind: Deployment
    name: my-app
    apiVersion: apps/v1
  fieldref:
    fieldpath: metadata.name
- name: APP_NAMESPACE
  objref:
    kind: Deployment
    name: my-app
    apiVersion: apps/v1
  fieldref:
    fieldpath: metadata.namespace
```

**Variable Usage:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: $(APP_NAME)-service
  namespace: $(APP_NAMESPACE)
spec:
  selector:
    app: $(APP_NAME)
  ports:
  - port: 80
    targetPort: 80
```

### 9. Kustomize Best Practices
- **Base Structure:** Tổ chức base resources đúng cách
- **Overlay Organization:** Tổ chức overlays theo environment
- **Patch Management:** Quản lý patches hiệu quả
- **Security:** Secure sensitive data

**Base Structure Best Practices:**
```
my-app/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── secret.yaml
├── overlays/
│   ├── development/
│   │   ├── kustomization.yaml
│   │   └── patches/
│   ├── staging/
│   │   ├── kustomization.yaml
│   │   └── patches/
│   └── production/
│       ├── kustomization.yaml
│       └── patches/
└── README.md
```

**Security Best Practices:**
```yaml
# Use secretGenerator cho sensitive data
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml

secretGenerator:
- name: app-secret
  literals:
  - DB_PASSWORD=secret123
  - API_KEY=abc123
  files:
  - secrets/database.key
```

### 10. Troubleshooting Kustomize
- **Build Issues:** Problems với kustomize build
- **Patch Issues:** Problems với patches
- **Generator Issues:** Problems với generators
- **Validation Issues:** Problems với validation

**Troubleshoot Commands:**
```bash
# Validate kustomization
kustomize build overlays/development --dry-run

# Debug build
kustomize build overlays/development --enable-alpha-plugins

# Check resources
kustomize build overlays/development | kubectl apply --dry-run=client -f -

# Validate patches
kustomize build overlays/development --load-restrictor LoadRestrictionsNone

# Debug variables
kustomize build overlays/development --enable-alpha-plugins
```

**Common Issues:**
```bash
# Fix resource not found
kustomize build overlays/development --load-restrictor LoadRestrictionsNone

# Fix patch target not found
kustomize build overlays/development --enable-alpha-plugins

# Fix generator issues
kustomize build overlays/development --enable-alpha-plugins

# Fix validation issues
kustomize build overlays/development | kubectl apply --dry-run=client -f -
```

## Lưu ý quan trọng cho CKA
1. **Base Configuration:** Hiểu cấu trúc base và overlay pattern
2. **Patches:** Sử dụng strategic merge patches và JSON patches
3. **Generators:** Sử dụng ConfigMap và Secret generators
4. **Variables:** Define và sử dụng variables
5. **Commands:** Sử dụng kustomize commands để build và apply
6. **Best Practices:** Tổ chức kustomization files đúng cách
7. **Security:** Secure sensitive data với secret generators
8. **Troubleshooting:** Debug và fix common issues

## Practice Commands
```bash
# Create base kustomization
kustomize init

# Build configuration
kustomize build overlays/development

# Apply configuration
kubectl apply -k overlays/development

# Edit configuration
kustomize edit add resource deployment.yaml
kustomize edit set image nginx=nginx:1.19
kustomize edit add label app=my-app

# Diff configuration
kustomize build overlays/development | kubectl diff -f -

# Validate configuration
kustomize build overlays/development | kubectl apply --dry-run=client -f -

# Build với custom plugins
kustomize build --enable-alpha-plugins overlays/development

# Build với load restrictions
kustomize build --load-restrictor LoadRestrictionsNone overlays/development
``` 