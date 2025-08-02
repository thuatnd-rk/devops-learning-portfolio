# 5. Application Lifecycle Management

## Tổng quan
Phần này bao gồm các khái niệm về quản lý vòng đời ứng dụng trong Kubernetes, bao gồm deployments, updates, rollbacks, và scaling.

## Nội dung chính

### 1. Deployments
- **Deployment:** Controller quản lý ReplicaSets và Pods
- Cung cấp declarative updates cho Pods và ReplicaSets
- Hỗ trợ rolling updates và rollbacks

**Cú pháp Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

**Câu lệnh quan trọng:**
```bash
# Tạo deployment
kubectl apply -f deployment.yaml

# Xem deployments
kubectl get deployments

# Xem deployment status
kubectl rollout status deployment/nginx-deployment

# Xem deployment history
kubectl rollout history deployment/nginx-deployment

# Xem chi tiết deployment
kubectl describe deployment nginx-deployment

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5

# Update deployment
kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1

# Pause deployment
kubectl rollout pause deployment/nginx-deployment

# Resume deployment
kubectl rollout resume deployment/nginx-deployment
```

### 2. Rolling Updates
- **Rolling Update:** Update từng pod một cách tuần tự
- Đảm bảo zero-downtime deployments
- Có thể pause/resume quá trình update

**Các strategies:**
- **RollingUpdate (default):** Update từng pod
- **Recreate:** Xóa tất cả pods cũ trước khi tạo mới

**Cú pháp Rolling Update:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
```

**Câu lệnh quan trọng:**
```bash
# Update image
kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1

# Xem rollout status
kubectl rollout status deployment/nginx-deployment

# Pause rollout
kubectl rollout pause deployment/nginx-deployment

# Resume rollout
kubectl rollout resume deployment/nginx-deployment

# Xem rollout history
kubectl rollout history deployment/nginx-deployment

# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Rollback to specific revision
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

### 3. Rollbacks
- **Rollback:** Quay lại version trước đó
- Có thể rollback về revision cụ thể
- Hỗ trợ undo và redo

**Câu lệnh rollback:**
```bash
# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Rollback to specific revision
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Xem rollout history
kubectl rollout history deployment/nginx-deployment

# Xem chi tiết revision
kubectl rollout history deployment/nginx-deployment --revision=2
```

### 4. ReplicaSets
- **ReplicaSet:** Đảm bảo số lượng pods chạy
- Deployment sử dụng ReplicaSet để quản lý pods
- Có thể tạo ReplicaSet độc lập

**Cú pháp ReplicaSet:**
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
```

**Câu lệnh quan trọng:**
```bash
# Tạo ReplicaSet
kubectl apply -f replicaset.yaml

# Xem ReplicaSets
kubectl get replicasets

# Scale ReplicaSet
kubectl scale replicaset nginx-replicaset --replicas=5

# Xem chi tiết ReplicaSet
kubectl describe replicaset nginx-replicaset
```

### 5. StatefulSets
- **StatefulSet:** Quản lý stateful applications
- Mỗi pod có unique identity
- Pods được tạo và xóa theo thứ tự

**Cú pháp StatefulSet:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

**Câu lệnh quan trọng:**
```bash
# Tạo StatefulSet
kubectl apply -f statefulset.yaml

# Xem StatefulSets
kubectl get statefulsets

# Scale StatefulSet
kubectl scale statefulset web --replicas=5

# Xem pods của StatefulSet
kubectl get pods -l app=nginx

# Update StatefulSet
kubectl set image statefulset/web nginx=nginx:1.16.1
```

### 6. DaemonSets
- **DaemonSet:** Đảm bảo tất cả nodes chạy một copy của pod
- Thường dùng cho monitoring, logging, storage

**Cú pháp DaemonSet:**
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      serviceAccountName: fluentd
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "elasticsearch-logging"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

**Câu lệnh quan trọng:**
```bash
# Tạo DaemonSet
kubectl apply -f daemonset.yaml

# Xem DaemonSets
kubectl get daemonsets

# Update DaemonSet
kubectl set image daemonset/fluentd-elasticsearch fluentd=fluent/fluentd-kubernetes-daemonset:v1.14-debian-elasticsearch

# Xem pods của DaemonSet
kubectl get pods -l name=fluentd-elasticsearch
```

### 7. Jobs và CronJobs
- **Job:** Tạo một hoặc nhiều pods để chạy task và terminate
- **CronJob:** Tạo Jobs theo schedule

**Cú pháp Job:**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

**Cú pháp CronJob:**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

**Câu lệnh quan trọng:**
```bash
# Tạo Job
kubectl apply -f job.yaml

# Xem Jobs
kubectl get jobs

# Xem CronJobs
kubectl get cronjobs

# Xem logs của Job
kubectl logs job/pi

# Xóa Job
kubectl delete job pi

# Suspend CronJob
kubectl patch cronjob hello -p '{"spec" : {"suspend" : true }}'

# Resume CronJob
kubectl patch cronjob hello -p '{"spec" : {"suspend" : false }}'
```

### 8. Horizontal Pod Autoscaler (HPA)
- **HPA:** Tự động scale pods dựa trên CPU/memory usage
- Cần có metrics server hoặc custom metrics

**Cú pháp HPA:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 50
```

**Câu lệnh quan trọng:**
```bash
# Tạo HPA
kubectl apply -f hpa.yaml

# Xem HPA
kubectl get hpa

# Xem chi tiết HPA
kubectl describe hpa nginx-hpa

# Tạo HPA từ command line
kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=1 --max=10

# Xóa HPA
kubectl delete hpa nginx-hpa
```

### 9. Pod Disruption Budgets (PDB)
- **PDB:** Đảm bảo availability của application
- Giới hạn số pods có thể bị unavailable

**Cú pháp PDB:**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: nginx
```

**Câu lệnh quan trọng:**
```bash
# Tạo PDB
kubectl apply -f pdb.yaml

# Xem PDB
kubectl get pdb

# Xem chi tiết PDB
kubectl describe pdb nginx-pdb
```

## Lưu ý quan trọng cho CKA
1. **Deployment vs ReplicaSet:** Hiểu sự khác biệt và khi nào dùng
2. **Rolling Updates:** Cách implement và troubleshoot
3. **Rollbacks:** Cách thực hiện rollback và xem history
4. **StatefulSets:** Khi nào dùng và cách quản lý
5. **DaemonSets:** Cách deploy trên tất cả nodes
6. **Jobs/CronJobs:** Cách chạy batch tasks
7. **HPA:** Cách setup autoscaling
8. **PDB:** Cách đảm bảo availability

## Practice Commands
```bash
# Tạo deployment với rolling update
kubectl create deployment nginx --image=nginx:1.14.2 --replicas=3

# Update deployment
kubectl set image deployment/nginx nginx=nginx:1.16.1

# Xem rollout status
kubectl rollout status deployment/nginx

# Rollback deployment
kubectl rollout undo deployment/nginx

# Scale deployment
kubectl scale deployment nginx --replicas=5

# Tạo HPA
kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=10

# Xem deployment history
kubectl rollout history deployment/nginx

# Pause rollout
kubectl rollout pause deployment/nginx

# Resume rollout
kubectl rollout resume deployment/nginx
``` 