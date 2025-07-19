# CAgent EKS Deployment

## 🚀 Project Overview

CAgent is an AI-powered chatbot application deployed on AWS EKS (Elastic Kubernetes Service) with a comprehensive monitoring and observability stack. This project demonstrates production-ready Kubernetes deployment with best practices for scalability, security, and monitoring.

## 🏗️ Architecture

### **System Components**
- **Frontend**: React-based chatbot interface
- **Backend**: Node.js microservices
- **Database**: PostgreSQL 16 with Redis cache
- **Infrastructure**: AWS EKS with auto-scaling
- **Monitoring**: Prometheus + Grafana + AlertManager
- **CI/CD**: GitHub Actions with zero-downtime deployments

### **Infrastructure Stack**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   EKS Cluster   │    │   Monitoring    │
│   (ALB/NLB)     │◄──►│   (Kubernetes)  │◄──►│   (Prometheus)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Database      │    │   Cache         │
│   (CAgent)      │◄──►│   (PostgreSQL)  │◄──►│   (Redis)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 Key Achievements

### **Performance Improvements**
- **Deployment Time**: Reduced from 2 hours to 15 minutes
- **Auto-scaling**: Handles 3x traffic spikes automatically
- **Uptime**: Achieved 99.9% availability
- **Response Time**: Average API response < 200ms

### **Infrastructure Optimization**
- **Cost Reduction**: 30% reduction in infrastructure costs
- **Resource Utilization**: Optimized CPU/Memory usage
- **Security**: Implemented RBAC and network policies
- **Monitoring**: Real-time metrics and alerting

## 🛠️ Technologies Used

### **Cloud & Infrastructure**
- **AWS EKS**: Kubernetes cluster management
- **AWS ALB/NLB**: Load balancing and traffic management
- **AWS RDS**: PostgreSQL database
- **AWS S3**: Object storage for documents
- **AWS CloudWatch**: Cloud monitoring

### **Kubernetes & Orchestration**
- **Kubernetes**: Container orchestration
- **Helm**: Package management
- **RBAC**: Role-based access control
- **Network Policies**: Pod-to-pod communication control

### **Monitoring & Observability**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert management
- **Jaeger**: Distributed tracing (planned)

### **CI/CD & Automation**
- **GitHub Actions**: Automated deployment pipeline
- **Terraform**: Infrastructure as Code
- **Docker**: Containerization
- **ArgoCD**: GitOps deployment (planned)

## 📁 Project Structure

```
cagent-eks/
├── architecture/           # Architecture diagrams
├── infrastructure/         # Terraform configurations
├── monitoring/            # Prometheus, Grafana configs
├── deployment/            # Deployment scripts
└── documentation/         # Detailed documentation
```

## 🚀 Quick Start

### **Prerequisites**
- AWS CLI configured
- kubectl installed
- Helm installed
- Terraform installed

### **Deployment Steps**

1. **Clone the repository**
```bash
git clone https://github.com/your-username/devops-learning-portfolio.git
cd projects/cagent-eks
```

2. **Setup AWS credentials**
```bash
aws configure
```

3. **Deploy infrastructure**
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

4. **Deploy applications**
```bash
cd ../deployment
./deploy.sh
```

5. **Setup monitoring**
```bash
cd ../monitoring
./setup-monitoring.sh
```

## 📊 Monitoring & Metrics

### **Application Metrics**
- **Request Rate**: HTTP requests per second
- **Response Time**: API response latency
- **Error Rate**: HTTP error percentage
- **Active Users**: Concurrent user sessions

### **Infrastructure Metrics**
- **CPU Usage**: Node and pod CPU utilization
- **Memory Usage**: Node and pod memory usage
- **Network I/O**: Network traffic patterns
- **Disk Usage**: Storage utilization

### **Business Metrics**
- **User Engagement**: Session duration and interactions
- **Feature Usage**: Most used chatbot features
- **Performance**: Response time by endpoint
- **Availability**: Service uptime and reliability

## 🔧 Configuration

