# Kubernetes Cluster Setup Scripts

Automated scripts to deploy Kubernetes cluster using kubeadm.

## 🚀 Quick Start

### 1. Setup Master Node
```bash
# Make scripts executable
chmod +x *.sh

# Run master setup
./setup-cluster.sh master <MASTER_IP> <POD_NETWORK_CIDR> <KUBERNETES_VERSION>

# Example:
./setup-cluster.sh master 172.31.88.99 10.244.0.0/16 v1.33.0
```

### 2. Setup Worker Nodes
```bash
# Copy worker-join-command.txt from master to worker
# Then run on each worker:
./setup-cluster.sh worker <MASTER_IP> worker-join-command.txt

# Example:
./setup-cluster.sh worker 172.31.88.99 worker-join-command.txt
```

## 📁 Scripts

- **`setup-cluster.sh`** - Main orchestrator (use this)
- **`setup-master.sh`** - Master node setup (called by orchestrator)
- **`setup-worker.sh`** - Worker node setup (called by orchestrator)

## ⚡ Direct Usage

### Master Node
```bash
./setup-master.sh <MASTER_IP> <POD_NETWORK_CIDR> <KUBERNETES_VERSION>
```

### Worker Node
```bash
./setup-worker.sh <MASTER_IP> <JOIN_COMMAND_FILE>
```

## 🔧 Prerequisites

- Ubuntu 20.04+ or similar
- User with sudo privileges (NOT root)
- Internet connectivity
- 2GB+ RAM, 20GB+ disk space

## 📊 Verify Setup

```bash
# On master node
kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info
```

## 🚨 Troubleshooting

```bash
# Reset cluster if needed
sudo kubeadm reset --force  # Master
sudo kubeadm reset          # Worker

# Check logs
sudo journalctl -u kubelet -f
sudo systemctl status containerd
```

## 📝 Example Values

- **MASTER_IP**: `172.31.88.99` (your actual master IP)
- **POD_NETWORK_CIDR**: `10.244.0.0/16` (Flannel default)
- **KUBERNETES_VERSION**: `v1.33.0` (latest stable)

---

**Happy Clustering! 🎉**
