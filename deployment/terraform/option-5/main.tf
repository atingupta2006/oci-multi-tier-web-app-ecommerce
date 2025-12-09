############################################################
# main.tf – Network, Frontend, and Load Balancer (Multi-AD)
#
# Responsibilities:
#   • Discover availability domains
#   • Create VCN + gateways + route tables + security lists
#   • Create public + backend subnets (AD-aware)
#   • Create public Load Balancer (frontend + backend listeners)
#   • Create frontend compute instances (standalone)
#   • Generate shared .env content from env.tpl (includes metrics & logging)
#   • Configure frontend Cloud Agent logging for NGINX
#
# NOTE:
#   • Backend instance pool + autoscaling live in instance-pool-autoscaling.tf
#   • Logging/Monitoring/Alarms live in monitoring-logging.tf
############################################################


########################
# AVAILABILITY DOMAINS
########################

# Dynamically discover ADs in the tenancy.
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

locals {
  frontend_cloud_init = templatefile("${path.module}/cloud-init-frontend.tpl", {
    frontend_cloud_agent_config_b64 = local.frontend_cloud_agent_config_b64
    # FIX: Pass the full environment base64 for Vite build
    app_env_b64 = local.app_env_b64
    var = {
      github_repo_url = var.github_repo_url
    }
  })
  
  # List of AD names, e.g.
  # ["kIdk:EU-FRANKFURT-1-AD-1", "…-AD-2", …]
  ad_names = [
    for ad in data.oci_identity_availability_domains.ads.availability_domains :
    ad.name
  ]

  ad_count = length(local.ad_names)

  # Backend subnet CIDRs we plan to use.
  # We will only use as many as:
  #   min(number of ADs, number of CIDRs in this list)
  backend_subnet_cidrs = [
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]

  # Effective number of backend ADs actually used.
  max_backend_ads = local.ad_count > length(local.backend_subnet_cidrs) ? length(local.backend_subnet_cidrs) : local.ad_count

  # Shape helpers – detect if frontend/backend shapes are flexible.
  is_frontend_flexible_shape = can(regex("Flex$", var.frontend_shape))
  is_backend_flexible_shape  = can(regex("Flex$", var.backend_shape))
}


########################
# VCN
########################

resource "oci_core_vcn" "bharatmart_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-vcn"
  dns_label      = "bmartvcn"
}


########################
# GATEWAYS
########################

# Internet Gateway for public subnet (frontend + LB)
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  enabled        = true
  display_name   = "${var.project_name}-igw"
}

# NAT Gateway for backend subnets (outbound internet, no public IP)
resource "oci_core_nat_gateway" "nat" {
  
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-nat"
}


########################
# ROUTE TABLES
########################

# Public route table: direct internet access via IGW.
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# Private route table: egress via NAT gateway only.
resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }
}


########################
# SECURITY LISTS
########################

# Public subnet security list:
#   • SSH from configurable CIDR
#   • HTTP frontend port from anywhere
#   • Backend API port from anywhere (via LB)
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.bharatmart_vcn.id
  display_name = "${var.project_name}-public-sl"

  # SSH ingress (admin access)
  ingress_security_rules {
    protocol    = "6"                       # TCP
    source      = var.ssh_ingress_cidr
    description = "SSH ingress"
    tcp_options {
      min = 22
      max = 22
    }
  }

  
  # HTTP frontend (NGINX)
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP to frontend"
    tcp_options {
      min = var.frontend_port
      max = var.frontend_port
    }
  }

  # Backend API port exposed via LB listener
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Backend API LB listener"
    tcp_options {
      min = var.backend_api_port
      max = var.backend_api_port
    }
  }

  # Allow all outbound traffic
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Backend subnet security list:
#   • Backend API port allowed only inside VCN
#   • SSH allowed inside VCN (jump/bastion from frontend if needed)
resource "oci_core_security_list" "backend_sl" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.bharatmart_vcn.id
  display_name = "${var.project_name}-backend-sl"

  # Backend service port (private, via LB → backend subnets)
  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/16"
    description = "Backend service port"
    tcp_options {
      min = var.backend_api_port
      max = var.backend_api_port
    }
  }

  # SSH within VCN (for internal debugging)
  ingress_security_rules {
    protocol    = "6"
    source = "10.0.0.0/16"
    description = "SSH within VCN"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow all outbound from backend hosts
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}


