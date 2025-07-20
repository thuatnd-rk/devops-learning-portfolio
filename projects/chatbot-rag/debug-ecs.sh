#!/bin/bash

# Script để debug ECS deployment issues

echo "🔍 Debugging ECS Deployment..."

CLUSTER_NAME="bedrock-chatbot-cluster"
SERVICE_NAME="bedrock-chatbot-service"
REGION="ap-southeast-1"

# 1. Kiểm tra service status
echo "📊 Checking ECS Service Status..."
aws ecs describe-services \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --region $REGION \
    --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount,TaskDefinition:taskDefinition}'

# 2. Lấy task ARNs
echo "📋 Getting running tasks..."
TASK_ARNS=$(aws ecs list-tasks \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --region $REGION \
    --query 'taskArns[0]' \
    --output text)

if [ "$TASK_ARNS" = "None" ] || [ -z "$TASK_ARNS" ]; then
    echo "❌ No running tasks found!"
    echo "🔍 Checking stopped tasks..."
    
    STOPPED_TASKS=$(aws ecs list-tasks \
        --cluster $CLUSTER_NAME \
        --desired-status STOPPED \
        --region $REGION \
        --query 'taskArns[0]' \
        --output text)
    
    if [ "$STOPPED_TASKS" != "None" ] && [ -n "$STOPPED_TASKS" ]; then
        echo "📋 Describing stopped task..."
        aws ecs describe-tasks \
            --cluster $CLUSTER_NAME \
            --tasks $STOPPED_TASKS \
            --region $REGION \
            --query 'tasks[0].{StoppedReason:stoppedReason,StoppedAt:stoppedAt,Containers:containers[0].{Name:name,ExitCode:exitCode,Reason:reason}}'
    fi
    exit 1
fi

echo "✅ Found running task: $TASK_ARNS"

# 3. Kiểm tra task details
echo "📋 Checking task details..."
aws ecs describe-tasks \
    --cluster $CLUSTER_NAME \
    --tasks $TASK_ARNS \
    --region $REGION \
    --query 'tasks[0].{LastStatus:lastStatus,HealthStatus:healthStatus,CreatedAt:createdAt,Connectivity:connectivity}'

# 4. Kiểm tra logs
echo "📝 Checking CloudWatch logs..."
LOG_GROUP="/ecs/bedrock-agent-chatbot"

# Lấy log streams
LOG_STREAMS=$(aws logs describe-log-streams \
    --log-group-name $LOG_GROUP \
    --region $REGION \
    --order-by LastEventTime \
    --descending \
    --max-items 1 \
    --query 'logStreams[0].logStreamName' \
    --output text)

if [ "$LOG_STREAMS" != "None" ] && [ -n "$LOG_STREAMS" ]; then
    echo "📖 Latest log stream: $LOG_STREAMS"
    echo "📝 Recent logs:"
    aws logs get-log-events \
        --log-group-name $LOG_GROUP \
        --log-stream-name $LOG_STREAMS \
        --region $REGION \
        --start-from-head \
        --query 'events[-20:].{Time:timestamp,Message:message}' \
        --output table
else
    echo "❌ No log streams found in $LOG_GROUP"
fi

# 5. Kiểm tra parameters
echo "🔐 Checking Parameter Store values..."
aws ssm get-parameters \
    --names "/bedrock-chatbot/agent-id" "/bedrock-chatbot/alias-id" \
    --region $REGION \
    --query 'Parameters[].{Name:Name,Value:Value}' \
    --output table

echo ""
echo "🔍 Debug commands you can run manually:"
echo "1. View live logs: aws logs tail $LOG_GROUP --follow --region $REGION"
echo "2. Check task definition: aws ecs describe-task-definition --task-definition bedrock-agent-chatbot --region $REGION"
echo "3. Check service events: aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $REGION --query 'services[0].events'"
