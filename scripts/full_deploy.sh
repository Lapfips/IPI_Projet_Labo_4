#!/bin/bash
# Complete automated deployment script
# This script performs the full deployment workflow locally

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing=0
    
    if ! command -v ansible &> /dev/null; then
        log_error "ansible not found. Please install Ansible >= 2.14"
        missing=1
    fi
    
    if ! command -v terraform &> /dev/null; then
        log_error "terraform not found. Please install Terraform >= 1.5"
        missing=1
    fi
    
    if ! command -v ansible-playbook &> /dev/null; then
        log_error "ansible-playbook not found"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        log_error "Missing required tools. Please install them and try again."
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# Stage 1: Setup Proxmox
setup_proxmox() {
    log_info "=========================================="
    log_info "Stage 1/4: Setting up Proxmox host"
    log_info "=========================================="
    
    cd "$PROJECT_ROOT/ansible"
    
    log_info "Running proxmox-playbook.yml..."
    ansible-playbook -i inventory/inventory.yml proxmox-playbook.yml
    
    if [ -f "$PROJECT_ROOT/terraform/proxmox.auto.tfvars" ]; then
        log_success "Proxmox setup complete!"
        log_success "API credentials written to: terraform/proxmox.auto.tfvars"
    else
        log_error "proxmox.auto.tfvars not generated!"
        exit 1
    fi
}

# Stage 2: Provision VMs
provision_vms() {
    log_info "=========================================="
    log_info "Stage 2/4: Provisioning VMs with Terraform"
    log_info "=========================================="
    
    cd "$PROJECT_ROOT/terraform"
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        log_warning "terraform.tfvars not found. Copying from example..."
        cp terraform.tfvars.example terraform.tfvars
        log_warning "Please edit terraform.tfvars with your SSH public key!"
        log_warning "Then run: $0 --provision-only"
        exit 1
    fi
    
    log_info "Initializing Terraform..."
    terraform init
    
    log_info "Validating configuration..."
    terraform validate
    
    log_info "Planning infrastructure..."
    terraform plan -out=tfplan
    
    log_info "Applying infrastructure..."
    terraform apply tfplan
    
    if [ -f "$PROJECT_ROOT/ansible/inventory/terraform_hosts.yml" ]; then
        log_success "VMs provisioned successfully!"
        log_success "Ansible inventory generated: ansible/inventory/terraform_hosts.yml"
    else
        log_error "Ansible inventory not generated!"
        exit 1
    fi
}

# Stage 3: Wait for VMs
wait_for_vms() {
    log_info "=========================================="
    log_info "Stage 3/4: Waiting for VMs to be ready"
    log_info "=========================================="
    
    cd "$PROJECT_ROOT/ansible"
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt + 1))
        log_info "Checking VM accessibility (attempt $attempt/$max_attempts)..."
        
        if ansible all -i inventory/terraform_hosts.yml -m ping &> /dev/null; then
            log_success "All VMs are accessible!"
            return 0
        fi
        
        log_warning "VMs not ready yet. Waiting 10 seconds..."
        sleep 10
    done
    
    log_error "VMs not accessible after $max_attempts attempts"
    log_warning "You may need to wait longer or check VM console in Proxmox UI"
    exit 1
}

# Stage 4: Configure services
configure_services() {
    log_info "=========================================="
    log_info "Stage 4/4: Configuring services with Ansible"
    log_info "=========================================="
    
    cd "$PROJECT_ROOT/ansible"
    
    log_info "Running main-playbook.yml..."
    ansible-playbook -i inventory/terraform_hosts.yml main-playbook.yml
    
    log_success "Services configured successfully!"
}

# Test deployment
test_deployment() {
    log_info "=========================================="
    log_info "Testing deployment"
    log_info "=========================================="
    
    cd "$PROJECT_ROOT/ansible"
    
    log_info "Testing VM connectivity..."
    ansible all -i inventory/terraform_hosts.yml -m ping
    
    log_info "Checking PostgreSQL..."
    ansible database_servers -i inventory/terraform_hosts.yml -a "systemctl is-active postgresql" || true
    
    log_info "Checking web services..."
    ansible bastion_servers -i inventory/terraform_hosts.yml -a "curl -f http://localhost:8080/guacamole" || true
    ansible ticketing_servers -i inventory/terraform_hosts.yml -a "curl -f http://localhost/glpi" || true
    
    log_info "Checking DNS service..."
    ansible network_servers -i inventory/terraform_hosts.yml -a "systemctl is-active named" || true
    
    log_info "Checking Zabbix..."
    ansible monitoring_servers -i inventory/terraform_hosts.yml -a "systemctl is-active zabbix-server" || true
    
    log_success "Testing complete!"
}

# Destroy infrastructure
destroy_infrastructure() {
    log_warning "=========================================="
    log_warning "Destroying infrastructure"
    log_warning "=========================================="
    
    read -p "Are you sure you want to destroy all VMs? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "Destruction cancelled"
        exit 0
    fi
    
    cd "$PROJECT_ROOT/terraform"
    
    log_info "Destroying VMs..."
    terraform destroy -auto-approve
    
    log_success "Infrastructure destroyed"
}

# Display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Complete deployment automation script for LAB4 infrastructure.

OPTIONS:
    --all               Run complete deployment (setup + provision + configure)
    --setup-only        Only setup Proxmox (Stage 1)
    --provision-only    Only provision VMs (Stage 2)
    --configure-only    Only configure services (Stage 4)
    --test              Test deployment
    --destroy           Destroy all infrastructure
    --help              Display this help message

EXAMPLES:
    # Full deployment
    $0 --all

    # Setup Proxmox only
    $0 --setup-only

    # Provision VMs (requires proxmox.auto.tfvars)
    $0 --provision-only

    # Configure services (requires terraform_hosts.yml)
    $0 --configure-only

    # Test deployment
    $0 --test

    # Destroy infrastructure
    $0 --destroy

EOF
}

# Main
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi
    
    case "$1" in
        --all)
            check_prerequisites
            setup_proxmox
            provision_vms
            wait_for_vms
            configure_services
            test_deployment
            log_success "=========================================="
            log_success "Complete deployment finished!"
            log_success "=========================================="
            log_info "Access your services:"
            log_info "  Guacamole:  http://192.168.125.1:8080/guacamole"
            log_info "  GLPI:       http://192.168.125.2/glpi"
            log_info "  Nextcloud:  http://192.168.125.4"
            log_info "  Zabbix:     http://192.168.125.5/zabbix"
            ;;
        --setup-only)
            check_prerequisites
            setup_proxmox
            ;;
        --provision-only)
            check_prerequisites
            provision_vms
            ;;
        --configure-only)
            check_prerequisites
            wait_for_vms
            configure_services
            ;;
        --test)
            test_deployment
            ;;
        --destroy)
            destroy_infrastructure
            ;;
        --help|-h)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
}

main "$@"
