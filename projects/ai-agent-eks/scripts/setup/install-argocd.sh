#!/bin/bash
# Install ArgoCD on EKS cluster

set -e

NAMESPACE="argocd"
RELEASE_NAME="argocd"

echo "Installing ArgoCD..."

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Please install Helm first."
    exit 1
fi

# Add ArgoCD Helm repo
echo "Adding ArgoCD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update

# Check if ArgoCD release already exists
if helm list -n $NAMESPACE | grep -q "^$RELEASE_NAME"; then
    echo "ArgoCD release '$RELEASE_NAME' already exists. Uninstalling..."
    helm uninstall $RELEASE_NAME -n $NAMESPACE || true
    echo "Waiting for resources to be cleaned up..."
    sleep 10
fi

# Install/Upgrade ArgoCD (using upgrade --install for idempotency)
echo "Installing ArgoCD in namespace: $NAMESPACE"
helm upgrade --install $RELEASE_NAME argo/argo-cd \
  --namespace $NAMESPACE \
  --create-namespace \
  --set server.service.type=LoadBalancer \
  --set controller.nodeSelector.workload-type=application \
  --set server.nodeSelector.workload-type=application \
  --set repoServer.nodeSelector.workload-type=application \
  --set applicationSet.nodeSelector.workload-type=application \
  --set dex.nodeSelector.workload-type=application \
  --set notifications.nodeSelector.workload-type=application \
  --set redis.nodeSelector.workload-type=application \
  --wait

echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n $NAMESPACE || true

echo ""
echo "Getting ArgoCD admin password..."
sleep 10
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "Password not available yet. Please check later with: kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d")

echo ""
echo "=========================================="
echo "ArgoCD installed successfully!"
echo "=========================================="
echo "Admin username: admin"
echo "Admin password: $ARGOCD_PASSWORD"
echo ""
echo "To access ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n $NAMESPACE 8080:443"
echo "  Then open: https://localhost:8080"
echo ""
echo "Or get LoadBalancer URL:"
echo "  kubectl get svc argocd-server -n $NAMESPACE"
echo "=========================================="