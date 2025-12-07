############################################
# INSTANCE POOL & AUTO SCALING (Day 4 Lab 6)
# Scalable App Using OCI Load Balancer + Auto Scaling
############################################

# Get all Availability Domains for fault domain distribution
data "oci_identity_availability_domains" "all_ads" {
  compartment_id = var.tenancy_ocid
}

############################################
# INSTANCE CONFIGURATION
############################################

resource "oci_core_instance_configuration" "bharatmart_backend_config" {
  count = var.enable_instance_pool ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-backend-config"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id      = var.compartment_id
      shape               = var.compute_instance_shape
      display_name        = "${var.project_name}-${var.environment}-backend-pool"
      availability_domain = data.oci_identity_availability_domain.primary.name

      shape_config {
        ocpus         = var.compute_instance_ocpus
        memory_in_gbs = var.compute_instance_memory_in_gb
      }

      create_vnic_details {
        subnet_id        = var.enable_backend_public_ip ? oci_core_subnet.public_subnet.id : oci_core_subnet.private_subnet.id
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
git clone https://github.com/atingupta2006/oci-multi-tier-web-app-ecommerce.git
cd oci-multi-tier-web-app-ecommerce
npm install
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
# INSTANCE POOL
############################################

resource "oci_core_instance_pool" "bharatmart_backend_pool" {
  count = var.enable_instance_pool ? 1 : 0

  compartment_id            = var.compartment_id
  instance_configuration_id = oci_core_instance_configuration.bharatmart_backend_config[0].id
  display_name              = "${var.project_name}-${var.environment}-backend-pool"
  size                      = var.instance_pool_size

  dynamic "placement_configurations" {
    for_each = data.oci_identity_availability_domains.all_ads.availability_domains
    content {
      availability_domain = placement_configurations.value.name
      primary_subnet_id   = var.enable_backend_public_ip ? oci_core_subnet.public_subnet.id : oci_core_subnet.private_subnet.id
    }
  }

  freeform_tags = merge(local.common_tags, {
    "Role" = "backend-pool"
  })
}

############################################
# AUTO SCALING CONFIGURATION
############################################

resource "oci_autoscaling_auto_scaling_configuration" "bharatmart_backend_autoscaling" {
  count = var.enable_instance_pool ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-backend-autoscaling"
  is_enabled     = true

  freeform_tags = merge(local.common_tags, {
    "Role" = "backend-autoscaling"
  })

  auto_scaling_resources {
    id   = oci_core_instance_pool.bharatmart_backend_pool[0].id
    type = "instancePool"  # required exact value
  }

  policies {
    display_name = "CPU-based Autoscaling"
    policy_type  = "threshold"

    # Make scaling limits match your instance pool
    capacity {
      initial = var.instance_pool_size
      min     = var.instance_pool_min_size
      max     = var.instance_pool_max_size
    }

    # SCALE OUT (CPU > 70%)
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

    # SCALE IN (CPU < 30%)
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

