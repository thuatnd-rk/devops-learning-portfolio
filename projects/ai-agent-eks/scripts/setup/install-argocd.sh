#!/bin/bash
# Script to install ArgoCD on EKS
# Docs: https://argo-cd.readthedocs.io/en/stable/
#
# Usage:
#   ./install-argocd.sh
#   ARGOCD_NAMESPACE=argocd ARGOCD_VERSION=7.5.0 ./install-argocd.sh

set -e  # Exit on error

echo "========================================="
echo "ArgoCD Installation on EKS"
echo "========================================="

# Các biến có thể được truyền vào
ARGOCD_NAMESPACE=${ARGOCD_NAMESPACE:-"argocd"}
ARGOCD_VERSION=${ARGOCD_VERSION:-"7.5.0"}

echo "✓ Namespace: $ARGOCD_NAMESPACE"
echo "✓ Version: $ARGOCD_VERSION"
echo ""

# Step 1: Create namespace
echo "📋 Step 1: Creating namespace..."
kubectl create namespace "$ARGOCD_NAMESPACE" 2>/dev/null || {
    echo "   ⚠️  Namespace đã tồn tại, tiếp tục..."
}
echo "   ✓ Namespace created"
echo ""

# Step 2: Add ArgoCD Helm repository
echo "📋 Step 2: Adding ArgoCD Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || {
    echo "   ⚠️  Repository có thể đã được thêm, tiếp tục..."
}
helm repo update argo
echo "   ✓ Helm repository updated"
echo ""

# Step 3: Install ArgoCD using Helm
echo "📋 Step 3: Installing ArgoCD..."
echo "   This may take a few minutes..."

# Kiểm tra xem đã cài đặt chưa
if helm list -n "$ARGOCD_NAMESPACE" | grep -q argocd; then
    echo "   ⚠️  ArgoCD đã được cài đặt."
    read -p "   Bạn có muốn upgrade? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Upgrading..."
        helm upgrade argocd argo/argo-cd \
          -n "$ARGOCD_NAMESPACE" \
          --version "$ARGOCD_VERSION" \
          --set server.service.type=ClusterIP \
          --wait
        echo "   ✓ Upgrade completed"
    else
        echo "   Skipping installation"
    fi
else
    helm install argocd argo/argo-cd \
      -n "$ARGOCD_NAMESPACE" \
      --version "$ARGOCD_VERSION" \
      --set server.service.type=ClusterIP \
      --wait
    
    echo "   ✓ Installation completed"
fi
echo ""

# Step 4: Wait for ArgoCD to be ready
echo "📋 Step 4: Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n "$ARGOCD_NAMESPACE" || {
    echo "   ⚠️  Timeout waiting for ArgoCD server. Please check manually."
}
echo "   ✓ ArgoCD is ready"
echo ""

# Step 5: Get initial admin password
echo "📋 Step 5: Getting initial admin password..."
ARGOCD_PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "")

if [ -n "$ARGOCD_PASSWORD" ]; then
    echo ""
    echo "========================================="
    echo "ArgoCD Installation Completed!"
    echo "========================================="
    echo ""
    echo "📝 Initial Admin Credentials:"
    echo "   Username: admin"
    echo "   Password: $ARGOCD_PASSWORD"
    echo ""
    echo "💾 Save this password securely!"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Install ArgoCD CLI (optional):"
    echo "      curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
    echo "      chmod +x /usr/local/bin/argocd"
    echo ""
    echo "   2. Port-forward to access UI (temporary):"
    echo "      kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443"
    echo "      Then access: https://localhost:8080"
    echo ""
    echo "   3. Create Ingress for ArgoCD UI:"
    echo "      kubectl apply -f kubernetes/ingress/argocd-ingress.yaml"
    echo ""
    echo "   4. Login via CLI:"
    echo "      argocd login <ARGOCD_SERVER_URL> --username admin --password '$ARGOCD_PASSWORD'"
    echo ""
else
    echo "   ⚠️  Could not retrieve admin password. It may have been changed."
    echo "   You can reset it using:"
    echo "   kubectl -n $ARGOCD_NAMESPACE patch secret argocd-secret \\"
    echo "     -p '{\"stringData\":{\"admin.password\":\"\$(bcrypt <new-password> | tr -d '\\n')\",\"admin.passwordMtime\":\"'\$(date +%FT%T%Z)'\"}}'"
fi

# Step 6: Verify Installation
echo "📋 Step 6: Verifying Installation..."
echo ""
echo "ArgoCD Pods:"
kubectl get pods -n "$ARGOCD_NAMESPACE"
echo ""
echo "ArgoCD Services:"
kubectl get svc -n "$ARGOCD_NAMESPACE"
echo ""

echo "✅ ArgoCD installation script completed!"