########################
# SUBNETS
########################

# Single public subnet used by:
#   • Frontend instances
#   • Public Load Balancer
resource "oci_core_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.bharatmart_vcn.id
  display_name = "${var.project_name}-public-subnet"
  dns_label = "pub"
  route_table_id = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
  prohibit_public_ip_on_vnic = false
}

# Backend private subnets:
#   • One per AD (up to max_backend_ads)
#   • No public IPs (private only)
#   • Used by backend instance pool
resource "oci_core_subnet" "backend_subnet" {
  count = local.max_backend_ads

  cidr_block = local.backend_subnet_cidrs[count.index]
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.bharatmart_vcn.id
  display_name = "${var.project_name}-backend-subnet-${count.index + 1}"
  dns_label = "bk${count.index + 1}"
  route_table_id = oci_core_route_table.private_rt.id
  security_list_ids = [oci_core_security_list.backend_sl.id]
  availability_domain = local.ad_names[count.index]
 
  prohibit_public_ip_on_vnic = true
}

# Convenience map: AD name → backend subnet OCID
locals {
  backend_subnet_map = {
    for idx in range(local.max_backend_ads) :
    local.ad_names[idx] => oci_core_subnet.backend_subnet[idx].id
  }
}


########################
# LOAD BALANCER (Public)
########################

resource "oci_load_balancer_load_balancer" "app_lb" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-lb"

  # Use Flexible shape so we can tune bandwidth (SRE-friendly)
  shape = "flexible"
  shape_details {
    minimum_bandwidth_in_mbps = var.lb_min_bandwidth_mbps
    maximum_bandwidth_in_mbps = var.lb_max_bandwidth_mbps
  }

  subnet_ids = [oci_core_subnet.public_subnet.id]
  is_private = false
}


########################
# ENV FILE (env.tpl → .env for backend + frontend)
########################
locals {
  
  ###########################################################################
  # 1) Render env.tpl with runtime values
  #
  # These values are injected into the backend + frontend via cloud-init.
  # NOTE:
  #   • lb_ip is the LB public IP
  #   • All Supabase + admin credentials come from terraform.tfvars
  ###########################################################################
  app_env = templatefile("${path.module}/env.tpl", {
    lb_ip                     = oci_load_balancer_load_balancer.app_lb.ip_address_details[0].ip_address
    supabase_url              = var.supabase_url
    supabase_anon_key         = var.supabase_anon_key
    supabase_service_role_key = var.supabase_service_role_key
   
    jwt_secret                = var.jwt_secret
    admin_email               = var.admin_email
    admin_password            = var.admin_password
  })

  # Base64 version for safe cloud-init injection
  app_env_b64 = base64encode(local.app_env)


  ###########################################################################
  # 2) Render UMA Prometheus config (NEW)
  #
  # FIX: REMOVE REDUNDANT LOCALS. CONFIG IS NOW IN instance-pool-autoscaling.tf HEREDOC.
  ###########################################################################
  # backend_uma_prom_config = templatefile("${path.module}/uma-prometheus.tpl", {})
  # backend_uma_prom_config_b64 = base64encode(local.backend_uma_prom_config)


  ###########################################################################
  # 3) Frontend Cloud Agent Logging Configuration
  #
  # Ships NGINX logs to OCI Logging using UMA's Logging plugin.
  # These values are written to:
  #   /opt/oracle-cloud-agent/plugins/logging/config.json
  #
  # IMPORTANT:
  #   backend UMA config and frontend log config are separate concerns.
  ###########################################################################
  frontend_cloud_agent_config = jsonencode({
    logSources = [
      {
        logId   = oci_logging_log.frontend_nginx_access_log.id
        logPath = "/var/log/nginx/access.log"
        logType = "custom"
        parser  = "text"
        labels = {
          service     = "bharatmart-frontend"
          environment = "production"
   
          logType     = "nginx-access"
        }
      },
      {
        logId   = oci_logging_log.frontend_nginx_error_log.id
        logPath = "/var/log/nginx/error.log"
        logType = "custom"
        parser  = "text"
        labels = {
          service = "bharatmart-frontend"
          environment = "production"
          logType = "nginx-error"
        }
      }
    ]
  })

  # Base64 version for cloud-init
  frontend_cloud_agent_config_b64 = base64encode(local.frontend_cloud_agent_config)
}


