# Certified Kubernetes Administrator (CKA) – Cheat Sheet & Useful Resources

Tài liệu dưới đây tổng hợp các **alias**, biến môi trường và lệnh `kubectl` cùng với các liên kết tham khảo hữu ích. Đây là bộ tài liệu “cheat sheet” giúp bạn nhanh chóng tìm được lệnh phù hợp trong quá trình làm việc và ôn tập cho kỳ thi CKA.

---

## 1. Useful Resources

- **CKA Wiki trên GitHub:**  
  [https://github.com/ascode-com/wiki/tree/main/certified-kubernetes-administrator](https://github.com/ascode-com/wiki/tree/main/certified-kubernetes-administrator)

- **CKA Course trên KodekloudHub:**  
  [https://github.com/kodekloudhub/certified-kubernetes-administrator-course](https://github.com/kodekloudhub/certified-kubernetes-administrator-course)

- **Video hữu ích:**  
  [https://www.youtube.com/watch?v=qRPNuT080Hk](https://www.youtube.com/watch?v=qRPNuT080Hk)

- **Tài liệu chính thức Kubernetes:**  

  - **Kubeadm Upgrade:**  
    [https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

  - **Services & Networking:**  
    [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)

  - **Persistent Volumes:**  
    [https://kubernetes.io/docs/concepts/storage/persistent-volumes/](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

  - **ConfigMap:**  
    [https://kubernetes.io/docs/concepts/configuration/configmap/](https://kubernetes.io/docs/concepts/configuration/configmap/)

  - **Secret:**  
    [https://kubernetes.io/docs/concepts/configuration/secret/](https://kubernetes.io/docs/concepts/configuration/secret/)

  - **Deployment:**  
    [https://kubernetes.io/docs/concepts/workloads/controllers/deployment/](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

  - **ReplicaSet:**  
    [https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

  - **StatefulSet:**  
    [https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

  - **DaemonSet:**  
    [https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

  - **Job:**  
    [https://kubernetes.io/docs/concepts/workloads/controllers/job/](https://kubernetes.io/docs/concepts/workloads/controllers/job/)

  - **Upgrade etcd:**  
    [https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)

  - **Certificate Signing Requests:**  
    [https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-certificatesigningrequest](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-certificatesigningrequest)

  - **RBAC – Role Example:**  
    [https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-example](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-example)

  - **RBAC – Create RoleBinding:**  
    [https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-rolebinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-rolebinding)

  - **Security Context cho Pod:**  
    [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod)

  - **HostPath Volume Example:**  
    [https://kubernetes.io/docs/concepts/storage/volumes/#hostpath-configuration-example](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath-configuration-example)

  - **Create PersistentVolume:**  
    [https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolume)

  - **Create PersistentVolumeClaim:**  
    [https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolumeclaim](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/#create-a-persistentvolumeclaim)

  - **Claims as Volumes:**  
    [https://kubernetes.io/docs/concepts/storage/persistent-volumes/#claims-as-volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#claims-as-volumes)

  - **StorageClass Local:**  
    [https://kubernetes.io/docs/concepts/storage/storage-classes/#local](https://kubernetes.io/docs/concepts/storage/storage-classes/#local)

---

## 2. Aliases & Environment Variables

### Alias cho các lệnh `kubectl` và ls

```bash
alias ll='ls -l'
alias kcr='kubectl create'
alias ka='kubectl apply -f'
alias k=kubectl
alias kg='kubectl get'
alias ke='kubectl edit'
alias kd='kubectl describe'
alias kdd='kubectl delete'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgpvc='kubectl get pvc'
alias kgpv='kubectl get pv'
```

### Biến môi trường (export alias)

> **Lưu ý:** Một số người thích export các alias này để dùng chung trong script.

```bash
export alias fg='--force --grace-period=0'
export alias do='--dry-run=client -o yaml'
export alias oy='-o yaml'
```

### Thiết lập alias và bash completion cho `kubectl`

```bash
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
```

### Câu lệnh khác

```bash
sed -i 's/old_text/new_text/g' filename
kubectl get pods | awk '{print $1, $3}'
kubectl get pods | awk '$3 != "Running" {print $1, $3}'
```

---

## 3. Command Categories

### 3.1. Pods

- **Thay thế (replace) YAML cho pod một cách cưỡng chế:**
  ```bash
  kubectl replace --force -f /tmp/kubectl-31523123.yaml
  ```
  *(Sử dụng khi các giá trị không thay đổi trực tiếp, ví dụ: cập nhật command.)*

- **Chạy các pod:**
  ```bash
  kubectl run test --image=nginx
  kubectl run redis --image=redis -n finance
  kubectl run redis --image=redis:alpine -l 'tier=db'
  kubectl run custom-nginx --image=nginx --port=8080
  kubectl run webapp-color --image=kodekloud/webapp-color -l name=webapp-color --env="APP_COLOR=green"
  kubectl run pvviewer --image=redis --serviceaccount=pvviewer
  ```

- **Sắp xếp kết quả hiển thị:**
  ```bash
  kubectl get pods -A --sort-by='metadata.uid' > /root/pods.txt
  kubectl get pods -A --sort-by='metadata.creationTimestamp' > /root/creation.txt
  ```

---

### 3.2. Generate YAML Files

- **Tạo file YAML từ pod (không tạo resource):**
  ```bash
  kubectl run nginx --image=nginx --dry-run=client -o yaml
  ```

- **Tạo Deployment với file YAML mẫu:**
  ```bash
  kubectl create deployment nginx --image=nginx
  kubectl create deployment nginx --image=nginx --dry-run=client -o yaml
  kubectl create deployment nginx --image=nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml
  ```

- **Tạo YAML cho webapp với tham số:**
  ```bash
  kubectl run webapp-green --image=kodekloud/webapp-color --dry-run=client -o yaml -- command --color=green > asd.yaml
  kubectl run webapp-green --image=kodekloud/webapp-color -- --color green
  ```

---

### 3.3. Deployments

- **Tạo Deployments:**
  ```bash
  kubectl create deployment httpd-frontend --image=httpd:2.4-alpine --replicas=3
  kubectl create deploy redis-deploy --image=redis --replicas=2 -n dev-ns
  ```

- **Cập nhật image cho Deployment:**
  ```bash
  kubectl set image deployment nginx nginx=nginx:1.15
  kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1
  ```

- **Scale và Rollout:**
  ```bash
  kubectl scale deployment nginx --replicas=5
  kubectl rollout status deployment/myapp-deployment
  kubectl rollout history deployment/myapp-deployment
  kubectl rollout undo deployment/myapp-deployment
  ```

- **Tạo/Áp dụng Deployment từ file YAML:**
  ```bash
  kubectl create -f deployment-definition.yml
  kubectl apply -f deployment-definition.yml
  ```

- **Xuất thông tin Deployment với custom-columns:**
  ```bash
  kubectl -n admin2406 get deployment -o custom-columns=DEPLOYMENT:.metadata.name,CONTAINER_IMAGE:.spec.template.spec.containers[].image,READY_REPLICAS:.status.readyReplicas,NAMESPACE:.metadata.namespace --sort-by=.metadata.name > /opt/admin2406_data
  ```

---

### 3.4. Services

- **Expose Deployment/Pod thành Service:**
  ```bash
  kubectl expose deploy minio --type=NodePort --port=9001 --target-port=9001 --dry-run=client -o yaml > minio-svc.yaml
  kubectl expose pod redis --port=6379 --name redis-service
  kubectl run httpd --image=httpd:alpine --port=80 --expose
  ```

- **Tạo Service bằng lệnh:**
  ```bash
  kubectl create service clusterip redis --tcp=6379:6378 --dry-run=client -o yaml
  kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml
  ```

---

### 3.5. Scheduler

- **Kiểm tra trạng thái Scheduler:**
  ```bash
  kubectl get pods --namespace kube-system
  ```
  *Nếu không thấy Scheduler, cần thêm `nodeName` trong phần `spec.containers` của file YAML.*

---

### 3.6. Labels and Selectors

- **Đếm số pod theo label:**
  ```bash
  kubectl get pods --selector env=dev --no-headers | wc -l
  kubectl get pods --selector='bu=finance' | wc -l
  kubectl get all --selector='env=prod' | wc -l
  kubectl get all --selector env=prod,bu=finance,tier=frontend
  ```

---

### 3.7. Taints and Tolerations

- **Áp dụng và loại bỏ taint:**
  ```bash
  kubectl taint nodes node01.test.kz spray=mortein:NoSchedule
  kubectl taint nodes node01.test.kz spray=mortein:NoSchedule-
  ```

---

### 3.8. NodeSelector & NodeAffinity

- **Gán nhãn cho node:**  
  ```bash
  kubectl label node node01.test.kz size=Super
  ```
- *(Thực hành NodeAffinity thêm nếu cần.)*

---

### 3.9. DaemonSet

- **Ghi chú:**  
  Tạo Deployment sau đó loại bỏ các trường như `replicas`, `strategy`, `status` để chuyển đổi sang DaemonSet.

---

### 3.10. Static Pods

- **Xem file manifest của static pods:**
  ```bash
  ls -l /etc/kubernetes/manifests/
  ```

- **Tìm thông tin kubelet:**
  ```bash
  ps -aux | grep /usr/bin/kubelet
  grep -i staticpod /var/lib/kubelet/config.yaml
  ```

- **Sinh file YAML cho static pod:**
  ```bash
  kubectl run static-busybox --image=busybox --dry-run=client -o yaml --command -- sleep 1000
  kubectl run --restart=Never --image=busybox:1.28.4 static-busybox --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml
  ```

---

### 3.11. Multiple Schedulers

- **Kiểm tra sự kiện:**
  ```bash
  kubectl get events -o wide
  ```

---

### 3.12. Logging and Monitoring

- **Xem log và sử dụng Metrics:**
  ```bash
  kubectl logs -f event-simulator-pod
  kubectl logs -p -c nginx web
  kubectl top node
  kubectl top pod
  kubectl top pods --containers=true
  ```

---

### 3.13. ConfigMap

- **Làm việc với ConfigMap:**
  ```bash
  kubectl describe cm db-config
  kubectl create configmap webapp-config-map --from-literal=APP_COLOR=darkblue
  ```

---

### 3.14. Init Containers

- **Kiểm tra log của initContainer:**
  ```bash
  kubectl logs orange -c init-myservice
  ```

---

### 3.15. Cluster Maintenance

- **Drain, cordon & uncordon:**
  ```bash
  kubectl drain node-1
  kubectl cordon node-2
  kubectl uncordon node-1
  ```

- **Cập nhật & xóa pod khi nâng cấp:**
  ```bash
  kubectl upgrade plan
  kubectl upgrade apply
  kubectl drain node01 --ignore-daemonsets --force
  ```

---

### 3.16. ETCD Operations

- **Kiểm tra ETCD:**
  ```bash
  kubectl describe pod etcd-controlplane -n kube-system
  etcdctl version
  ```

- **Backup ETCD:**
  ```bash
  ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /opt/snapshot-pre-boot.db
  ```

- **Restore ETCD:**
  ```bash
  ETCDCTL_API=3 etcdctl snapshot restore /opt/snapshot-pre-boot.db --data-dir /var/lib/etcd-from-backup
  ```

---

### 3.17. TLS and Certificates

- **Các thao tác với chứng chỉ:**
  ```bash
  cat akshay.csr | base64 -w 0
  kubectl certificate approve akshay
  kubectl get csr agent-smith -o yaml
  kubectl delete csr agent-smith
  ```

---

### 3.18. Kubeconfig and Context

- **Xem và chuyển context:**
  ```bash
  kubectl config get-contexts
  kubectl config current-context
  kubectl config view
  kubectl config view --kubeconfig=/path/to/kubeconfig --validate=true
  kubectl cluster-info --kubeconfig=/path/to/kubeconfig
  ```

---

### 3.19. RBAC, Roles & RoleBindings

- **Kiểm tra RBAC:**
  ```bash
  kubectl get roles
  kubectl get rolebindings
  kubectl describe role developer
  kubectl describe rolebinding devuser-developer-binding
  kubectl auth can-i create deployments
  kubectl auth can-i delete node
  kubectl auth can-i create deployments --as dev-user
  kubectl auth can-i create pods --as dev-user
  ```

- **Tạo Role và RoleBinding:**
  ```bash
  kubectl create role developer --namespace=default --verb=list,create,delete --resource=pods
  kubectl create rolebinding dev-user-binding --namespace=default --role=developer --user=dev-user
  kubectl create role developer --verb=create --verb=get --verb=delete --verb=list --resource=pods --resource=deployments --namespace=blue
  ```

---

### 3.20. ClusterRole

- **Xem và tạo ClusterRole:**
  ```bash
  kubectl get clusterrolebindings --no-headers | wc -l
  kubectl create clusterrole nodes --verb=create --verb=list --verb=delete --verb=watch --resource=nodes
  kubectl create clusterrolebinding nodes-admin --clusterrole=nodes --user=michelle
  kubectl create clusterrole storage-admin --verb=list,create,watch --resource=persistentvolumes,storageclasses
  kubectl create clusterrolebinding michelle-storage-admin --clusterrole=storage-admin --user=michelle
  ```

---

### 3.21. ServiceAccount

- **Tạo ServiceAccount và token:**
  ```bash
  kubectl create sa dashboard-sa
  kubectl create token dashboard-sa
  ```

- **Helmsman ServiceAccount:**
  ```bash
  kubectl create clusterrole deployment-change --verb=get --verb=delete --verb=create --verb=list --verb=patch --verb=watch --resource=rs,deployment,secrets,services -n altyn-le-dev
  kubectl create clusterrolebinding cr-deployment-change --clusterrole=deployment-change --serviceaccount=altyn-le-dev:deployer -n altyn-le-dev
  ```

---

### 3.22. Security Context

- **Kiểm tra security context của pod:**
  ```bash
  kubectl exec ubuntu-sleeper -- whoami
  ```

---

### 3.23. Persistent Volumes (PV) & Persistent Volume Claims (PVC)

- **Xem thông tin PVC:**
  ```bash
  kubectl describe pvc local-pvc
  ```

---

### 3.24. DNS

- **Thực hiện tra cứu DNS từ pod:**
  ```bash
  kubectl exec -it hr -- nslookup mysql.payroll > /root/CKA/nslookup.out
  ```

---

### 3.25. Ingress (K8s 1.20+)

- **Tạo Ingress:**
  ```bash
  kubectl create ingress minio-dev --dry-run=client -o yaml --rule="minio-dev.halykmarket.com/=minio:9000,tls=wildcard.halykmarket.com" -n minio-dev
  kubectl create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80"
  kubectl create ingress pay-ingress --rule="/pay=pay-service:8282" --dry-run=client -o yaml -n critical-space > pay-ing.yaml
  kubectl create ingress shop --rule='/wear=wear-service:8080' --rule='/watch=video-service:8080' -n app-space
  ```

---

### 3.26. Troubleshooting

- **Các lệnh kiểm tra và debug:**
  ```bash
  kubectl get nodes
  service kube-apiserver status
  service kube-controller-manager status
  service kube-scheduler status
  service kubelet status
  service kube-proxy status
  kubectl logs kube-apiserver-master -n kube-system
  sudo journalctl -u kube-apiserver
  kubectl describe node worker-1
  sudo journalctl -u kubelet
  openssl x509 -in /var/lib/kubelet/worker-1.crt -text
  openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt
  openssl x509 -enddate -noout -text -in /etc/kubernetes/pki/apiserver.crt
  vi /etc/kubernetes/kubelet.conf
  ```
  *Kiểm tra file cấu hình kubelet nếu gặp lỗi "node not found".*

---

### 3.27. Pods Exec

- **Chạy các lệnh bên trong pod:**
  ```bash
  kubectl run dns-resolver1 --image=busybox:1.28 --restart=Never --rm -it --command -- nslookup nginx-resolver-service > /root/CKA/nginx.svc
  kubectl run dns-resolver2 --image=busybox:1.28 --restart=Never --rm -it --command -- nslookup 10.244.192.4 > /root/CKA/nginx.pod
  kubectl run --rm -ti tshoot --image=nicolaka/netshoot --command -- nc -z -v -w -2 10.244.192.1 80
  ```

---

### 3.28. JSONPath

- **Trích xuất dữ liệu với JSONPath:**
  ```bash
  kubectl get nodes -o json | jq -c 'paths'
  kubectl get nodes -o json | jq -c 'paths' | grep type | grep -v "metadata" | grep address
  ```

---

### 3.29. Crictl

- **Lấy log container qua `crictl`:**
  ```bash
  crictl logs 2354z34edhyd43 >& /opt/log/container.log
  ```

---

### 3.30. kubeadm Join & Certificates

- **Quản lý token và chứng chỉ:**
  ```bash
  kubeadm token list
  kubeadm token create --print-join-command
  kubeadm certs check-expiration
  ```

- **Tìm socket của container runtime:**
  ```bash
  ps -aux | grep kubelet | grep --color container-runtime-endpoint
  ```

- **CNI plugins & cấu hình mạng:**
  ```bash
  ls /etc/cni/net.d/
  cat /etc/cni/net.d/10-flannel.conflist
  ip route
  ```
  *Ví dụ kết quả hiển thị:*
  ```
  default via 172.25.1.1 dev eth1 
  10.57.230.0/24 dev eth0 proto kernel scope link src 10.57.230.6 
  10.244.0.0/16 dev weave proto kernel scope link src 10.244.192.0
  172.25.1.0/24 dev eth1 proto kernel scope link src 172.25.1.11
  ```
  *Dòng có `10.244.0.0/16` là ví dụ về gateway mặc định cho pods.*

---

*Nguồn tham khảo: [CKA Wiki](https://github.com/ascode-com/wiki/tree/main/certified-kubernetes-administrator) và các bài viết, video về kinh nghiệm thi CKA.*