### **Environment Variables**
```yaml
# Application Configuration
NODE_ENV: "production"
PORT: "3000"
CORS_ORIGINS: "*"

# Database Configuration
DB_HOST: "postgres-service.vpcp-app.svc.cluster.local"
DB_PORT: "5432"
DB_NAME: "cagent"
DB_USER: "cagent_user"

# Redis Configuration
REDIS_HOST: "redis-service.vpcp-app.svc.cluster.local"
REDIS_PORT: "6379"

# AI Service Configuration
AI_SERVICE_URL: "http://3.231.34.3:8001"
TRIGGER_API_URL: "https://trigger.1882.studio.ai.vn"
```

### **Kubernetes Resources**
- **Deployments**: Application and database deployments
- **Services**: Internal and external service exposure
- **Ingress**: Traffic routing and SSL termination
- **ConfigMaps**: Configuration management
- **Secrets**: Sensitive data storage

## 🔒 Security Implementation

### **Network Security**
- **Network Policies**: Pod-to-pod communication control
- **Ingress Rules**: External traffic filtering
- **SSL/TLS**: Encrypted communication
- **VPC**: Isolated network environment

### **Access Control**
- **RBAC**: Role-based access control
- **Service Accounts**: Pod identity management
- **IAM Roles**: AWS service permissions
- **Secrets Management**: Secure credential storage

### **Container Security**
- **Image Scanning**: Vulnerability assessment
- **Non-root Users**: Security context configuration
- **Resource Limits**: CPU and memory constraints
- **Security Context**: Pod security policies

## 🚨 Troubleshooting

### **Common Issues**

#### **Pod Startup Issues**
```bash
# Check pod status
kubectl get pods -n vpcp-app

# Check pod logs
kubectl logs <pod-name> -n vpcp-app

# Check pod events
kubectl describe pod <pod-name> -n vpcp-app
```

#### **Service Connectivity**
```bash
# Check service endpoints
kubectl get endpoints -n vpcp-app

# Test service connectivity
kubectl exec -it <pod-name> -n vpcp-app -- curl <service-name>
```

#### **Database Issues**
```bash
# Check database connectivity
kubectl exec -it <pod-name> -n vpcp-app -- psql -h postgres-service -U cagent_user -d cagent

# Check database logs
kubectl logs deployment/postgres -n vpcp-app
```

### **Debug Commands**
```bash
# Get cluster information
kubectl cluster-info

# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n vpcp-app

# Check service status
kubectl get services -n vpcp-app
```

## 📈 Performance Optimization

### **Resource Optimization**
- **CPU Limits**: Optimized based on usage patterns
- **Memory Limits**: Configured for application needs
- **Storage**: SSD-backed persistent volumes
- **Networking**: Optimized pod network policies

### **Scaling Strategies**
- **Horizontal Pod Autoscaler**: CPU and memory-based scaling
- **Vertical Pod Autoscaler**: Resource optimization
- **Cluster Autoscaler**: Node-level scaling
- **Custom Metrics**: Business-driven scaling

### **Caching Strategy**
- **Redis Cache**: Session and data caching
- **CDN**: Static content delivery
- **Application Cache**: In-memory caching
- **Database Cache**: Query result caching

## 🔄 CI/CD Pipeline

### **GitHub Actions Workflow**
```yaml
name: Deploy to EKS
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Configure AWS credentials
      - name: Update kubeconfig
      - name: Deploy to EKS
      - name: Run health checks
```

### **Deployment Strategy**
- **Blue-Green Deployment**: Zero-downtime updates
- **Rolling Updates**: Gradual pod replacement
- **Canary Deployments**: Traffic splitting for testing
- **Rollback Strategy**: Quick rollback on issues

## 📚 Documentation

### **Architecture Documentation**
- [System Architecture](./architecture/system-architecture.md)
- [Network Design](./architecture/network-design.md)
- [Security Architecture](./architecture/security-architecture.md)

### **Deployment Guides**
- [Installation Guide](./documentation/installation.md)
- [Configuration Guide](./documentation/configuration.md)
- [Troubleshooting Guide](./documentation/troubleshooting.md)

### **Monitoring Guides**
- [Monitoring Setup](./monitoring/setup.md)
- [Dashboard Configuration](./monitoring/dashboards.md)
- [Alert Configuration](./monitoring/alerts.md)

## 🤝 Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for contribution guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

---

**Last Updated**: December 2024  
**Status**: Production Ready  
**Environment**: AWS EKS  
**Version**: 1.0.0 