########################
# FRONTEND IMAGE
########################

data "oci_core_images" "frontend_image" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = var.os_version
  shape = var.frontend_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}


########################
# FRONTEND CLOUD-INIT (NGINX + static files)
########################

########################
# FRONTEND INSTANCES
########################

resource "oci_core_instance" "frontend" {
  count = var.frontend_instance_count

  availability_domain = local.ad_names[count.index % local.ad_count]
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project_name}-fe-${count.index + 1}"
  shape               = var.frontend_shape

  # Flex shape support
  dynamic "shape_config" {
    for_each = local.is_frontend_flexible_shape ? [1] : []
    content {
      ocpus         = var.frontend_flex_ocpus
      memory_in_gbs = var.frontend_flex_memory_gbs
    }
  }

  source_details {
    source_type = "image"
    source_id   = var.use_custom_images && var.frontend_custom_image_id != null ? var.frontend_custom_image_id : data.oci_core_images.frontend_image.images[0].id
  }

  ##########################################################
  # Attach FRONTEND cloud-init
  ##########################################################
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(local.frontend_cloud_init)
  }

  ##########################################################
  # REQUIRED: Enable UMA plugins
  #
  #  • Logging → send NGINX logs to OCI Logging
  #  • Monitoring → required for UMA agent runtime
  #  • Trace → optional (kept for consistency with backend)
  ##########################################################
  agent_config {
    is_management_disabled = false
    is_monitoring_disabled = false

    plugins_config {
      name          = "Custom Logs Monitoring"
      desired_state = "ENABLED"
    }

    plugins_config {
      name          = "Compute Instance Monitoring"
      desired_state = "ENABLED"
    }

    plugins_config {
      name          = "Compute Instance Run Command"
      desired_state = "ENABLED"
    }

    plugins_config {
      name          = "Management Agent"
      desired_state = "ENABLED"
    }
  }


  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = true
    hostname_label   = "fe-${count.index + 1}"
  }
}



########################
# BACKEND SETS & LISTENERS (LB)
########################

# Frontend backend set (targets: frontend VMs)
resource "oci_load_balancer_backendset" "frontend_bs" {
  name             = "frontend-backendset"
  load_balancer_id = oci_load_balancer_load_balancer.app_lb.id
  policy = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    url_path = "/"
    port     = var.frontend_port
  }
}

# Backend API backend set (targets: backend instance pool)
resource "oci_load_balancer_backendset" "backend_api_bs" {
  name             = "backend-api-backendset"
  load_balancer_id = oci_load_balancer_load_balancer.app_lb.id
  policy = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    url_path = "/api/health"
    port = var.backend_api_port
  }
}

# HTTP listener for frontend
resource "oci_load_balancer_listener" "frontend_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.app_lb.id
  name                     = "listener-frontend"
  default_backend_set_name = oci_load_balancer_backendset.frontend_bs.name
  port                     = var.frontend_port
  protocol                 = "HTTP"
}

# HTTP listener for 
  # backend API
resource "oci_load_balancer_listener" "backend_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.app_lb.id
  name                     = "listener-backend-api"
  default_backend_set_name = oci_load_balancer_backendset.backend_api_bs.name
  port                     = var.backend_api_port
  protocol                 = "HTTP"
}


########################
# FRONTEND → LB BACKEND REGISTRATION
########################

resource "oci_load_balancer_backend" "frontend_backends" {
  count = var.frontend_instance_count

  load_balancer_id = oci_load_balancer_load_balancer.app_lb.id
  backendset_name  = oci_load_balancer_backendset.frontend_bs.name

  ip_address = oci_core_instance.frontend[count.index].private_ip
  port       = var.frontend_port
  weight     = 1
  backup     = false
  drain      = false
  offline    = false
}