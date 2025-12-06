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
| `region` | `us-ashburn-1` | OCI region |
| `project_name` | `bharatmart` | Project name for resource naming |
| `environment` | `dev` | Environment (dev/staging/prod) |
| `compute_instance_count` | `1` | Number of backend instances |
| `compute_instance_shape` | `VM.Standard.E2.1.Micro` | Compute instance shape |
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

## Future Expansion

This is a minimal configuration that can be expanded to include:

### Additional Infrastructure
- **OCI Autonomous Database** - Replace Supabase for data storage
- **OCI Cache** - Managed Redis for caching
- **OCI Queue** - Managed message queue for workers
- **OCI Object Storage** - For frontend static assets
- **OCI Vault** - For secrets management
- **Bastion Host** - For secure access to private instances
- **Multiple Availability Domains** - For high availability

### Enhanced Features
- **Auto-Scaling** - Instance pools with auto-scaling policies
- **SSL/TLS** - HTTPS listener with SSL certificate
- **Multiple Backend Sets** - For different application tiers
- **Path-Based Routing** - Route different paths to different backends
- **WAF** - Web Application Firewall integration
- **Monitoring** - OCI Monitoring alarms and dashboards
- **Logging** - OCI Logging integration

### Expansion Guide

To add new resources:

1. **Create new `.tf` files** or add to `main.tf`
2. **Add variables** in `variables.tf` for customization
3. **Add outputs** in `outputs.tf` for new resource identifiers
4. **Use Terraform modules** for reusable components (recommended for larger deployments)

Example expansion structure:
```
deployment/terraform/
├── modules/
│   ├── networking/     # VCN, subnets, gateways
│   ├── compute/        # Compute instances
│   ├── load-balancer/  # Load Balancer configuration
│   ├── database/       # Autonomous Database
│   └── cache/          # OCI Cache
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── main.tf             # Root module
```

## Troubleshooting

### Common Issues

1. **Image OCID not found**:
   - Verify the image OCID is correct for your region
   - Use `oci compute image list` to find available images

2. **SSH key format**:
   - Ensure `ssh_public_key` contains the full public key (not file path)
   - Format: `ssh-rsa AAAAB3... user@host`

3. **Compartment permissions**:
   - Ensure your OCI user has permissions to create resources in the compartment

4. **Load Balancer creation fails**:
   - Flexible shape requires minimum/maximum bandwidth specification
   - Verify subnet has proper security list rules

## Security Considerations

- Compute instances are in private subnet (no direct internet access)
- Load Balancer is public (handles internet traffic)
- NAT Gateway allows outbound access from private instances
- Security lists restrict traffic appropriately
- SSH access is limited to within VCN

## Cost Optimization

- Use `VM.Standard.E2.1.Micro` shape for development/testing
- Use flexible Load Balancer with minimum bandwidth for cost savings
- Disable NAT Gateway if outbound internet is not needed
- Use single Availability Domain for minimal deployment

## Related Documentation

- [Day 3 Topic 4: Automation with Resource Manager](../../training-material/Day-3/04-Automation-with-Resource-Manager/index.md)
- [OCI Deployment Guide](../../docs/05-deployment/07-oci-deployment.md)
- [OCI Resource Manager Documentation](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm)

