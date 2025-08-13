#!/bin/bash

# Kubernetes Worker Node Setup Script
# Usage: ./setup-worker.sh <MASTER_IP> <JOIN_COMMAND_FILE>

set -e  # Exit on any error

# Enable error tracing for better debugging
set -o errtrace
trap 'echo "Error occurred in line $LINENO. Exit code: $?" >&2' ERR

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
if [ $# -ne 2 ]; then
    print_error "Usage: $0 <MASTER_IP> <JOIN_COMMAND_FILE>"
    print_error "Example: $0 192.168.1.100 worker-join-command.txt"
    exit 1
fi

MASTER_IP=$1
JOIN_COMMAND_FILE=$2

print_status "Starting Kubernetes Worker Node Setup..."
print_status "Master IP: $MASTER_IP"
print_status "Join command file: $JOIN_COMMAND_FILE"

# Log system information for debugging
print_status "System information:"
print_status "OS: $(lsb_release -d | cut -f2 2>/dev/null || echo 'Unknown')"
print_status "Kernel: $(uname -r)"
print_status "Architecture: $(uname -m)"
print_status "Hostname: $(hostname)"
print_status "User: $(whoami)"
print_status "Date: $(date)"

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

# Check for network tools (optional but helpful)
print_status "Checking network tools..."
if command -v nc &> /dev/null; then
    print_success "netcat (nc) is available"
else
    print_warning "netcat (nc) not found - some debug features may be limited"
fi

if command -v traceroute &> /dev/null; then
    print_success "traceroute is available"
else
    print_warning "traceroute not found - some debug features may be limited"
fi

# Function to run command with status
run_command() {
    local cmd="$1"
    local desc="$2"
    
    print_status "$desc..."
    if eval "$cmd"; then
        print_success "$desc completed"
    else
        print_error "$desc failed"
        print_error "Command: $cmd"
        exit 1
    fi
}

# Function to run command with status (non-critical)
run_command_soft() {
    local cmd="$1"
    local desc="$2"
    
    print_status "$desc..."
    if eval "$cmd"; then
        print_success "$desc completed"
    else
        print_warning "$desc failed (continuing...)"
    fi
}

# Check if join command file exists
if [ ! -f "$JOIN_COMMAND_FILE" ]; then
    print_error "Join command file $JOIN_COMMAND_FILE not found!"
    print_error "Please copy the file from master node first."
    exit 1
fi

# Read join command from file
JOIN_COMMAND=$(cat "$JOIN_COMMAND_FILE")
print_status "Join command loaded: $JOIN_COMMAND"

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

# Test connectivity to master
print_status "Testing connectivity to master node..."
print_status "Testing TCP connection to $MASTER_IP:6443..."

# Test TCP connectivity to Kubernetes API server
if timeout 5 bash -c "</dev/tcp/$MASTER_IP/6443" 2>/dev/null; then
    print_success "Master node is reachable on port 6443"
else
    print_error "Cannot reach master node at $MASTER_IP:6443"
    print_error "Please check network connectivity and firewall settings"
    print_error "Note: This checks TCP connectivity to Kubernetes API server port 6443"
    
    # Additional debugging information
    print_status "Debug information:"
    print_status "1. Checking if port 6443 is open on master node..."
    run_command_soft "nc -zv $MASTER_IP 6443" "Port 6443 connectivity test"
    
    print_status "2. Checking network route to master node..."
    run_command_soft "traceroute -n $MASTER_IP" "Network route check"
    
    print_status "3. Checking if master IP is reachable via ping (for reference)..."
    run_command_soft "ping -c 3 $MASTER_IP" "Ping test (optional)"
    
    print_error "Network connectivity test failed. Please resolve network issues before continuing."
    exit 1
fi

# Join the cluster
print_status "Joining Kubernetes cluster..."
print_status "Join command: $JOIN_COMMAND"

# Validate join command format
if [[ ! "$JOIN_COMMAND" =~ ^kubeadm\ join ]]; then
    print_error "Invalid join command format"
    print_error "Join command should start with 'kubeadm join'"
    print_error "Current command: $JOIN_COMMAND"
    exit 1
fi

print_status "Executing join command..."
if eval "sudo $JOIN_COMMAND"; then
    print_success "Successfully joined the cluster!"
else
    print_error "Failed to join the cluster"
    print_error "Join command: $JOIN_COMMAND"
    
    # Additional troubleshooting information
    print_status "Troubleshooting steps:"
    print_status "1. Check if master node is ready: kubectl get nodes (from master)"
    print_status "2. Verify join token is valid: kubeadm token list (from master)"
    print_status "3. Check kubelet logs: sudo journalctl -u kubelet -f"
    print_status "4. Verify network connectivity to master node"
    print_status "5. Check if worker node meets system requirements"
    
    exit 1
fi

# Verify node status (this will only work if kubectl is configured)
print_status "Verifying node status..."
print_warning "Note: kubectl commands may not work until configured on this node"
print_status "You can verify node status from the master node using:"
print_status "kubectl get nodes"

# Check kubelet status
print_status "Checking kubelet service status..."
run_command_soft "sudo systemctl status kubelet --no-pager" "Kubelet service status"

# Final status
print_success "Kubernetes Worker Node setup completed successfully!"
print_status "Next steps:"
print_status "1. Go back to master node and verify: kubectl get nodes"
print_status "2. Check if this node appears in the cluster"
print_status "3. Repeat this process for other worker nodes if needed"
print_status "4. Monitor node status: kubectl describe node <worker-node-name>"

print_status "Useful commands for troubleshooting:"
print_status "- Check kubelet logs: sudo journalctl -u kubelet -f"
print_status "- Check kubelet status: sudo systemctl status kubelet"
print_status "- Check node status from master: kubectl get nodes -o wide"

print_success "Worker node setup completed! 🎉"
