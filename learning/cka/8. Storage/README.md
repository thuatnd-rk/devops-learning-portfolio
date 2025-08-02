# 8. Storage

## Tổng quan
Phần này bao gồm các khái niệm về storage trong Kubernetes, bao gồm volumes, persistent volumes, storage classes, và dynamic provisioning.

## Nội dung chính

### 1. Volumes
- **Volumes:** Storage được attach vào pod
- **Types:**
  - emptyDir
  - hostPath
  - configMap
  - secret
  - persistentVolumeClaim

**emptyDir Volume:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: nginx
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```

**hostPath Volume:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: nginx
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:
      path: /data
      type: Directory
```

**configMap Volume:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: test-container
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: special-config
```

**secret Volume:**
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
      secretName: test-secret
```

### 2. Persistent Volumes (PV)
- **Persistent Volume:** Storage resource trong cluster
- **Access Modes:**
  - ReadWriteOnce (RWO)
  - ReadOnlyMany (ROM)
  - ReadWriteMany (RWM)

**Persistent Volume:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

**Persistent Volume Claim:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

**Pod với PVC:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  containers:
  - name: task-pv-container
    image: nginx
    ports:
    - containerPort: 80
      name: "http-server"
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: task-pv-storage
  volumes:
  - name: task-pv-storage
    persistentVolumeClaim:
      claimName: task-pv-claim
```

**Câu lệnh quan trọng:**
```bash
# Tạo PV
kubectl apply -f pv.yaml

# Tạo PVC
kubectl apply -f pvc.yaml

# Xem PVs
kubectl get pv

# Xem PVCs
kubectl get pvc

# Xem chi tiết PV
kubectl describe pv <pv-name>

# Xem chi tiết PVC
kubectl describe pvc <pvc-name>

# Xóa PV
kubectl delete pv <pv-name>

# Xóa PVC
kubectl delete pvc <pvc-name>
```

### 3. Storage Classes
- **Storage Class:** Define storage provisioner và parameters
- **Dynamic Provisioning:** Tự động tạo PV khi có PVC

**Storage Class:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  iops: "3000"
  throughput: "125"
reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
  - debug
volumeBindingMode: Immediate
```

**PVC với Storage Class:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fast-ssd-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 100Gi
```

**Default Storage Class:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Delete
allowVolumeExpansion: true
```

**Câu lệnh quan trọng:**
```bash
# Tạo storage class
kubectl apply -f storage-class.yaml

# Xem storage classes
kubectl get storageclass

# Set default storage class
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Xem storage class details
kubectl describe storageclass <storage-class-name>
```

### 4. Volume Snapshots
- **Volume Snapshots:** Backup và restore volumes
- **Snapshot Classes:** Define snapshot provisioner

**Volume Snapshot Class:**
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-aws-vsc
driver: ebs.csi.aws.com
deletionPolicy: Delete
```

**Volume Snapshot:**
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: new-snapshot-test
spec:
  volumeSnapshotClassName: csi-aws-vsc
  source:
    persistentVolumeClaimName: task-pv-claim
```

**PVC từ Snapshot:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restore-pvc
spec:
  dataSource:
    name: new-snapshot-test
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

**Câu lệnh quan trọng:**
```bash
# Tạo snapshot
kubectl apply -f snapshot.yaml

# Xem snapshots
kubectl get volumesnapshots

# Xem snapshot details
kubectl describe volumesnapshot <snapshot-name>

# Restore từ snapshot
kubectl apply -f restore-pvc.yaml
```

### 5. CSI (Container Storage Interface)
- **CSI:** Standard interface cho storage plugins
- **CSI Drivers:** Third-party storage drivers

**CSI Driver Installation:**
```bash
# Install AWS EBS CSI Driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.16"

# Install Azure Disk CSI Driver
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/crd/csi-driver-registrar.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/crd/csi-node-info.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/rbac/csi-azuredisk-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/csi-azuredisk-driver.yaml
```

**Storage Class với CSI:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp2
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

### 6. Local Storage
- **Local Storage:** Storage trên local node
- **Local PV:** Persistent volume trên local disk

**Local Persistent Volume:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/disks/vol1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - example-node
```

**Local Storage Class:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

### 7. Volume Lifecycle
- **Volume Binding:** Khi nào volume được bind
- **Volume Expansion:** Mở rộng volume size
- **Volume Snapshot:** Backup và restore

**Volume Binding Modes:**
- **Immediate:** Bind ngay khi tạo PVC
- **WaitForFirstConsumer:** Bind khi pod được tạo

**Volume Expansion:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: expandable-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: expandable-storage
  resources:
    requests:
      storage: 1Gi
```

**Expand PVC:**
```bash
# Patch PVC để expand
kubectl patch pvc expandable-pvc -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'

# Xem PVC status
kubectl get pvc expandable-pvc
```

### 8. Storage Security
- **Security Context:** Security settings cho volumes
- **ReadOnly Root Filesystem:** Mount volumes read-only

**Pod với Security Context:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
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
      readOnlyRootFilesystem: true
```

### 9. Troubleshooting Storage
- **Volume Mount Issues:** Pod không mount được volume
- **Storage Class Issues:** Storage class không hoạt động
- **CSI Driver Issues:** CSI driver problems

**Troubleshoot Volume Issues:**
```bash
# Check PV status
kubectl get pv
kubectl describe pv <pv-name>

# Check PVC status
kubectl get pvc
kubectl describe pvc <pvc-name>

# Check pod volume mounts
kubectl describe pod <pod-name>

# Check storage class
kubectl get storageclass
kubectl describe storageclass <storage-class-name>

# Check CSI driver
kubectl get pods -n kube-system | grep csi

# Check volume events
kubectl get events --field-selector involvedObject.name=<pv-name>
```

**Debug Volume Mount:**
```bash
# Exec vào pod để check mount
kubectl exec -it <pod-name> -- df -h

# Check volume mount point
kubectl exec -it <pod-name> -- ls -la /path/to/mount

# Check volume permissions
kubectl exec -it <pod-name> -- id
```

## Lưu ý quan trọng cho CKA
1. **Volume Types:** Hiểu các loại volumes và khi nào dùng
2. **PV/PVC:** Cách tạo và quản lý persistent volumes
3. **Storage Classes:** Cách configure storage classes và dynamic provisioning
4. **Volume Snapshots:** Cách backup và restore volumes
5. **CSI Drivers:** Cách install và configure CSI drivers
6. **Local Storage:** Cách setup local persistent volumes
7. **Volume Security:** Cách secure volumes với security contexts
8. **Troubleshooting:** Cách debug storage issues

## Practice Commands
```bash
# Tạo PV và PVC
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml

# Tạo storage class
kubectl apply -f storage-class.yaml

# Tạo pod với volume
kubectl apply -f pod-with-volume.yaml

# Check volume status
kubectl get pv,pvc
kubectl describe pv <pv-name>
kubectl describe pvc <pvc-name>

# Expand PVC
kubectl patch pvc <pvc-name> -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'

# Create snapshot
kubectl apply -f snapshot.yaml

# Check storage classes
kubectl get storageclass

# Debug volume issues
kubectl describe pod <pod-name>
kubectl exec -it <pod-name> -- df -h
``` 