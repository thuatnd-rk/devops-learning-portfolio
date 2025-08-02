# 7. Security

## Tổng quan
Phần này bao gồm các khái niệm về bảo mật trong Kubernetes, bao gồm authentication, authorization, network policies, và pod security.

## Nội dung chính

### 1. Authentication
- **Authentication:** Xác thực người dùng và service accounts
- **Methods:**
  - X509 certificates
  - Bearer tokens
  - Service accounts
  - OpenID Connect

**Service Accounts:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
```

**Cú pháp Pod với Service Account:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-service-account
  containers:
  - name: nginx
    image: nginx:latest
```

**Câu lệnh quan trọng:**
```bash
# Tạo service account
kubectl create serviceaccount my-service-account

# Xem service accounts
kubectl get serviceaccounts

# Xem service account token
kubectl get secret <service-account-name>-token-<random-string> -o yaml

# Tạo kubeconfig cho service account
kubectl create token my-service-account
```

### 2. Authorization (RBAC)
- **RBAC:** Role-based access control
- **Components:**
  - Roles/ClusterRoles
  - RoleBindings/ClusterRoleBindings
  - ServiceAccounts

**Role:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

**ClusterRole:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

**RoleBinding:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

**ClusterRoleBinding:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

**Câu lệnh quan trọng:**
```bash
# Tạo role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# Tạo cluster role
kubectl create clusterrole secret-reader --verb=get,list,watch --resource=secrets

# Tạo role binding
kubectl create rolebinding read-pods --role=pod-reader --serviceaccount=default:my-service-account

# Tạo cluster role binding
kubectl create clusterrolebinding read-secrets-global --clusterrole=secret-reader --serviceaccount=default:my-service-account

# Xem roles
kubectl get roles
kubectl get clusterroles

# Xem role bindings
kubectl get rolebindings
kubectl get clusterrolebindings

# Test permissions
kubectl auth can-i get pods
kubectl auth can-i create deployments
```

### 3. Network Policies
- **Network Policies:** Control traffic flow giữa pods
- **Default Behavior:** Allow all traffic nếu không có network policy

**Network Policy:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress: []
  egress: []
```

**Allow specific traffic:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nginx
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
```

**Câu lệnh quan trọng:**
```bash
# Tạo network policy
kubectl apply -f network-policy.yaml

# Xem network policies
kubectl get networkpolicies

# Xem chi tiết network policy
kubectl describe networkpolicy <policy-name>

# Test network connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- <service-name>:<port>
```

### 4. Pod Security Standards
- **Pod Security Standards:** Security policies cho pods
- **Levels:**
  - Privileged (least secure)
  - Baseline
  - Restricted (most secure)

**Pod Security Admission:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: nginx
    image: nginx:latest
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

**Pod Security Policy (deprecated):**
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
  - ALL
  volumes:
  - 'configMap'
  - 'emptyDir'
  - 'projected'
  - 'secret'
  - 'downwardAPI'
  - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
    - min: 1
      max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
    - min: 1
      max: 65535
  readOnlyRootFilesystem: true
```

### 5. Security Contexts
- **Security Context:** Security settings cho pods và containers
- **Pod Security Context:** Settings áp dụng cho tất cả containers
- **Container Security Context:** Settings cho container cụ thể

**Pod Security Context:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox
    command: ["sh", "-c", "sleep 1h"]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /data/demo
    securityContext:
      allowPrivilegeEscalation: false
```

**Container Security Context:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo-2
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - name: sec-ctx-demo-2
    image: gcr.io/google-samples/node-hello:1.0
    securityContext:
      runAsUser: 2000
      allowPrivilegeEscalation: false
```

### 6. Secrets Management
- **Secrets:** Store sensitive data
- **Types:**
  - Opaque (default)
  - kubernetes.io/service-account-token
  - kubernetes.io/dockercfg
  - kubernetes.io/dockerconfigjson
  - kubernetes.io/basic-auth
  - kubernetes.io/ssh-auth
  - kubernetes.io/tls

**Opaque Secret:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: cGFzc3dvcmQ=  # base64 encoded
```

**TLS Secret:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
```

**Docker Registry Secret:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

**Câu lệnh quan trọng:**
```bash
# Tạo secret từ file
kubectl create secret generic my-secret --from-file=username.txt --from-file=password.txt

# Tạo secret từ literal
kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=password

# Tạo docker registry secret
kubectl create secret docker-registry my-registry-secret --docker-server=<server> --docker-username=<username> --docker-password=<password>

# Tạo TLS secret
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key

# Xem secrets
kubectl get secrets

# Xem secret data
kubectl get secret my-secret -o yaml

# Decode secret
echo "YWRtaW4=" | base64 -d
```

### 7. Pod với Secrets
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-test-pod
spec:
  containers:
  - name: test-container
    image: nginx
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secret-volume
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: my-secret
```

**Environment Variables với Secrets:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-test
spec:
  containers:
  - name: env-test-container
    image: nginx
    env:
    - name: SECRET_USERNAME
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: username
    - name: SECRET_PASSWORD
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: password
```

### 8. Admission Controllers
- **Admission Controllers:** Validate và modify requests
- **Built-in Controllers:**
  - PodSecurityPolicy
  - ResourceQuota
  - LimitRanger
  - ServiceAccount

**Enable Admission Controllers:**
```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - name: kube-apiserver
    image: k8s.gcr.io/kube-apiserver:v1.24.0
    command:
    - kube-apiserver
    - --enable-admission-plugins=NodeRestriction,PodSecurityPolicy
```

### 9. Audit Logging
- **Audit Logging:** Log tất cả API requests
- **Audit Levels:**
  - None
  - Metadata
  - Request
  - RequestResponse

**Configure Audit Logging:**
```yaml
# /etc/kubernetes/manifests/kube-apiserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - name: kube-apiserver
    image: k8s.gcr.io/kube-apiserver:v1.24.0
    command:
    - kube-apiserver
    - --audit-log-path=/var/log/audit.log
    - --audit-log-maxage=30
    - --audit-log-maxbackup=10
    - --audit-log-maxsize=100
    - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
```

**Audit Policy:**
```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["pods"]
- level: Request
  resources:
  - group: ""
    resources: ["secrets"]
```

## Lưu ý quan trọng cho CKA
1. **RBAC:** Hiểu roles, clusterroles, rolebindings, clusterrolebindings
2. **Service Accounts:** Cách tạo và sử dụng service accounts
3. **Network Policies:** Cách control traffic flow
4. **Security Contexts:** Cách set security settings cho pods và containers
5. **Secrets:** Cách quản lý sensitive data
6. **Pod Security:** Cách implement pod security standards
7. **Audit Logging:** Cách configure và monitor audit logs
8. **Admission Controllers:** Cách enable và configure admission controllers

## Practice Commands
```bash
# Tạo service account
kubectl create serviceaccount my-sa

# Tạo role và role binding
kubectl create role pod-reader --verb=get,list,watch --resource=pods
kubectl create rolebinding read-pods --role=pod-reader --serviceaccount=default:my-sa

# Test permissions
kubectl auth can-i get pods --as=system:serviceaccount:default:my-sa

# Tạo secret
kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=password

# Tạo network policy
kubectl create networkpolicy default-deny --pod-selector='' --ingress='[]' --egress='[]'

# Check security context
kubectl get pod <pod-name> -o yaml | grep -A 10 securityContext

# Check RBAC
kubectl get roles,rolebindings,clusterroles,clusterrolebindings --all-namespaces

# Check network policies
kubectl get networkpolicies --all-namespaces

# Check secrets
kubectl get secrets --all-namespaces
``` 