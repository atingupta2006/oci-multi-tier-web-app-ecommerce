############################################
# VCN & Subnet Outputs
############################################

output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.bharatmart_vcn.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.bharatmart_vcn.cidr_blocks[0]
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet"
  value       = oci_core_subnet.private_subnet.id
}

############################################
# Internet Gateway / NAT Gateway
############################################

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.bharatmart_igw.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway (if enabled)"
  value       = var.enable_nat_gateway ? oci_core_nat_gateway.bharatmart_nat[0].id : null
}

############################################
# Load Balancer Outputs
############################################

output "load_balancer_id" {
  description = "OCID of the Load Balancer"
  value       = oci_load_balancer_load_balancer.bharatmart_lb.id
}

output "load_balancer_public_ip" {
  description = "Public IP address of the Load Balancer"
  value       = oci_load_balancer_load_balancer.bharatmart_lb.ip_address_details[0].ip_address
}

output "load_balancer_url" {
  description = "URL to access the frontend application"
  value       = "http://${oci_load_balancer_load_balancer.bharatmart_lb.ip_address_details[0].ip_address}"
}

############################################
# Frontend VM Outputs
############################################

output "frontend_instance_id" {
  description = "OCID of the frontend compute instance"
  value       = oci_core_instance.bharatmart_frontend.id
}

output "frontend_public_ip" {
  description = "Public IP of frontend VM"
  value       = oci_core_instance.bharatmart_frontend.public_ip
}

output "frontend_private_ip" {
  description = "Private IP of frontend VM"
  value       = oci_core_instance.bharatmart_frontend.private_ip
}

############################################
# Backend VM Outputs
############################################

output "backend_instance_ids" {
  description = "OCIDs of backend compute instances"
  value       = [for i in oci_core_instance.bharatmart_backend : i.id]
}

output "backend_private_ips" {
  description = "Private IPs of backend compute instances"
  value       = [for i in oci_core_instance.bharatmart_backend : i.private_ip]
}

output "backend_public_ips" {
  description = "Public IPs for backend instances (only if enabled)"
  value       = var.enable_backend_public_ip ? [for i in oci_core_instance.bharatmart_backend : i.public_ip] : []
}

############################################
# Convenience URLs
############################################

output "frontend_url" {
  description = "URL to access the frontend"
  value       = "http://${oci_load_balancer_load_balancer.bharatmart_lb.ip_address_details[0].ip_address}"
}

output "backend_api_url" {
  description = "Base URL for backend API via Load Balancer"
  value       = "http://${oci_load_balancer_load_balancer.bharatmart_lb.ip_address_details[0].ip_address}:3000/api"
}
