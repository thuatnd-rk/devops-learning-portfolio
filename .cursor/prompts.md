# /k8s-dry
Tạo chuỗi lệnh kiểm tra manifest (theo thư mục hiện tại):
- Nếu dùng kustomize:
  kustomize build . | kubeconform -strict && kustomize build . | kubectl apply --dry-run=client -f -
- Nếu dùng Helm chart:
  helm template . -f values.yaml | kubeconform -strict && helm template . -f values.yaml | kubectl apply --dry-run=client -f -
- Cuối cùng:
  yamllint .

# /helm-review
Rà soát values*.yaml:
- requests/limits, readiness/liveness/startup probes
- securityContext (runAsNonRoot, readOnlyRootFilesystem, drop CAPs)
- tolerations/nodeSelector/affinity
- service/ingress annotations (timeouts, LB), HPA
Trả về: đề xuất diff tối thiểu + lệnh `helm template` để kiểm chứng.

# /tf-guardrails
Quy trình an toàn trước thay đổi Terraform:
- terraform fmt -recursive && terraform validate
- terraform workspace select <env> || terraform workspace new <env>
- terraform plan -var-file=env/<env>.tfvars
- Nhắc: backend/state lock, quyền IAM least privilege.

# /obs-verify
Kiểm tra stack quan sát:
- promtool check config projects/system-monitoring/prometheus/*.yml
- amtool check-config projects/system-monitoring/alertmanager/*.yml
- Kiểm tra Grafana provisioning (datasources/dashboards)
- Loki/Fluent Bit: xác thực pipeline, ví dụ truy vấn LogQL mẫu.

# /commit-summary
Tóm tắt thay đổi dưới dạng bullet để dùng cho commit/PR:
- What changed
- Why
- How to validate (lệnh dry-run/plan/lint)