############################################
# INSTANCE POOL & AUTO SCALING (Day 4 Lab 6)
# Scalable App Using OCI Load Balancer + Auto Scaling
############################################

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
yum install -y nodejs
# Install BharatMart application (configure as needed)
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

  # Placement configuration - distribute across fault domains in primary AD
  placement_configurations {
    availability_domain = data.oci_identity_availability_domain.primary.name
    primary_subnet_id   = var.enable_backend_public_ip ? oci_core_subnet.public_subnet.id : oci_core_subnet.private_subnet.id

    # Distribute instances across fault domains for high availability
    primary_vnic_subnets {
      subnet_id = var.enable_backend_public_ip ? oci_core_subnet.public_subnet.id : oci_core_subnet.private_subnet.id
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
  count = var.enable_instance_pool && var.enable_auto_scaling ? 1 : 0

  compartment_id       = var.compartment_id
  display_name         = "${var.project_name}-${var.environment}-autoscaling"
  auto_scaling_resources {
    id   = oci_core_instance_pool.bharatmart_backend_pool[0].id
    type = "instance pool"
  }

  policies {
    capacity {
      initial = var.instance_pool_size
      max     = var.instance_pool_max_size
      min     = var.instance_pool_min_size
    }

    display_name = "Scale-out based on CPU utilization"
    policy_type  = "threshold"

    rules {
      display_name = "Scale-out when CPU > ${var.auto_scaling_scale_out_threshold}%"
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "GT"
          value    = var.auto_scaling_scale_out_threshold
        }
      }

      action {
        type  = "CHANGE_COUNT_BY"
        value = 1
      }
    }
  }

  policies {
    capacity {
      initial = var.instance_pool_size
      max     = var.instance_pool_max_size
      min     = var.instance_pool_min_size
    }

    display_name = "Scale-in based on CPU utilization"
    policy_type  = "threshold"

    rules {
      display_name = "Scale-in when CPU < ${var.auto_scaling_scale_in_threshold}%"
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "LT"
          value    = var.auto_scaling_scale_in_threshold
        }
      }

      action {
        type  = "CHANGE_COUNT_BY"
        value = -1
      }
    }
  }

  is_enabled = true

  freeform_tags = local.common_tags
}

