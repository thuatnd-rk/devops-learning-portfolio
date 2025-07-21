# Monitoring Guide

## Tổng quan

Hệ thống monitoring được thiết lập với:
- **Prometheus**: Thu thập và lưu trữ metrics
- **Grafana**: Hiển thị dashboard và visualization
- **AlertManager**: Quản lý alerts và notifications
- **Kube-State-Metrics**: Metrics về Kubernetes objects

## Truy cập

### URLs
- **Grafana**: https://monitoring.learnaws.click/grafana
- **Prometheus**: https://monitoring.learnaws.click/prometheus

### Credentials
- **Grafana**: admin / admin123
- **Prometheus**: No authentication required

## Metrics được thu thập

### 1. Application Metrics
- **Cagent Service**: CPU, Memory, HTTP requests, response time
- **S3 Explorer Service**: CPU, Memory, HTTP requests, response time
- **PostgreSQL**: Connection count, query performance, slow queries
- **Redis**: Memory usage, connection count, hit/miss ratio

### 2. Infrastructure Metrics
- **Kubernetes Nodes**: CPU, Memory, Disk usage
- **Kubernetes Pods**: CPU, Memory, Network I/O
- **Kubernetes Services**: Request count, error rate
- **Load Balancer**: Request count, response time, error rate

### 3. Business Metrics
- **User Activity**: Active users, session duration
- **API Performance**: Endpoint response times, error rates
- **Database Performance**: Query execution time, connection pool usage

## Dashboards

### 1. System Overview
- Cluster resource usage
- Pod status and health
- Service availability
- Network traffic

### 2. Application Performance
- Request rate and response time
- Error rate and error types
- Database performance
- Cache hit/miss ratio

### 3. Infrastructure Health
- Node resource usage
- Pod resource usage
- Network performance
- Storage performance

## Alerts

### Critical Alerts
- Pod crash or restart
- High CPU/Memory usage (>80%)
- Service unavailable
- Database connection issues
- High error rate (>5%)

### Warning Alerts
- Resource usage approaching limits
- Slow response time
- High latency
- Disk space low

## Setup Instructions

### 1. Deploy Monitoring Stack
```bash
cd eks
chmod +x scripts/deploy-monitoring.sh
./scripts/deploy-monitoring.sh
```

### 2. Verify Deployment
```bash
kubectl get pods -n monitoring
kubectl get services -n monitoring
kubectl get ingress -n monitoring
```

### 3. Configure Grafana
1. Login to Grafana
2. Add Prometheus as data source
3. Import dashboards
4. Configure alerts

### 4. Configure Alerts
1. Edit AlertManager config
2. Add email/Slack notifications
3. Test alert rules

## Troubleshooting

### Common Issues

#### 1. Prometheus not scraping metrics
```bash
# Check Prometheus targets
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring
# Access http://localhost:9090/targets
```

#### 2. Grafana cannot connect to Prometheus
```bash
# Check service connectivity
kubectl exec -it <grafana-pod> -n monitoring -- curl prometheus-service:9090/api/v1/status/config
```

#### 3. Alerts not firing
```bash
# Check AlertManager status
kubectl port-forward svc/alertmanager 9093:9093 -n monitoring
# Access http://localhost:9093
```

### Debug Commands
```bash
# Check pod logs
kubectl logs -f deployment/prometheus -n monitoring
kubectl logs -f deployment/grafana -n monitoring
kubectl logs -f deployment/alertmanager -n monitoring

# Check metrics endpoint
kubectl exec -it <cagent-pod> -n vpcp-app -- curl localhost:3000/metrics

# Check service endpoints
kubectl get endpoints -n monitoring
```

## Best Practices

### 1. Resource Management
- Set appropriate resource limits
- Monitor resource usage trends
- Scale based on metrics

### 2. Alert Management
- Use meaningful alert names
- Set appropriate thresholds
- Avoid alert fatigue
- Test alerts regularly

### 3. Dashboard Management
- Create focused dashboards
- Use consistent naming
- Include relevant metrics
- Update dashboards regularly

### 4. Data Retention
- Configure appropriate retention periods
- Monitor storage usage
- Clean up old data

## Customization

### 1. Add Custom Metrics
- Instrument your application
- Expose metrics endpoint
- Configure Prometheus scraping

### 2. Create Custom Dashboards
- Design dashboard layout
- Add relevant panels
- Configure alerts

### 3. Configure Notifications
- Set up email notifications
- Configure Slack integration
- Add webhook endpoints

## Security

### 1. Access Control
- Use RBAC for service accounts
- Limit access to monitoring data
- Secure Grafana access

### 2. Data Protection
- Encrypt sensitive data
- Use secure communication
- Regular security updates

### 3. Network Security
- Use network policies
- Limit external access
- Monitor network traffic
