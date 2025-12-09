############################################################
# monitoring-logging.tf – OCI Observability & SRE Setup
#
# Responsibilities:
#   • IAM for custom metrics (backend instances → Monitoring)
#   • Central Log Group + custom logs
#   • Flow logs (subnet-level)
#   • Load Balancer logs (access/error)
#   • Notification topic for alarms
#   • Alarms for:
#       - Compute (CPU, Memory, Disk)
#       - Load balancer health, rate, latency
#       - Instance pool size
#       - Network traffic
#
# Design notes:
#   • Metrics that come from prom-client in the app should be named
#     with a `bm_` prefix (e.g. bm_http_requests_total) and will be
#     scraped per-instance by the Unified Monitoring Agent.
#   • Custom metrics namespace is `custombharatmart`.
############################################################


########################
# IAM for Custom Metrics (REQUIRED)
########################

# We need the compartment *name* for IAM policy statements.
data "oci_identity_compartment" "backend_compartment" {
  id = var.compartment_ocid
}

# Dynamic Group:
#   • All compute instances in the target compartment
#   • Used to allow them to push custom metrics
#   • Created in tenancy home region via provider alias oci.home_region
resource "oci_identity_dynamic_group" "backend_instances" {
  provider       = oci.home_region
  name           = "${var.project_name}-backend-instances"
  compartment_id = var.tenancy_ocid
  description    = "Dynamic group for BharatMart backend instances to write metrics"

  # Match instances by compartment ID.
  # You can further narrow this using tags if desired.
  matching_rule = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
}

# IAM Policy:
#   • Grant dynamic group permission to manage metrics in target compartment
#   • "manage metrics" = push custom metrics into OCI Monitoring
resource "oci_identity_policy" "backend_metrics_policy" {
  provider       = oci.home_region
  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-backend-metrics-policy"
  description    = "Allow backend instances to write custom metrics to Monitoring"

  statements = [
    "ALLOW dynamic-group ${oci_identity_dynamic_group.backend_instances.name} TO manage metrics IN compartment ${data.oci_identity_compartment.backend_compartment.name}"
  ]
}


########################
# Log Group (central)
########################

resource "oci_logging_log_group" "bharatmart_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-log-group"
  description    = "Central log group for BharatMart application, network, and load balancer logs"
}


########################
# VCN Flow Logs (Subnet Level)
########################

# Note:
#   • Flow logs are configured on subnets, not the VCN object.
#   • Valid categories for the "flowlogs" service: subnet, vnic, instance, networkloadbalancer.

# Flow Logs – Public subnet (frontend + LB)
resource "oci_logging_log" "vcn_flow_log_public" {
  log_group_id = oci_logging_log_group.bharatmart_log_group.id
  display_name = "${var.project_name}-flow-log-public-subnet"
  log_type     = "SERVICE"
  is_enabled   = true

  configuration {
    source {
      source_type = "OCISERVICE"
      service     = "flowlogs"
      resource    = oci_core_subnet.public_subnet.id
      category    = "subnet"
    }
  }
}

# Flow Logs – Backend subnets (one per backend subnet)
resource "oci_logging_log" "vcn_flow_log_backend" {
  count        = local.max_backend_ads
  log_group_id = oci_logging_log_group.bharatmart_log_group.id
  display_name = "${var.project_name}-flow-log-backend-subnet-${count.index + 1}"
  log_type     = "SERVICE"
  is_enabled   = true

  configuration {
    source {
      source_type = "OCISERVICE"
      service     = "flowlogs"
      resource    = oci_core_subnet.backend_subnet[count.index].id
      category    = "subnet"
    }
  }
}


########################
# Load Balancer Logs
########################

# Load Balancer Access Logs:
#   • HTTP access details (method, path, status, response time, etc.)
resource "oci_logging_log" "lb_access_log" {
  log_group_id = oci_logging_log_group.bharatmart_log_group.id
  display_name = "${var.project_name}-lb-access-log"
  log_type     = "SERVICE"
  is_enabled   = true

  configuration {
    source {
      source_type = "OCISERVICE"
      service     = "loadbalancer"
      resource    = oci_load_balancer_load_balancer.app_lb.id
      category    = "access"
    }
  }
}

# Load Balancer Error Logs:
#   • Listener/backend errors, connection issues, etc.
resource "oci_logging_log" "lb_error_log" {
  log_group_id = oci_logging_log_group.bharatmart_log_group.id
  display_name = "${var.project_name}-lb-error-log"
  log_type     = "SERVICE"
  is_enabled   = true

  configuration {
    source {
      source_type = "OCISERVICE"
      service     = "loadbalancer"
      resource    = oci_load_balancer_load_balancer.app_lb.id
      category    = "error"
    }
  }
}


########################
# Custom Logs for Application (Frontend + Backend)
########################

# Frontend NGINX Access Log (high volume)
resource "oci_logging_log" "frontend_nginx_access_log" {
  log_group_id = oci_logging_log_group.bharatmart_log_group.id
  display_name = "${var.project_name}-frontend-nginx-access-log"
  log_type     = "CUSTOM"
  is_enabled   = true
}

# Frontend NGINX Error Log (low volume, important for debugging)
resource "oci_logging_log" "frontend_nginx_error_log" {
  log_group_id = oci_logging_log_group.bharatmart_log_group.id
  display_name = "${var.project_name}-frontend-nginx-error-log"
  log_type     = "CUSTOM"
  is_enabled   = true
}

