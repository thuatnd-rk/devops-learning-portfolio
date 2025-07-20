# 🚀 DevOps Learning Portfolio - Projects

This directory contains practical projects demonstrating various DevOps, cloud, and infrastructure skills.

## 📋 Project Overview

### 🤖 [Chatbot RAG](./chatbot-rag/)
**AWS Bedrock Agent + Streamlit Chatbot**

A secure, production-ready chatbot using AWS Bedrock Agent with RAG (Retrieval-Augmented Generation) capabilities.

**Key Features:**
- 🔐 **Secure AWS Integration**: Uses AWS SDK default credential chain (no hardcoded credentials)
- 🤖 **Bedrock Agent**: Leverages AWS Bedrock for advanced AI capabilities
- 📊 **Streamlit UI**: Modern, responsive web interface
- 🐳 **Docker Support**: Containerized deployment
- ☁️ **ECS Deployment**: Production-ready AWS ECS deployment
- 📝 **Comprehensive Logging**: Detailed logging and monitoring

**Technologies:**
- Python 3.12+, Streamlit, AWS Bedrock
- Docker, AWS ECS, CloudWatch
- uv (Python package management)

**Quick Start:**
```bash
cd chatbot-rag
uv init -p 3.12
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt
streamlit run Chatbot.py
```

---

### 🏗️ [Infrastructure Demos](./infrastructure-demos/)
**Terraform, Kubernetes, and Infrastructure as Code**

Collection of infrastructure automation and deployment examples.

**Components:**
- **Terraform Modules**: Reusable infrastructure components
- **Kubernetes Manifests**: Container orchestration examples
- **Helm Charts**: Kubernetes application packaging

**Use Cases:**
- Multi-environment deployments
- Infrastructure automation
- Cloud-native application deployment

---

### 📊 [Monitoring Stack](./monitoring-stack/)
**Observability and Monitoring Solutions**

Complete monitoring and observability stack for production environments.

**Components:**
- **Prometheus Setup**: Metrics collection and storage
- **Grafana Dashboards**: Visualization and alerting
- **AlertManager**: Alert routing and management
- **Custom Metrics**: Application-specific monitoring

**Features:**
- Real-time metrics collection
- Custom dashboard templates
- Automated alerting
- Performance monitoring

---

## 🛠️ Technology Stack

### Cloud Platforms
- **AWS**: ECS, Bedrock, CloudWatch, IAM
- **Kubernetes**: Container orchestration
- **Terraform**: Infrastructure as Code

### Development Tools
- **Python**: Application development
- **Docker**: Containerization
- **uv**: Modern Python package management
- **Streamlit**: Web application framework

### Monitoring & Observability
- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **AlertManager**: Alert management
- **CloudWatch**: AWS monitoring

### CI/CD & DevOps
- **GitHub Actions**: Automated workflows
- **Docker Compose**: Local development
- **ECS**: Container deployment
- **Helm**: Kubernetes package management

## 📁 Project Structure

```
projects/
├── chatbot-rag/              # AI-powered chatbot
│   ├── Chatbot.py           # Main application
│   ├── Dockerfile           # Container configuration
│   ├── deploy-to-ecs.sh     # Deployment script
│   └── README.md            # Project documentation
├── infrastructure-demos/     # Infrastructure examples
│   ├── terraform-modules/   # Reusable Terraform code
│   ├── kubernetes-manifests/ # K8s deployment files
│   └── helm-charts/         # Helm package charts
├── monitoring-stack/         # Monitoring solutions
│   ├── prometheus-setup/    # Metrics collection
│   ├── grafana-dashboards/  # Visualization
│   └── alertmanager/        # Alert management
└── README.md               # This file
```

## 🎯 Learning Objectives

### DevOps Skills
- **Infrastructure as Code**: Terraform, CloudFormation
- **Container Orchestration**: Kubernetes, ECS
- **CI/CD Pipelines**: GitHub Actions, automated deployment
- **Monitoring & Observability**: Prometheus, Grafana, CloudWatch

### Cloud Skills
- **AWS Services**: ECS, Bedrock, IAM, CloudWatch
- **Security**: IAM roles, credential management
- **Scalability**: Auto-scaling, load balancing
- **Cost Optimization**: Resource management

### Development Skills
- **Python Development**: Modern Python practices
- **API Development**: RESTful services
- **Frontend Development**: Streamlit web applications
- **Testing**: Unit tests, integration tests

## 🚀 Getting Started

### Prerequisites
- Python 3.12+
- Docker
- AWS CLI (for cloud projects)
- Kubernetes cluster (for K8s projects)

### Common Setup
```bash
# Clone the repository
git clone <repository-url>
cd projects

# Choose a project
cd chatbot-rag

# Follow project-specific setup instructions
# See individual project README files
```

## 📚 Documentation

Each project contains detailed documentation:
- **Setup Instructions**: Step-by-step configuration
- **Architecture Diagrams**: System design and components
- **API Documentation**: Service interfaces
- **Deployment Guides**: Production deployment steps

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/new-project`
3. **Make your changes**: Follow project-specific guidelines
4. **Test thoroughly**: Ensure all functionality works
5. **Submit a pull request**: Include detailed description

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](../LICENSE) file for details.

## 🔗 Related Resources

- [Learning Paths](../learning/) - Structured learning materials
- [Certifications](../certifications/) - Professional certifications
- [Blog Posts](../blog-posts/) - Technical articles and tutorials
- [Tools & Scripts](../tools-scripts/) - Automation utilities

---

**🎓 Learning Portfolio by [Your Name]**  
*Building practical DevOps skills through hands-on projects*
