############################################################
# variables.tf – Central Inputs for BharatMart Deployment
#
# Notes:
#   • This file is rewritten to support Observability v2:
#       - Unified YAML agent config (logging + metrics)
#       - OTEL Collector sidecar install
#       - Prometheus → OCI custom metrics namespace
#       - JSON application logs
#   • Variable descriptions are expanded for clarity.
#   • No breaking changes to existing tfvars; defaults maintained.
############################################################


########################
# OCI AUTHENTICATION (MANDATORY)
########################

variable "tenancy_ocid" {
  description = "OCI Tenancy OCID used for all API calls."
  type        = string
}

variable "user_ocid" {
  description = "OCI User OCID for API signing key authentication."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API signing key."
  type        = string
}

variable "region" {
  description = "Deployment region (e.g. eu-frankfurt-1)."
  type        = string
}

variable "home_region" {
  description = "Tenancy home region used for home-region resources (e.g. IAM)."
  type        = string
  default     = "ap-mumbai-1"
}

variable "private_key_path" {
  description = <<EOF
Path to local private key for Terraform CLI usage.
If provided, this is preferred over inline private_key.
EOF
  type        = string
  default     = ""
}

variable "private_key" {
  description = <<EOF
Inline PEM private key (ONLY used when executing in OCI Resource Manager).
If empty, Terraform assumes CLI mode using private_key_path.
EOF
  type        = string
  sensitive   = true
  default     = ""
}

variable "private_key_password" {
  description = "Password for encrypted private keys. Leave empty if not used."
  type        = string
  sensitive   = true
  default     = ""
}

variable "compartment_ocid" {
  description = "Compartment OCID where BharatMart resources will be deployed."
  type        = string
}


########################
# PROJECT-WIDE SETTINGS
########################

variable "project_name" {
  description = "Name prefix for all created resources (VCN, LB, logs, alarms)."
  type        = string
  default     = "bharatmart"
}


########################
# SSH ACCESS
########################

variable "ssh_public_key" {
  description = "Public SSH key injected into VM instances for admin access."
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR range allowed to SSH into frontend instances."
  type        = string
  default     = "0.0.0.0/0"
}


########################
# GITHUB REPOSITORY
########################

variable "github_repo_url" {
  description = "GitHub URL for BharatMart application repository (frontend + backend)."
  type        = string
}


########################
# APPLICATION ENVIRONMENT VARS
########################

variable "supabase_url" {
  description = "Supabase project URL for auth and database."
  type        = string
}

variable "supabase_anon_key" {
  description = "Supabase anonymous key."
  type        = string
  sensitive   = true
}

variable "supabase_service_role_key" {
  description = "Supabase service role key (admin)."
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret for backend authentication."
  type        = string
  sensitive   = true
}

variable "admin_email" {
  description = "Initial admin account email for seeding."
  type        = string
  default     = "admin@bharatmart.com"
}

variable "admin_password" {
  description = "Initial admin password used during application bootstrap."
  type        = string
  sensitive   = true
  default     = "Admin@123"
}


########################
# IMAGE SELECTION
########################

variable "os_version" {
  description = "Oracle Linux version to use (auto-discovered image)."
  type        = string
  default     = "9"
}

variable "use_custom_images" {
  description = "If true, use custom image IDs instead of auto-discovered ones."
  type        = bool
  default     = false
}

variable "frontend_custom_image_id" {
  description = "Frontend custom image ID (when use_custom_images = true)."
  type        = string
  default     = null
}

variable "backend_custom_image_id" {
  description = "Backend custom image ID (when use_custom_images = true)."
  type        = string
  default     = null
}


########################
# FRONTEND SETTINGS
########################

variable "frontend_instance_count" {
  description = "Number of standalone frontend VM instances."
  type        = number
  default     = 1
}

variable "frontend_shape" {
  description = "OCI compute shape for frontend (e.g., VM.Standard.E5.Flex)."
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "frontend_flex_ocpus" {
  description = "OCPUs for frontend flex shape."
  type        = number
  default     = 2
}

variable "frontend_flex_memory_gbs" {
  description = "Memory in GB for frontend flex shape."
  type        = number
  default     = 12
}

variable "frontend_port" {
  description = "Port served by NGINX on frontend instances."
  type        = number
  default     = 80
}


########################
# BACKEND (INSTANCE POOL)
########################

variable "backend_shape" {
  description = "OCI compute shape for backend instance pool nodes."
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "backend_flex_ocpus" {
  description = "OCPUs for backend flex shape."
  type        = number
  default     = 2
}

variable "backend_flex_memory_gbs" {
  description = "Memory (GB) for backend flex shape."
  type        = number
  default     = 12
}

variable "backend_api_port" {
  description = "Backend API port where Node.js listens."
  type        = number
  default     = 3000
}

variable "backend_pool_initial_size" {
  description = "Initial backend instance pool size."
  type        = number
  default     = 2
}

variable "backend_pool_min_size" {
  description = "Minimum backend pool size enforced by autoscaling."
  type        = number
  default     = 1
}

variable "backend_pool_max_size" {
  description = "Maximum backend pool size enforced by autoscaling."
  type        = number
  default     = 10
}


########################
# AUTOSCALING THRESHOLDS
########################

variable "backend_cpu_scale_out_threshold" {
  description = "CPU % above which pool scales OUT."
  type        = number
  default     = 70
}

variable "backend_cpu_scale_in_threshold" {
  description = "CPU % below which pool scales IN."
  type        = number
  default     = 30
}


########################
# LOAD BALANCER SETTINGS
########################

variable "lb_min_bandwidth_mbps" {
  description = "Minimum bandwidth allocation for the Flexible Load Balancer."
  type        = number
  default     = 10
}

variable "lb_max_bandwidth_mbps" {
  description = "Maximum LB bandwidth for autoscaling workloads."
  type        = number
  default     = 100
}


########################
# OBSERVABILITY v2 – Additional Variables
#
# These support:
#   - Unified Cloud Agent YAML config
#   - OTEL collector
#   - Custom metrics namespace
########################

variable "custom_metrics_namespace" {
  description = <<EOF
Custom namespace where Prometheus → OCI metrics will be ingested.
Calling code will map prom-client metric names into this namespace.
EOF
  type        = string
  default     = "custombharatmart"
}

variable "otel_service_name" {
  description = "Service name used by OTEL collector & trace spans."
  type        = string
  default     = "bharatmart-backend"
}

variable "otel_exporter_otlp_endpoint" {
  description = "Local OTEL Collector OTLP HTTP endpoint."
  type        = string
  default     = "http://localhost:4318/v1/traces"
}
