############################################
# INSTANCE POOL & AUTO SCALING (Option 3)
# Scalable Backend Using OCI Load Balancer + Auto Scaling (Multi-AD)
############################################

# All Availability Domains (used for placement across ADs)
data "oci_identity_availability_domains" "all_ads" {
  compartment_id = var.tenancy_ocid
}

############################################
# BACKEND SUBNET MAP (AD -> Subnet ID)
############################################
# These subnets are defined in main.tf:
# - oci_core_subnet.backend_subnet_ad1
# - oci_core_subnet.backend_subnet_ad2
# - oci_core_subnet.backend_subnet_ad3
#
# We build a map so the instance pool can pick the correct subnet for each AD.

locals {
  backend_subnet_map = {
    (data.oci_identity_availability_domains.all_ads.availability_domains[0].name) = oci_core_subnet.backend_subnet_ad1.id
    (data.oci_identity_availability_domains.all_ads.availability_domains[1].name) = oci_core_subnet.backend_subnet_ad2.id
    (data.oci_identity_availability_domains.all_ads.availability_domains[2].name) = oci_core_subnet.backend_subnet_ad3.id
  }
}

############################################
# INSTANCE CONFIGURATION (BACKEND NODES)
############################################

resource "oci_core_instance_configuration" "bharatmart_backend_config" {
  count = var.enable_instance_pool ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-backend-config"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.compartment_id
      shape          = var.compute_instance_shape
      display_name   = "${var.project_name}-${var.environment}-backend-pool"

      # AD is intentionally NOT set here for multi-AD pools.
      # It will be determined by the instance pool placement_configurations.

      shape_config {
        ocpus         = var.compute_instance_ocpus
        memory_in_gbs = var.compute_instance_memory_in_gb
      }

      # For private backends, we always use backend subnets.
      # Public IP use-case (for debugging only) still supported via var.enable_backend_public_ip.
      create_vnic_details {
        subnet_id = oci_core_subnet.backend_subnet_ad1.id
        assign_public_ip = var.enable_backend_public_ip
      }

      source_details {
        source_type = "image"
        image_id    = var.image_id
      }

      metadata = {
        ssh_authorized_keys = var.ssh_public_key
        user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs git

# Clone BharatMart repo
cd /home/opc
if [ ! -d "oci-multi-tier-web-app-ecommerce" ]; then
  git clone https://github.com/atingupta2006/oci-multi-tier-web-app-ecommerce.git
fi

cd oci-multi-tier-web-app-ecommerce
npm install

# You can add PM2 / systemd here if you want to auto-start the backend
EOF
        )
      }

      freeform_tags = merge(local.common_tags, {
        "Role" = "backend-pool"
      })
    }
  }

  freeform_tags = local.common_tags
}

############################################
# INSTANCE POOL (BACKEND – MULTI AD)
############################################

resource "oci_core_instance_pool" "bharatmart_backend_pool" {
  count = var.enable_instance_pool ? 1 : 0

  compartment_id            = var.compartment_id
  instance_configuration_id = oci_core_instance_configuration.bharatmart_backend_config[0].id
  display_name              = "${var.project_name}-${var.environment}-backend-pool"
  size                      = var.instance_pool_size

  # Avoid “instance config in use” 409 conflicts on updates
  lifecycle {
    create_before_destroy = true
  }

  # Place instances across all ADs, each with its own backend subnet
  dynamic "placement_configurations" {
    for_each = data.oci_identity_availability_domains.all_ads.availability_domains
    content {
      availability_domain = placement_configurations.value.name
      primary_subnet_id   = local.backend_subnet_map[placement_configurations.value.name]
    }
  }

  freeform_tags = merge(local.common_tags, {
    "Role" = "backend-pool"
  })
}

############################################
# AUTO SCALING CONFIGURATION (BACKEND POOL)
############################################

resource "oci_autoscaling_auto_scaling_configuration" "bharatmart_backend_autoscaling" {
  count = var.enable_instance_pool ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-backend-autoscaling"
  is_enabled     = true

  freeform_tags = merge(local.common_tags, {
    "Role" = "backend-autoscaling"
  })

  # Attach autoscaling to backend instance pool
  auto_scaling_resources {
    id   = oci_core_instance_pool.bharatmart_backend_pool[0].id
    type = "instancePool"
  }

  # Single threshold policy with both scale-out and scale-in rules
  policies {
    display_name = "CPU-based Autoscaling"
    policy_type  = "threshold"

    # Capacity bounds (driven by variables)
    capacity {
      initial = var.instance_pool_size
      min     = var.instance_pool_min_size
      max     = var.instance_pool_max_size
    }

    # SCALE OUT when CPU > 70%
    rules {
      display_name = "Scale-out when CPU > 70%"

      action {
        type  = "CHANGE_COUNT_BY"
        value = 1
      }

      metric {
        metric_source    = "COMPUTE_AGENT"
        metric_type      = "CPU_UTILIZATION"
        pending_duration = "PT3M"

        threshold {
          operator = "GT"
          value    = 70
        }
      }
    }

    # SCALE IN when CPU < 30%
    rules {
      display_name = "Scale-in when CPU < 30%"

      action {
        type  = "CHANGE_COUNT_BY"
        value = -1
      }

      metric {
        metric_source    = "COMPUTE_AGENT"
        metric_type      = "CPU_UTILIZATION"
        pending_duration = "PT3M"

        threshold {
          operator = "LT"
          value    = 30
        }
      }
    }
  }
}
