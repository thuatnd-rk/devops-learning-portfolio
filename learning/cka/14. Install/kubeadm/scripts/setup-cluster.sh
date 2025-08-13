#!/bin/bash

# Kubernetes Cluster Setup Orchestrator
# This script helps you set up a complete Kubernetes cluster

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

show_usage() {
    echo "Kubernetes Cluster Setup Script"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  master <MASTER_IP> <POD_NETWORK_CIDR> <KUBERNETES_VERSION>  - Setup master node"
    echo "  worker <MASTER_IP> <JOIN_COMMAND_FILE>                       - Setup worker node"
    echo "  help                                                          - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 master 192.168.1.100 10.244.0.0/16 v1.33.0"
    echo "  $0 worker 192.168.1.100 worker-join-command.txt"
    echo ""
    echo "Prerequisites:"
    echo "  - Ubuntu 20.04+ or similar Linux distribution"
    echo "  - User with sudo privileges (not root)"
    echo "  - Internet connectivity"
    echo "  - At least 2GB RAM and 20GB disk space"
}

check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check OS
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot determine operating system"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
    
    # Check sudo access
    if ! sudo -n true 2>/dev/null; then
        print_error "This user does not have sudo privileges or requires password"
        exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        print_error "No internet connectivity detected"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

setup_master() {
    local master_ip=$1
    local pod_network_cidr=$2
    local kubernetes_version=$3
    
    print_status "Setting up master node..."
    print_status "Master IP: $master_ip"
    print_status "Pod Network CIDR: $pod_network_cidr"
    print_status "Kubernetes Version: $kubernetes_version"
    
    # Check if script exists
    if [[ ! -f "./setup-master.sh" ]]; then
        print_error "setup-master.sh script not found in current directory"
        exit 1
    fi
    
    # Make script executable
    chmod +x ./setup-master.sh
    
    # Run master setup
    ./setup-master.sh "$master_ip" "$pod_network_cidr" "$kubernetes_version"
    
    print_success "Master node setup completed!"
    print_status "Next steps:"
    print_status "1. Copy worker-join-command.txt to worker nodes"
    print_status "2. Run: $0 worker <MASTER_IP> worker-join-command.txt on each worker node"
}

setup_worker() {
    local master_ip=$1
    local join_command_file=$2
    
    print_status "Setting up worker node..."
    print_status "Master IP: $master_ip"
    print_status "Join command file: $join_command_file"
    
    # Check if script exists
    if [[ ! -f "./setup-worker.sh" ]]; then
        print_error "setup-worker.sh script not found in current directory"
        exit 1
    fi
    
    # Check if join command file exists
    if [[ ! -f "$join_command_file" ]]; then
        print_error "Join command file $join_command_file not found"
        exit 1
    fi
    
    # Make script executable
    chmod +x ./setup-worker.sh
    
    # Run worker setup
    ./setup-worker.sh "$master_ip" "$join_command_file"
    
    print_success "Worker node setup completed!"
}

# Main script logic
main() {
    case "$1" in
        "master")
            if [[ $# -ne 4 ]]; then
                print_error "Master setup requires 3 arguments: MASTER_IP POD_NETWORK_CIDR KUBERNETES_VERSION"
                show_usage
                exit 1
            fi
            check_prerequisites
            setup_master "$2" "$3" "$4"
            ;;
        "worker")
            if [[ $# -ne 3 ]]; then
                print_error "Worker setup requires 2 arguments: MASTER_IP JOIN_COMMAND_FILE"
                show_usage
                exit 1
            fi
            check_prerequisites
            setup_worker "$2" "$3"
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Check if any arguments provided
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

# Run main function
main "$@"