# Backend Application Log (Node.js backend, Winston JSON logs)
#   • Mapped in instance-pool-autoscaling.tf:
#       /opt/bharatmart/logs/api.log
resource "oci_logging_log" "backend_app_log" {
  log_group_id = oci_logging_log_group.bharatmart_log_group.id
  display_name = "${var.project_name}-backend-app-log"
  log_type     = "CUSTOM"
  is_enabled   = true
}


########################
# Notification Topic for Alarms
########################

resource "oci_ons_notification_topic" "alarm_topic" {
  compartment_id = var.compartment_ocid
  name           = "${var.project_name}-alarm-topic"
  description    = "Notification topic for BharatMart monitoring alarms"
}


########################
# Monitoring Alarms – Compute Instances
#
# These use the built-in oci_computeagent metrics:
#   • CpuUtilization
#   • MemoryUtilization
#   • DiskUtilization
#
# Metric namespace: oci_computeagent
########################

# Frontend high CPU
resource "oci_monitoring_alarm" "frontend_high_cpu" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-frontend-high-cpu"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_computeagent"

  # NOTE: no dimension filter here → any frontend/backends match.
  # You can scope this later via dimensions (resourceId, displayName, etc.).
  query            = "CpuUtilization[1m].mean() > 80"
  severity         = "CRITICAL"
  body             = "Frontend instance CPU utilization is above 80%."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT4H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}

# Frontend high memory
resource "oci_monitoring_alarm" "frontend_high_memory" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-frontend-high-memory"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_computeagent"

  query            = "MemoryUtilization[1m].mean() > 85"
  severity         = "WARNING"
  body             = "Frontend instance memory utilization is above 85%."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT4H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}

# Backend high CPU (instance pool nodes)
resource "oci_monitoring_alarm" "backend_high_cpu" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-backend-high-cpu"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_computeagent"

  query            = "CpuUtilization[1m].mean() > 80"
  severity         = "CRITICAL"
  body             = "Backend instance CPU utilization is above 80%."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT4H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}

# Backend high memory
resource "oci_monitoring_alarm" "backend_high_memory" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-backend-high-memory"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_computeagent"

  query            = "MemoryUtilization[1m].mean() > 85"
  severity         = "WARNING"
  body             = "Backend instance memory utilization is above 85%."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT4H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}

# Disk utilization (both frontend + backend)
resource "oci_monitoring_alarm" "compute_disk_utilization" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-compute-disk-utilization"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_computeagent"

  query            = "DiskUtilization[1m].mean() > 90"
  severity         = "CRITICAL"
  body             = "Compute instance disk utilization is above 90%."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT4H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}


########################
# Monitoring Alarms – Load Balancer
#
# Namespace: oci_lbaas
########################

# No healthy backend servers
resource "oci_monitoring_alarm" "lb_backend_health" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-lb-backend-health"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_lbaas"

  query            = "HealthyBackendServers[1m].mean() < 1"
  severity         = "CRITICAL"
  body             = "Load balancer has no healthy backend servers."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT2M"

  repeat_notification_duration = "PT1H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}

# High request rate
resource "oci_monitoring_alarm" "lb_high_request_rate" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-lb-high-request-rate"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_lbaas"

  query            = "RequestRate[1m].mean() > 1000"
  severity         = "WARNING"
  body             = "Load balancer request rate is above 1000 requests/second."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT2H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}

# High response time
resource "oci_monitoring_alarm" "lb_high_response_time" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-lb-high-response-time"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_lbaas"

  query            = "ResponseTime[1m].mean() > 2000"
  severity         = "WARNING"
  body             = "Load balancer response time is above 2000 ms."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT2H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}


########################
# Monitoring Alarms – Instance Pool
#
# Namespace: oci_compute_management (InstancePoolSize)
########################

# Too few instances in pool
resource "oci_monitoring_alarm" "instance_pool_low_size" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-instance-pool-low-size"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_compute_management"

  query            = "InstancePoolSize[1m].mean() < ${var.backend_pool_min_size}"
  severity         = "WARNING"
  body             = "Instance pool size is below the configured minimum."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT2H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}

# Too many instances (approaching max capacity)
resource "oci_monitoring_alarm" "instance_pool_high_size" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-instance-pool-high-size"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_compute_management"

  query            = "InstancePoolSize[1m].mean() > ${var.backend_pool_max_size * 0.9}"
  severity         = "INFO"
  body             = "Instance pool size is approaching maximum capacity."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT4H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}


########################
# Monitoring Alarms – Network
#
# Namespace: oci_computeagent
########################

# High network ingress
resource "oci_monitoring_alarm" "network_high_ingress" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-network-high-ingress"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_computeagent"

  query            = "NetworkBytesIn[1m].mean() > 1000000000"
  severity         = "INFO"
  body             = "High network ingress traffic detected."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT4H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}

# High network egress
resource "oci_monitoring_alarm" "network_high_egress" {
  compartment_id        = var.compartment_ocid
  display_name          = "${var.project_name}-network-high-egress"
  is_enabled            = true
  metric_compartment_id = var.compartment_ocid
  namespace             = "oci_computeagent"

  query            = "NetworkBytesOut[1m].mean() > 1000000000"
  severity         = "INFO"
  body             = "High network egress traffic detected."
  message_format   = "ONS_OPTIMIZED"
  pending_duration = "PT5M"

  repeat_notification_duration = "PT4H"
  destinations                 = [oci_ons_notification_topic.alarm_topic.id]
}
