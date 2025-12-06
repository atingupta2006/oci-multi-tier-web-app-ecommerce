variable "compartment_id" {
  description = "OCI Compartment OCID where resources will be created"
  type        = string
}

variable "region" {
  description = "OCI region for deployment"
  type        = string
  default     = "us-ashburn-1"
}

variable "availability_domain" {
  description = "Availability Domain name (e.g., AD-1, AD-2, AD-3)"
  type        = string
  default     = "AD-1"
}

variable "project_name" {
  description = "Project name used for resource naming (e.g., bharatmart, training)"
  type        = string
  default     = "bharatmart"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vcn_cidr" {
  description = "CIDR block for VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (for Load Balancer)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (for Compute instances)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "compute_instance_shape" {
  description = "Shape for Compute instances"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "compute_instance_count" {
  description = "Number of backend Compute instances to create"
  type        = number
  default     = 1
}

variable "ssh_public_key" {
  description = "SSH public key for Compute instances (content, not file path)"
  type        = string
}

variable "load_balancer_shape" {
  description = "Shape for Load Balancer (Flexible or 100Mbps, 400Mbps, 8000Mbps)"
  type        = string
  default     = "flexible"
}

variable "load_balancer_shape_min_mbps" {
  description = "Minimum bandwidth in Mbps for flexible Load Balancer"
  type        = number
  default     = 10
}

variable "load_balancer_shape_max_mbps" {
  description = "Maximum bandwidth in Mbps for flexible Load Balancer"
  type        = number
  default     = 10
}

variable "image_id" {
  description = "OCI image OCID for Compute instances (Oracle Linux or Ubuntu)"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet (required if Compute instances need outbound internet)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    "Project"     = "BharatMart"
    "ManagedBy"   = "Terraform"
    "Environment" = "dev"
  }
}

