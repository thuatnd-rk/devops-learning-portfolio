#!/bin/bash

# Safe ECS deployment script with credential validation

set -e  # Exit on any error

# Configuration
REGION="ap-southeast-1"
CLUSTER_NAME="bedrock-chatbot-cluster"
SERVICE_NAME="bedrock-chatbot-service"
TASK_FAMILY="bedrock-agent-chatbot"
ECR_REPOSITORY="187091248012.dkr.ecr.ap-southeast-1.amazonaws.com/genai-poc-registry"
SECRET_NAME="bedrock-chatbot"

echo "🚀 Starting ECS Deployment Process..."
echo "=================================="

# Function to check if AWS CLI is configured
check_aws_cli() {
    echo "🔍 Checking AWS CLI configuration..."
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        echo "❌ AWS CLI not configured or no permissions"
        exit 1
    fi
    echo "✅ AWS CLI configured successfully"
}

# Function to validate secrets
validate_secrets() {
    echo "🔐 Validating AWS Secrets Manager..."
    
    # Check if secret exists and has required keys
    if ! aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$REGION" > /dev/null 2>&1; then
        echo "❌ Secret '$SECRET_NAME' not found in Secrets Manager"
        echo "💡 Run: python fix-ecs-credentials.py to set up secrets"
        exit 1
    fi
    
    # Get secret and check keys
    SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$REGION" --query 'SecretString' --output text)
    
    REQUIRED_KEYS=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "AGENT_ID" "ALIAS_ID")
    
    for key in "${REQUIRED_KEYS[@]}"; do
        if ! echo "$SECRET_JSON" | jq -e ".$key" > /dev/null 2>&1; then
            echo "❌ Missing key '$key' in secret"
            echo "💡 Run: python fix-ecs-credentials.py to fix secrets"
            exit 1
        fi
    done
    
    echo "✅ All required secrets are present"
}

# Function to build and push Docker image
build_and_push() {
    echo "🐳 Building and pushing Docker image..."
    
    # Get ECR login token
    aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR_REPOSITORY"
    
    # Build image
    echo "🔨 Building Docker image..."
    docker build -t genai-poc .
    
    # Tag image
    docker tag genai-poc:latest "$ECR_REPOSITORY:latest"
    
    # Push image
    echo "📤 Pushing image to ECR..."
    docker push "$ECR_REPOSITORY:latest"
    
    echo "✅ Image pushed successfully"
}

# Function to register new task definition
register_task_definition() {
    echo "📋 Registering new task definition..."
    
    # Register the task definition
    TASK_DEF_ARN=$(aws ecs register-task-definition \
        --cli-input-json file://ecs-task-definition.json \
        --region "$REGION" \
        --query 'taskDefinition.taskDefinitionArn' \
        --output text)
    
    echo "✅ Task definition registered: $TASK_DEF_ARN"
    echo "$TASK_DEF_ARN"
}

# Function to update ECS service
update_service() {
    local task_def_arn=$1
    
    echo "🔄 Updating ECS service..."
    
    # Update service with new task definition
    aws ecs update-service \
        --cluster "$CLUSTER_NAME" \
        --service "$SERVICE_NAME" \
        --task-definition "$task_def_arn" \
        --force-new-deployment \
        --region "$REGION" > /dev/null
    
    echo "✅ Service update initiated"
}

# Function to wait for deployment
wait_for_deployment() {
    echo "⏳ Waiting for deployment to complete..."
    
    # Wait for service to stabilize
    aws ecs wait services-stable \
        --cluster "$CLUSTER_NAME" \
        --services "$SERVICE_NAME" \
        --region "$REGION"
    
    echo "✅ Deployment completed successfully"
}

# Function to check service health
check_service_health() {
    echo "🏥 Checking service health..."
    
    # Get service status
    SERVICE_STATUS=$(aws ecs describe-services \
        --cluster "$CLUSTER_NAME" \
        --services "$SERVICE_NAME" \
        --region "$REGION" \
        --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}' \
        --output json)
    
    echo "📊 Service Status:"
    echo "$SERVICE_STATUS" | jq .
    
    # Check if service is running
    RUNNING_COUNT=$(echo "$SERVICE_STATUS" | jq -r '.Running')
    DESIRED_COUNT=$(echo "$SERVICE_STATUS" | jq -r '.Desired')
    
    if [ "$RUNNING_COUNT" -eq "$DESIRED_COUNT" ] && [ "$RUNNING_COUNT" -gt 0 ]; then
        echo "✅ Service is healthy"
        return 0
    else
        echo "⚠️  Service may not be fully healthy"
        return 1
    fi
}

# Function to show logs
show_recent_logs() {
    echo "📝 Recent application logs:"
    echo "=========================="
    
    # Get recent logs
    aws logs tail "/ecs/bedrock-agent-chatbot" \
        --since 5m \
        --region "$REGION" \
        --format short || echo "No recent logs found"
}

# Main deployment process
main() {
    echo "Starting deployment at $(date)"
    
    # Pre-deployment checks
    check_aws_cli
    validate_secrets
    
    # Build and deploy
    build_and_push
    TASK_DEF_ARN=$(register_task_definition)
    update_service "$TASK_DEF_ARN"
    
    # Wait and verify
    wait_for_deployment
    
    if check_service_health; then
        echo ""
        echo "🎉 Deployment successful!"
        echo "========================"
        echo "Service URL: http://your-load-balancer-url:8501"
        echo ""
        echo "📝 To monitor logs:"
        echo "aws logs tail /ecs/bedrock-agent-chatbot --follow --region $REGION"
        echo ""
        echo "🔍 To check service status:"
        echo "aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $REGION"
    else
        echo ""
        echo "⚠️  Deployment completed but service may have issues"
        echo "Check the logs for more details:"
        show_recent_logs
    fi
}

# Handle script arguments
case "${1:-deploy}" in
    "deploy")
        main
        ;;
    "logs")
        show_recent_logs
        ;;
    "status")
        check_service_health
        ;;
    "secrets")
        validate_secrets
        ;;
    *)
        echo "Usage: $0 [deploy|logs|status|secrets]"
        echo "  deploy  - Full deployment (default)"
        echo "  logs    - Show recent logs"
        echo "  status  - Check service status"
        echo "  secrets - Validate secrets configuration"
        exit 1
        ;;
esac
