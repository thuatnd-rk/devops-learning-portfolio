#!/bin/bash
# Script to install AWS Load Balancer Controller on EKS
# Docs: https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html
#
# Usage:
#   ./install-aws-lbc.sh
#   CLUSTER_NAME=my-cluster AWS_REGION=us-east-1 ./install-aws-lbc.sh

set -e  # Exit on error

echo "========================================="
echo "AWS Load Balancer Controller Installation"
echo "========================================="

# Các biến có thể được truyền vào hoặc tự động phát hiện
CLUSTER_NAME=${CLUSTER_NAME:-""}
AWS_REGION=${AWS_REGION:-""}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-""}
VPC_ID=${VPC_ID:-""}
LBC_VERSION=${LBC_VERSION:-"1.14.0"}

# Tự động phát hiện AWS Region
if [ -z "$AWS_REGION" ]; then
    AWS_REGION=$(aws configure get region 2>/dev/null || echo "")
    if [ -z "$AWS_REGION" ]; then
        # Thử lấy từ metadata service (nếu đang chạy trên EC2)
        AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null || echo "")
    fi
    if [ -z "$AWS_REGION" ]; then
        echo "❌ Error: AWS_REGION không được tìm thấy."
        echo "   Vui lòng set biến: export AWS_REGION=us-east-1"
        echo "   hoặc chạy: aws configure set region us-east-1"
        exit 1
    fi
fi
echo "✓ Region: $AWS_REGION"

# Tự động phát hiện Cluster Name từ kubeconfig
if [ -z "$CLUSTER_NAME" ]; then
    # Thử lấy từ kubeconfig context
    CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}' 2>/dev/null | sed 's/.*\///' || echo "")
    
    # Nếu không có, thử lấy từ current context
    if [ -z "$CLUSTER_NAME" ]; then
        CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "")
        if [ -n "$CURRENT_CONTEXT" ]; then
            CLUSTER_NAME=$(echo "$CURRENT_CONTEXT" | cut -d'/' -f2 | cut -d'.' -f1 || echo "")
        fi
    fi
    
    if [ -z "$CLUSTER_NAME" ]; then
        echo "❌ Error: CLUSTER_NAME không được tìm thấy."
        echo "   Vui lòng set biến: export CLUSTER_NAME=my-cluster"
        exit 1
    fi
fi
echo "✓ Cluster Name: $CLUSTER_NAME"

# Tự động lấy AWS Account ID
if [ -z "$AWS_ACCOUNT_ID" ]; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        echo "❌ Error: Không thể lấy AWS Account ID."
        echo "   Vui lòng kiểm tra AWS credentials: aws sts get-caller-identity"
        exit 1
    fi
fi
echo "✓ AWS Account ID: $AWS_ACCOUNT_ID"

# Tự động lấy VPC ID từ cluster (cần thiết cho IMDS hop limit = 1)
if [ -z "$VPC_ID" ]; then
    VPC_ID=$(aws eks describe-cluster \
        --name "$CLUSTER_NAME" \
        --region "$AWS_REGION" \
        --query "cluster.resourcesVpcConfig.vpcId" \
        --output text 2>/dev/null)
    
    if [ -z "$VPC_ID" ]; then
        echo "❌ Error: Không thể lấy VPC ID từ cluster $CLUSTER_NAME"
        echo "   Vui lòng kiểm tra cluster name và AWS credentials"
        exit 1
    fi
fi
echo "✓ VPC ID: $VPC_ID"

echo "========================================="
echo ""

# Step 1: Create IAM Policy
echo "📋 Step 1: Creating IAM Policy..."
if [ ! -f "iam_policy.json" ]; then
    echo "   Downloading IAM policy..."
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json
else
    echo "   IAM policy file already exists, skipping download"
fi

echo "   Creating IAM policy..."
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json 2>/dev/null || {
    echo "   ⚠️  Policy có thể đã tồn tại, tiếp tục..."
}

POLICY_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy"
echo "   ✓ Policy ARN: $POLICY_ARN"
echo ""

# Step 2: Create IAM Service Account
echo "📋 Step 2: Creating IAM Service Account..."
eksctl create iamserviceaccount \
    --cluster="$CLUSTER_NAME" \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn="$POLICY_ARN" \
    --override-existing-serviceaccounts \
    --region "$AWS_REGION" \
    --approve

echo "   ✓ IAM Service Account created"
echo ""

# Step 3: Add Helm Repository
echo "📋 Step 3: Adding Helm Repository..."
helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || {
    echo "   ⚠️  Repository có thể đã được thêm, tiếp tục..."
}
helm repo update eks
echo "   ✓ Helm repository updated"
echo ""

# Step 4: Install AWS Load Balancer Controller
echo "📋 Step 4: Installing AWS Load Balancer Controller..."
echo "   Cluster: $CLUSTER_NAME"
echo "   Region: $AWS_REGION"
echo "   VPC ID: $VPC_ID"
echo "   Version: $LBC_VERSION"
echo ""

# Kiểm tra xem đã cài đặt chưa
if helm list -n kube-system | grep -q aws-load-balancer-controller; then
    echo "   ⚠️  AWS Load Balancer Controller đã được cài đặt."
    read -p "   Bạn có muốn upgrade? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Upgrading..."
        helm upgrade aws-load-balancer-controller eks/aws-load-balancer-controller \
          -n kube-system \
          --set clusterName="$CLUSTER_NAME" \
          --set serviceAccount.create=false \
          --set serviceAccount.name=aws-load-balancer-controller \
          --set region="$AWS_REGION" \
          --set vpcId="$VPC_ID" \
          --version "$LBC_VERSION" \
          --wait
        echo "   ✓ Upgrade completed"
    else
        echo "   Skipping installation"
    fi
else
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
      -n kube-system \
      --set clusterName="$CLUSTER_NAME" \
      --set serviceAccount.create=false \
      --set serviceAccount.name=aws-load-balancer-controller \
      --set region="$AWS_REGION" \
      --set vpcId="$VPC_ID" \
      --version "$LBC_VERSION" \
      --wait
    
    echo "   ✓ Installation completed"
fi
echo ""

# Step 5: Verify Installation
echo "📋 Step 5: Verifying Installation..."
echo ""
echo "Deployment status:"
kubectl get deployment -n kube-system aws-load-balancer-controller
echo ""
echo "Pod status:"
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
echo ""

# Kiểm tra pods đang chạy
READY_PODS=$(kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --no-headers 2>/dev/null | grep -c "Running" || echo "0")
if [ "$READY_PODS" -gt 0 ]; then
    echo "✅ AWS Load Balancer Controller đã được cài đặt thành công!"
    echo ""
    echo "Để xem logs:"
    echo "  kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller"
else
    echo "⚠️  Pods chưa sẵn sàng. Vui lòng kiểm tra lại sau vài giây:"
    echo "  kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller"
fi
