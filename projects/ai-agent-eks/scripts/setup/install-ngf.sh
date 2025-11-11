#!/bin/bash

# Setup Nginx Gateway Fabric
# Docs: https://docs.nginx.com/nginx-gateway-fabric/install/helm/

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Setting up Nginx Gateway Fabric"
echo "=========================================="

# I. Install Gateway API CRDs
echo ""
echo "I. Installing Gateway API CRDs..."
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.2.0" | kubectl apply -f -

echo ""
echo "Verifying CRDs installation..."
kubectl get crd | grep gateway || echo "Warning: No gateway CRDs found"

# II. Install Nginx Gateway Fabric Controller
echo ""
echo "II. Installing Nginx Gateway Fabric Controller..."
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --create-namespace -n nginx-gateway \
  --set nginx.service.type=LoadBalancer

echo ""
echo "Waiting for controller to be ready..."
kubectl wait --for=condition=ready pod -l app=nginx-gateway-fabric -n nginx-gateway --timeout=300s || echo "Warning: Pods may not be ready yet"

echo ""
echo "Verifying installation..."
kubectl get pod -n nginx-gateway
kubectl get svc -n nginx-gateway
kubectl get gatewayclass

echo ""
echo "=========================================="
echo "Nginx Gateway Fabric setup completed!"
echo "=========================================="

# ==========================================
# NEXT STEPS / SUGGESTED ACTIONS
# ==========================================
echo ""
echo "=========================================="
echo "NEXT STEPS / SUGGESTED ACTIONS:"
echo "=========================================="
echo ""

# III. Create Gateway and HTTPRoute
echo "III. Create Gateway and HTTPRoute"
echo "-----------------------------------"
echo ""
echo "Create gateway.yaml:"
echo ""
cat <<'GATEWAY_EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: nginx-gateway
spec:
  gatewayClassName: nginx
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
GATEWAY_EOF

echo ""
echo "Create httproute.yaml:"
echo ""
cat <<'HTTPROUTE_EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: coffee-routes
  namespace: default
spec:
  parentRefs:
    - name: main-gateway
      namespace: nginx-gateway
      sectionName: http
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /coffee
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
      backendRefs:
        - name: coffee
          port: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: tea-routes
  namespace: default
spec:
  parentRefs:
    - name: main-gateway
      namespace: nginx-gateway
      sectionName: http
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /tea
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
      backendRefs:
        - name: tea
          port: 80
HTTPROUTE_EOF

echo ""
echo "Then apply:"
echo "  kubectl apply -f gateway.yaml"
echo ""
echo "Verify:"
echo "  kubectl get gateway -n nginx-gateway"
echo "  kubectl get pod -n nginx-gateway"
echo "  kubectl get svc -n nginx-gateway"
echo ""
echo "  kubectl apply -f httproute.yaml"
echo ""

# IV. Create applications
echo "IV. Create applications (coffee and tea)"
echo "-----------------------------------"
echo ""
echo "Create coffee.yaml:"
echo ""
cat <<'COFFEE_EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coffee-deployment
  namespace: default
  labels:
    app: coffee
spec:
  replicas: 2
  selector:
    matchLabels:
      app: coffee
  template:
    metadata:
      labels:
        app: coffee
    spec:
      containers:
      - name: coffee-container
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: coffee-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coffee-html
  namespace: default
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Coffee Shop</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background: linear-gradient(135deg, #8B4513 0%, #D2691E 100%);
          color: white;
          text-align: center;
          padding: 50px;
        }
        h1 { font-size: 3em; margin-bottom: 20px; }
        p { font-size: 1.5em; }
      </style>
    </head>
    <body>
      <h1>☕ Coffee Shop</h1>
      <p>Welcome to our Coffee Service!</p>
      <p>Enjoy your favorite coffee ☕</p>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: coffee
  namespace: default
spec:
  selector:
    app: coffee
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
COFFEE_EOF

echo ""
echo "Create tea.yaml:"
echo ""
cat <<'TEA_EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tea-deployment
  namespace: default
  labels:
    app: tea
spec:
  replicas: 2
  selector:
    matchLabels:
      app: tea
  template:
    metadata:
      labels:
        app: tea
    spec:
      containers:
      - name: tea-container
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: tea-html
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: tea-html
  namespace: default
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Tea Shop</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background: linear-gradient(135deg, #228B22 0%, #90EE90 100%);
          color: white;
          text-align: center;
          padding: 50px;
        }
        h1 { font-size: 3em; margin-bottom: 20px; }
        p { font-size: 1.5em; }
      </style>
    </head>
    <body>
      <h1>🍵 Tea Shop</h1>
      <p>Welcome to our Tea Service!</p>
      <p>Enjoy your favorite tea 🍵</p>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: tea
  namespace: default
spec:
  selector:
    app: tea
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
TEA_EOF

echo ""
echo "Then apply:"
echo "  kubectl apply -f coffee.yaml"
echo "  kubectl apply -f tea.yaml"
echo ""