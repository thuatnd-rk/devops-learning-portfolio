#!/bin/bash

echo "🚀 Deploying Monitoring Stack..."

# Create namespace
echo "📦 Creating monitoring namespace..."
kubectl apply -f manifests/namespaces/monitoring-namespace.yaml

# Create service accounts
echo "👤 Creating service accounts..."
kubectl apply -f manifests/service-accounts/prometheus-sa.yaml
kubectl apply -f manifests/service-accounts/kube-state-metrics-sa.yaml

# Create RBAC
echo "🔐 Creating RBAC..."
kubectl apply -f manifests/rbac/kube-state-metrics-rbac.yaml

# Create ConfigMaps
echo "⚙️ Creating ConfigMaps..."
kubectl apply -f manifests/monitoring/prometheus/prometheus-config.yaml
kubectl apply -f manifests/monitoring/alertmanager/alertmanager-config.yaml
kubectl apply -f manifests/monitoring/grafana/grafana-datasources.yaml
kubectl apply -f manifests/monitoring/grafana/grafana-dashboards.yaml

# Deploy kube-state-metrics
echo "📊 Deploying kube-state-metrics..."
kubectl apply -f manifests/monitoring/kube-state-metrics/kube-state-metrics-deployment.yaml
kubectl apply -f manifests/monitoring/kube-state-metrics/kube-state-metrics-service.yaml

# Deploy AlertManager
echo "🚨 Deploying AlertManager..."
kubectl apply -f manifests/monitoring/alertmanager/alertmanager-deployment.yaml
kubectl apply -f manifests/monitoring/alertmanager/alertmanager-service.yaml

# Deploy Prometheus
echo "📈 Deploying Prometheus..."
kubectl apply -f manifests/monitoring/prometheus/prometheus-deployment.yaml
kubectl apply -f manifests/monitoring/prometheus/prometheus-service.yaml

# Deploy Grafana
echo "📊 Deploying Grafana..."
kubectl apply -f manifests/monitoring/grafana/grafana-deployment.yaml
kubectl apply -f manifests/monitoring/grafana/grafana-service.yaml

# Deploy Ingress
echo "🌐 Deploying Ingress..."
kubectl apply -f manifests/ingress/monitoring-ingress.yaml

echo "✅ Monitoring stack deployed successfully!"
echo ""
echo "📋 Access URLs:"
echo "   Grafana: https://monitoring.learnaws.click/grafana"
echo "   Prometheus: https://monitoring.learnaws.click/prometheus"
echo ""
echo "🔑 Default credentials:"
echo "   Grafana: admin / admin123"
echo ""
echo "📊 Check status:"
echo "   kubectl get pods -n monitoring"
echo "   kubectl get services -n monitoring"
echo "   kubectl get ingress -n monitoring" 