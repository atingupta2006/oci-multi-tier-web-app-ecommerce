############################################################
# outputs.tf — BharatMart Complete Outputs (Multi-AD, SRE-Ready)
############################################################

############################################################
# COMMON LOCALS
############################################################

locals {
  lb_public_ip      = oci_load_balancer_load_balancer.app_lb.ip_address_details[0].ip_address
  metrics_namespace = "custombharatmart"
}

############################################################
# NETWORK OUTPUTS
############################################################

output "vcn_id" {
  description = "OCID of the VCN used by BharatMart"
  value       = oci_core_vcn.bharatmart_vcn.id
}

output "vcn_cidr" {
  description = "VCN CIDR block"
  value       = oci_core_vcn.bharatmart_vcn.cidr_blocks[0]
}

output "public_subnet_id" {
  description = "Subnet for frontend instances and Load Balancer"
  value       = oci_core_subnet.public_subnet.id
}

output "backend_subnet_ids" {
  description = "List of backend private subnets (multi-AD safe)"
  value       = [for sn in oci_core_subnet.backend_subnet : sn.id]
}

output "backend_subnet_map" {
  description = "Mapping of AD → backend subnet ID"
  value       = local.backend_subnet_map
}

############################################################
# INTERNET GATEWAY / NAT GATEWAY
############################################################

output "internet_gateway_id" {
  value       = oci_core_internet_gateway.igw.id
  description = "OCID of the Internet Gateway"
}

output "nat_gateway_id" {
  value       = oci_core_nat_gateway.nat.id
  description = "OCID of the NAT Gateway"
}

############################################################
# LOAD BALANCER OUTPUTS
############################################################

output "load_balancer_id" {
  description = "OCID of the public Load Balancer"
  value       = oci_load_balancer_load_balancer.app_lb.id
}

output "load_balancer_public_ip" {
  description = "Primary public IP address of the Load Balancer"
  value       = local.lb_public_ip
}

output "service_urls" {
  description = "Frontend and Backend service entrypoints"
  value = {
    frontend_ui = "http://${local.lb_public_ip}"
    backend_api = "http://${local.lb_public_ip}:${var.backend_api_port}"
    healthcheck = "http://${local.lb_public_ip}:${var.backend_api_port}/api/health"
  }
}

############################################################
# FRONTEND OUTPUTS
############################################################

output "frontend_instance_ids" {
  description = "OCIDs of all frontend compute instances"
  value       = [for fe in oci_core_instance.frontend : fe.id]
}

output "frontend_public_ips" {
  description = "Public IP addresses of frontend compute instances"
  value       = [for fe in oci_core_instance.frontend : fe.public_ip]
}

output "frontend_private_ips" {
  description = "Private IPs of frontend compute instances"
  value       = [for fe in oci_core_instance.frontend : fe.private_ip]
}

output "frontend_debug_urls" {
  description = "Direct URLs to frontend instances (debug bypassing LB)"
  value       = [for fe in oci_core_instance.frontend : "http://${fe.public_ip}"]
}

############################################################
# BACKEND INSTANCE POOL — INSTANCE DISCOVERY (disabled)
# NOTE: Some OCI provider versions do not expose the same data sources
# for instance-pool instance discovery. To keep this module compatible
# across provider versions, instance-level discovery is disabled here.
############################################################

output "backend_instance_pool_id" {
  description = "OCID of the backend instance pool"
  value       = oci_core_instance_pool.backend_pool.id
}

output "backend_instance_configuration_id" {
  description = "OCID of the instance configuration used for backend VMs"
  value       = oci_core_instance_configuration.backend_config.id
}

output "backend_instance_ids" {
  description = "OCIDs of backend VMs created by the Instance Pool (discovery disabled)"
  value = []
}

output "backend_private_ips" {
  description = "Private IPs of backend instances discovered dynamically (discovery disabled)"
  value = []
}

output "backend_instance_details" {
  description = "Full backend instance details (discovery disabled)"
  value = []
}

############################################################
# OBSERVABILITY OUTPUTS (LOGGING + METRICS + ALARMS)
############################################################

output "log_group_id" {
  description = "Unified Log Group OCID"
  value       = oci_logging_log_group.bharatmart_log_group.id
}

output "observability_namespace" {
  description = "Custom metrics namespace used for Prometheus ingestion"
  value       = local.metrics_namespace
}

output "custom_log_ids" {
  description = "List of app + LB + flow logs"
  value = {
    lb_access_log_id = oci_logging_log.lb_access_log.id
    lb_error_log_id  = oci_logging_log.lb_error_log.id
    be_app_log_id    = oci_logging_log.backend_app_log.id
    fe_nginx_access  = oci_logging_log.frontend_nginx_access_log.id
    fe_nginx_error   = oci_logging_log.frontend_nginx_error_log.id
  }
}

output "alarm_topic_id" {
  description = "OCID of the ONS Notification Topic used for alarms"
  value       = oci_ons_notification_topic.alarm_topic.id
}

output "alarm_ids" {
  description = "All alarm OCIDs mapped by name"
  value = {
    frontend_high_cpu        = oci_monitoring_alarm.frontend_high_cpu.id
    frontend_high_memory     = oci_monitoring_alarm.frontend_high_memory.id
    backend_high_cpu         = oci_monitoring_alarm.backend_high_cpu.id
    backend_high_memory      = oci_monitoring_alarm.backend_high_memory.id
    compute_disk_utilization = oci_monitoring_alarm.compute_disk_utilization.id
    lb_backend_health        = oci_monitoring_alarm.lb_backend_health.id
    lb_high_request_rate     = oci_monitoring_alarm.lb_high_request_rate.id
    lb_high_response_time    = oci_monitoring_alarm.lb_high_response_time.id
    instance_pool_low_size   = oci_monitoring_alarm.instance_pool_low_size.id
    instance_pool_high_size  = oci_monitoring_alarm.instance_pool_high_size.id
    network_high_ingress     = oci_monitoring_alarm.network_high_ingress.id
    network_high_egress      = oci_monitoring_alarm.network_high_egress.id
  }
}

############################################################
# FULL SUMMARY OUTPUT (SRE FRIENDLY)
############################################################

output "bharatmart_summary" {
  description = "Human-friendly rollout summary of all important resources"
  value = {
    load_balancer_ip     = local.lb_public_ip
    frontend_public_ips  = [for fe in oci_core_instance.frontend : fe.public_ip]
    backend_private_ips  = []
    backend_instance_ids = []
    backend_pool_id      = oci_core_instance_pool.backend_pool.id
    backend_api_url      = "http://${local.lb_public_ip}:${var.backend_api_port}"
    metrics_namespace    = local.metrics_namespace
  }
}
