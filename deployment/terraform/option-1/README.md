# BharatMart OCI Deployment - Terraform Configuration

This directory contains Terraform configuration files for deploying BharatMart infrastructure on Oracle Cloud Infrastructure (OCI) using OCI Resource Manager.

## Overview

This Terraform configuration creates a minimal but complete infrastructure setup for BharatMart:

- **VCN** (Virtual Cloud Network) with public and private subnets
- **Internet Gateway** for public subnet connectivity
- **NAT Gateway** (optional) for private subnet outbound connectivity
- **Security Lists** with appropriate rules for Load Balancer and Compute instances
- **Compute Instances** (configurable count) for BharatMart backend API
- **Load Balancer** with health checks and backend configuration

## Prerequisites

1. **OCI Account** with appropriate permissions
2. **OCI Compartment** OCID where resources will be created
3. **Terraform** version >= 1.5.0 (for local testing, or use OCI Resource Manager)
4. **OCI Image** OCID (Oracle Linux or Ubuntu)
5. **SSH Public Key** for Compute instance access

## File Structure

```
deployment/terraform/
├── versions.tf          # Terraform and provider version requirements
├── variables.tf         # Input variable definitions
├── main.tf              # Main infrastructure resources
├── outputs.tf           # Output values (resource IDs, IPs, etc.)
├── terraform.tfvars.example  # Example variables file
└── README.md            # This file
```

## Quick Start

### Using OCI Resource Manager (Recommended for Training)

1. **Create a ZIP file** of the Terraform configuration:
   ```bash
   cd deployment/terraform
   zip -r bharatmart-terraform.zip *.tf
   ```

2. **Upload to Resource Manager**:
   - Go to OCI Console → Developer Services → Resource Manager → Stacks
   - Click "Create Stack"
   - Choose "My Local Machine"
   - Upload `bharatmart-terraform.zip`
   - Fill in variables (compartment_id, image_id, ssh_public_key, etc.)
   - Review and create stack

3. **Run Plan**:
   - Open your stack
   - Click "Terraform Actions → Plan"
   - Review the plan output

4. **Apply**:
   - Click "Terraform Actions → Apply"
   - Wait for resources to be created

### Using Terraform CLI (Optional)

1. **Initialize Terraform**:
   ```bash
   cd deployment/terraform
   terraform init
   ```

2. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Plan**:
   ```bash
   terraform plan
   ```

4. **Apply**:
   ```bash
   terraform apply
   ```

## Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `compartment_id` | OCI Compartment OCID | `ocid1.compartment.oc1..aaaaaaa...` |
| `image_id` | OCI Image OCID | `ocid1.image.oc1.iad.aaaaaaaa...` |
| `ssh_public_key` | SSH public key content | `ssh-rsa AAAAB3...` |

## Key Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `ap-mumbai-1` | OCI region |
| `project_name` | `bharatmart` | Project name for resource naming |
| `environment` | `dev` | Environment (dev/staging/prod) |
| `compute_instance_count` | `1` | Number of backend instances |
| `compute_instance_shape` | `VM.Standard.A1.Flex` | Compute instance shape |
| `load_balancer_shape` | `flexible` | Load Balancer shape |
| `enable_nat_gateway` | `true` | Enable NAT Gateway for private subnet |

## What Gets Created

### Networking
- **VCN** with CIDR block (default: 10.0.0.0/16)
- **Public Subnet** (default: 10.0.1.0/24) - for Load Balancer
- **Private Subnet** (default: 10.0.2.0/24) - for Compute instances
- **Internet Gateway** - for public subnet
- **NAT Gateway** - for private subnet outbound access (if enabled)

### Security
- **Public Security List** - allows HTTP (80), HTTPS (443) from internet
- **Private Security List** - allows API traffic (3000) from Load Balancer, SSH (22) from VCN

### Compute
- **Compute Instances** (configurable count) - for BharatMart backend API
  - Deployed in private subnet
  - Basic Node.js installation via user_data
  - SSH access configured

### Load Balancing
- **Load Balancer** (public, flexible shape)
  - Backend Set with health check on `/api/health`
  - HTTP listener on port 80
  - Backend servers: Compute instances on port 3000

## Outputs

After successful deployment, the following outputs are available:

- `vcn_id` - VCN OCID
- `load_balancer_ip_address` - Public IP of Load Balancer
- `load_balancer_hostname` - Hostname of Load Balancer
- `load_balancer_url` - Full URL to access application
- `compute_instance_ids` - OCIDs of Compute instances
- `compute_instance_private_ips` - Private IPs of Compute instances

## Post-Deployment Steps

After Terraform creates the infrastructure:

1. **SSH to Compute instances** (via bastion or VPN):
   ```bash
   ssh -i ~/.ssh/your_key opc@<private_ip>
   ```

2. **Deploy BharatMart application**:
   - Install Node.js (already done via user_data)
   - Clone repository
   - Configure environment variables
   - Start application

3. **Verify Load Balancer**:
   ```bash
   curl http://<load_balancer_ip>/api/health
   ```

4. **Configure DNS** (optional):
   - Point your domain to Load Balancer IP/hostname

## Version Information

- **Terraform**: >= 1.5.0
- **OCI Provider**: ~> 5.0

