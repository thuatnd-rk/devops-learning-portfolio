#!/bin/bash

# Kubernetes Master Node Setup Script
# Usage: ./setup-master.sh <MASTER_IP> <POD_NETWORK_CIDR> <KUBERNETES_VERSION>
./setup-master.sh 10.0.8.129 10.244.0.0/16 v1.33.0

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Check arguments
if [ $# -ne 3 ]; then
    print_error "Usage: $0 <MASTER_IP> <POD_NETWORK_CIDR> <KUBERNETES_VERSION>"
    print_error "Example: $0 192.168.1.100 10.244.0.0/16 v1.33.0"
    exit 1
fi

MASTER_IP=$1
POD_NETWORK_CIDR=$2
KUBERNETES_VERSION=$3

print_status "Starting Kubernetes Master Node Setup..."
print_status "Master IP: $MASTER_IP"
print_status "Pod Network CIDR: $POD_NETWORK_CIDR"
print_status "Kubernetes Version: $KUBERNETES_VERSION"

# Function to check command existence
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

# Check required commands
print_status "Checking required commands..."
check_command curl
check_command sudo

# Function to run command with status
run_command() {
    local cmd="$1"
    local desc="$2"
    
    print_status "$desc..."
    if eval "$cmd"; then
        print_success "$desc completed"
    else
        print_error "$desc failed"
        exit 1
    fi
}

# Update system
print_status "Updating system packages..."
run_command "sudo apt-get update" "System update"

# Install required packages
print_status "Installing required packages..."
run_command "sudo apt-get install -y apt-transport-https ca-certificates curl gpg" "Package installation"

# Add Kubernetes repository
print_status "Adding Kubernetes repository..."
run_command "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg" "GPG key download"
run_command "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list" "Repository addition"

# Install Kubernetes components
print_status "Installing Kubernetes components..."
run_command "sudo apt-get update" "Repository update"
run_command "sudo apt-get install -y kubelet kubeadm kubectl" "Kubernetes installation"
run_command "sudo apt-mark hold kubelet kubeadm kubectl" "Prevent auto-updates"

# Verify installation
print_status "Verifying Kubernetes installation..."
run_command "kubeadm version" "kubeadm version check"
run_command "kubectl version --client" "kubectl version check"
run_command "kubelet --version" "kubelet version check"

# Install containerd
print_status "Installing containerd..."
run_command "sudo apt update" "Package list update"
run_command "sudo apt install -y containerd" "containerd installation"

# Configure containerd
print_status "Configuring containerd..."
run_command "sudo mkdir -p /etc/containerd" "Create containerd config directory"
run_command "containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml" "Configure containerd with systemd cgroup driver"
run_command "sudo systemctl restart containerd" "Restart containerd"
run_command "sudo systemctl enable containerd" "Enable containerd"
run_command "sudo systemctl status containerd --no-pager" "Verify containerd status"

# Network configuration
print_status "Configuring network parameters..."
run_command "cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF" "Create sysctl configuration"

run_command "sudo sysctl --system" "Apply sysctl parameters"
run_command "sysctl net.ipv4.ip_forward" "Verify IP forwarding"

# Load kernel modules
print_status "Loading required kernel modules..."
run_command "cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF" "Create modules configuration"

run_command "sudo modprobe overlay" "Load overlay module"
run_command "sudo modprobe br_netfilter" "Load br_netfilter module"

# Initialize Kubernetes cluster
print_status "Initializing Kubernetes cluster..."
run_command "sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=$POD_NETWORK_CIDR --upload-certs --control-plane-endpoint=$MASTER_IP:6443 --kubernetes-version=$KUBERNETES_VERSION" "Cluster initialization"

# Configure kubectl
print_status "Configuring kubectl..."
run_command "mkdir -p \$HOME/.kube" "Create .kube directory"
run_command "sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config" "Copy admin config"
run_command "sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config" "Set ownership"

# Verify cluster status
print_status "Verifying cluster status..."
run_command "kubectl cluster-info" "Cluster info"
run_command "kubectl get nodes" "Node status"

# Install Flannel network addon
print_status "Installing Flannel network addon..."
run_command "wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml" "Download Flannel manifest"
run_command "kubectl apply -f kube-flannel.yml" "Apply Flannel manifest"

# Wait for Flannel pods to be ready
print_status "Waiting for Flannel pods to be ready..."
sleep 30
run_command "kubectl get pods -n kube-flannel" "Check Flannel pods"

# Get join command for worker nodes
print_status "Getting join command for worker nodes..."
JOIN_COMMAND=$(sudo kubeadm token create --print-join-command)
print_success "Worker node join command:"
echo "$JOIN_COMMAND"

# Save join command to file
echo "$JOIN_COMMAND" > worker-join-command.txt
print_success "Join command saved to worker-join-command.txt"

# Final status
print_success "Kubernetes Master Node setup completed successfully!"
print_status "Next steps:"
print_status "1. Copy worker-join-command.txt to worker nodes"
print_status "2. Run the worker setup script on each worker node"
print_status "3. Verify cluster with: kubectl get nodes"

print_success "Setup completed! 🎉"
