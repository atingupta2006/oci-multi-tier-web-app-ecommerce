############################################
# Core Deployment Variables
############################################

variable "compartment_id" {
  description = "OCI Compartment OCID where resources will be created"
  type        = string
}

variable "region" {
  description = "OCI region for deployment"
  type        = string
  default     = "ap-mumbai-1"
}

variable "availability_domain" {
  description = "Availability Domain name (e.g., AD-1, AD-2, AD-3)"
  type        = string
  default     = "AD-1"
}

variable "project_name" {
  description = "Project name used for resource naming (e.g., bharatmart)"
  type        = string
  default     = "bharatmart"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

############################################
# Network Variables
############################################

variable "vcn_cidr" {
  description = "CIDR block for VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet (Load Balancer + Frontend)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (Backend VMs)"
  type        = string
  default     = "10.0.2.0/24"
}

############################################
# Compute Instance Settings – Backend
############################################

variable "compute_instance_shape" {
  description = "Shape for backend compute instances"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "compute_instance_count" {
  description = "Number of backend compute instances to create"
  type        = number
  default     = 1
}

variable "enable_backend_public_ip" {
  description = "Enable public IP on backend VMs (for debugging; default false)"
  type        = bool
  default     = false
}

############################################
# Compute Instance Settings – Frontend
############################################

variable "frontend_instance_shape" {
  description = "Shape for frontend compute instance"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "frontend_instance_count" {
  description = "Number of frontend compute instances to create (future scalability)"
  type        = number
  default     = 1
}

############################################
# Load Balancer Settings
############################################

variable "load_balancer_shape" {
  description = "Shape for Load Balancer (flexible recommended)"
  type        = string
  default     = "flexible"
}

variable "load_balancer_shape_min_mbps" {
  description = "Minimum bandwidth (Mbps) for flexible LB"
  type        = number
  default     = 10
}

variable "load_balancer_shape_max_mbps" {
  description = "Maximum bandwidth (Mbps) for flexible LB"
  type        = number
  default     = 10
}

############################################
# System Access & Image
############################################

variable "image_id" {
  description = "OCI image OCID for compute instances"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content (not file path)"
  type        = string
}

############################################
# Gateways
############################################

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for backend outbound internet access"
  type        = bool
  default     = true
}

############################################
# Tagging
############################################

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    "Project"     = "BharatMart"
    "ManagedBy"   = "Terraform"
    "Environment" = "dev"
  }
}

variable "compute_instance_ocpus" {
  description = "OCPUs for backend compute instance (Flex shapes only)"
  type        = number
  default     = 2
}

variable "compute_instance_memory_in_gb" {
  description = "Memory in GB for backend compute instance (Flex shapes only)"
  type        = number
  default     = 12
}
