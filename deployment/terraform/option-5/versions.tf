############################################################
# versions.tf – Terraform + OCI provider configuration
#
# This file:
#   - Pins Terraform + OCI provider versions
#   - Defines the default OCI provider (regional resources)
#   - Defines a "home_region" provider alias for IAM resources
############################################################

terraform {
  # Require at least Terraform 1.5.x (you can bump if your environment supports it)
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source = "oracle/oci"
      # OCI provider 6.12.0+ includes the Monitoring/Logging/Autoscaling
      # resources we use in this project. You can bump this if needed.
      version = ">= 6.12.0"
    }
  }
}

############################################################
# Default OCI provider
#
# Used for:
#   - VCN, subnets, gateways, security lists
#   - Compute instances + instance pools
#   - Load balancer
#   - Logging, Monitoring, Alarms, Notifications
#
# Region is controlled via var.region (e.g. "eu-frankfurt-1")
############################################################

provider "oci" {
  # Core identity/auth values come from variables.tf / terraform.tfvars
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  region       = var.region

  # === Authentication mode selection ===
  #
  # 1) Local Terraform CLI:
  #    - You typically set private_key_path to "~/.oci/oci_api_key.pem"
  #    - In that case, private_key_path is non-empty and will be used.
  #
  # 2) OCI Resource Manager (ORM):
  #    - You leave private_key_path empty
  #    - You paste the PEM key into the "private_key" variable instead.
  #
  # The ternary operators below ensure we don't set *both* at the same time.
  # If a value is an empty string, we pass null, so the provider ignores it.

  # Use file-based private key for local CLI runs (if provided)
  private_key_path = var.private_key_path != "" ? var.private_key_path : null

  # Use inline PEM key for ORM or explicit inline config (if provided)
  private_key = var.private_key != "" ? var.private_key : null

  # Optional key password (for encrypted private keys).
  private_key_password = var.private_key_password
}

############################################################
# Home-region OCI provider alias
#
# WHY:
#   - Some IAM resources (dynamic groups, policies) must be created
#     in the tenancy's *home region*.
#   - Your code already uses this alias for IAM in monitoring-logging.tf:
#       provider = oci.home_region
#
# HOW:
#   - We keep auth identical to the default provider
#   - We only change region to the tenancy home region (BOM).
#
# NOTE:
#   - If you ever move to a different tenancy with a different home region,
#     this is the *only* place you need to update.
############################################################

provider "oci" {
  alias = "home_region"

  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint

  # Set to your tenancy HOME region (not necessarily the same as var.region).
  # For your current tenancy, this is "ap-mumbai-1" (BOM).
  region = var.home_region

  # Same auth selection logic as the default provider.
  private_key_path     = var.private_key_path != "" ? var.private_key_path : null
  private_key          = var.private_key != "" ? var.private_key : null
  private_key_password = var.private_key_password
}
