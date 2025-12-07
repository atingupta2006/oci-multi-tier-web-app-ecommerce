############################################
# GLOBAL / OCI
############################################

variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID"
}

variable "compartment_id" {
  type        = string
  description = "Compartment OCID where all resources will be created"
}

variable "region" {
  type        = string
  description = "OCI region"
  default     = "ap-mumbai-1"
}

############################################
# PROJECT METADATA
############################################

variable "project_name" {
  type        = string
  default     = "bharatmart"
  description = "Project name prefix"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name (dev/qa/prod)"
}

############################################
# IMAGE & SSH
############################################

variable "image_id" {
  type        = string
  description = "OCID of the compute image to use for all instances"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for opc user"
}

############################################
# FRONTEND INSTANCE (STANDALONE)
############################################

variable "frontend_instance_count" {
  type        = number
  default     = 1
  description = "Number of frontend instances"
}

variable "frontend_shape" {
  type        = string
  default     = "VM.Standard.A1.Flex"
  description = "Shape for frontend instances"
}

variable "frontend_ocpus" {
  type        = number
  default     = 2
  description = "OCPUs for frontend shape (Flex)"
}

variable "frontend_memory_in_gb" {
  type        = number
  default     = 8
  description = "Memory (GB) for frontend instances (Flex)"
}

############################################
# BACKEND INSTANCE POOL
############################################

variable "enable_instance_pool" {
  type        = bool
  default     = true
  description = "Enable backend instance pool and autoscaling"
}

variable "compute_instance_shape" {
  type        = string
  default     = "VM.Standard.A1.Flex"
  description = "Shape for backend instances in the pool"
}

variable "compute_instance_ocpus" {
  type        = number
  default     = 2
  description = "OCPUs for backend pool instances"
}

variable "compute_instance_memory_in_gb" {
  type        = number
  default     = 12
  description = "Memory (GB) for backend pool instances"
}

variable "instance_pool_size" {
  type        = number
  default     = 2
  description = "Initial size of the backend instance pool"
}

variable "instance_pool_min_size" {
  type        = number
  default     = 2
  description = "Minimum size of backend instance pool for autoscaling"
}

variable "instance_pool_max_size" {
  type        = number
  default     = 10
  description = "Maximum size of backend instance pool for autoscaling"
}

variable "enable_backend_public_ip" {
  type        = bool
  default     = false
  description = "Assign public IP to backend pool nodes (debug only; not recommended for prod)"
}

############################################
# TAGS
############################################

variable "common_tags" {
  description = "Common freeform tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "BharatMart"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
