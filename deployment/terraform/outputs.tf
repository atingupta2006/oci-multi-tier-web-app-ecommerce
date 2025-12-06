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

output "load_balancer_id" {
  description = "OCID of the Load Balancer"
  value       = oci_load_balancer_load_balancer.bharatmart_lb.id
}

output "load_balancer_ip_address" {
  description = "Public IP address of the Load Balancer"
  value       = oci_load_balancer_load_balancer.bharatmart_lb.ip_address_details[0].ip_address
}

output "load_balancer_hostname" {
  description = "Hostname of the Load Balancer"
  value       = oci_load_balancer_load_balancer.bharatmart_lb.ip_address_details[0].hostname
}

output "compute_instance_ids" {
  description = "OCIDs of the Compute instances"
  value       = oci_core_instance.bharatmart_backend[*].id
}

output "compute_instance_private_ips" {
  description = "Private IP addresses of the Compute instances"
  value       = oci_core_instance.bharatmart_backend[*].private_ip
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.bharatmart_igw.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway (if enabled)"
  value       = var.enable_nat_gateway ? oci_core_nat_gateway.bharatmart_nat[0].id : null
}

output "load_balancer_url" {
  description = "URL to access the application via Load Balancer"
  value       = "http://${oci_load_balancer_load_balancer.bharatmart_lb.ip_address_details[0].hostname}"
}

