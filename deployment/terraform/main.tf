# Configure the OCI Provider
provider "oci" {
  region = var.region
}

# Get Availability Domain
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

locals {
  ad_name = var.availability_domain
  common_tags = merge(var.tags, {
    "Name"        = "${var.project_name}-${var.environment}"
    "Environment" = var.environment
  })
}

# Create VCN
resource "oci_core_vcn" "bharatmart_vcn" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.project_name}-${var.environment}-vcn"
  dns_label      = "${var.project_name}${var.environment}"

  freeform_tags = local.common_tags
}

# Create Internet Gateway for public subnet
resource "oci_core_internet_gateway" "bharatmart_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-${var.environment}-igw"
  enabled        = true

  freeform_tags = local.common_tags
}

# Create NAT Gateway for private subnet (optional but recommended)
resource "oci_core_nat_gateway" "bharatmart_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-${var.environment}-nat"

  freeform_tags = local.common_tags
}

# Create Public Subnet (for Load Balancer)
resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.bharatmart_vcn.id
  cidr_block        = var.public_subnet_cidr
  display_name      = "${var.project_name}-${var.environment}-public-subnet"
  dns_label         = "public"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  security_list_ids = [oci_core_security_list.public_security_list.id]
  route_table_id    = oci_core_route_table.public_route_table.id

  prohibit_public_ip_on_vnic = false

  freeform_tags = local.common_tags
}

# Create Private Subnet (for Compute instances)
resource "oci_core_subnet" "private_subnet" {
  compartment_id     = var.compartment_id
  vcn_id             = oci_core_vcn.bharatmart_vcn.id
  cidr_block         = var.private_subnet_cidr
  display_name       = "${var.project_name}-${var.environment}-private-subnet"
  dns_label          = "private"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  security_list_ids  = [oci_core_security_list.private_security_list.id]
  route_table_id     = var.enable_nat_gateway ? oci_core_route_table.private_route_table[0].id : oci_core_vcn.bharatmart_vcn.default_route_table_id

  prohibit_public_ip_on_vnic = true

  freeform_tags = local.common_tags
}

# Public Route Table (routes traffic to Internet Gateway)
resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-${var.environment}-public-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.bharatmart_igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = local.common_tags
}

# Private Route Table (routes traffic to NAT Gateway)
resource "oci_core_route_table" "private_route_table" {
  count = var.enable_nat_gateway ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-${var.environment}-private-rt"

  route_rules {
    network_entity_id = oci_core_nat_gateway.bharatmart_nat[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = local.common_tags
}

# Public Security List (for Load Balancer)
resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-${var.environment}-public-sl"

  # Allow inbound HTTP/HTTPS traffic
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    description = "Allow HTTP from internet"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    description = "Allow HTTPS from internet"

    tcp_options {
      min = 443
      max = 443
    }
  }

  # Allow all outbound traffic
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all outbound traffic"
  }

  freeform_tags = local.common_tags
}

# Private Security List (for Compute instances)
resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.bharatmart_vcn.id
  display_name   = "${var.project_name}-${var.environment}-private-sl"

  # Allow inbound from Load Balancer subnet (port 3000 for BharatMart API)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.public_subnet_cidr
    source_type = "CIDR_BLOCK"
    description = "Allow API traffic from Load Balancer"

    tcp_options {
      min = 3000
      max = 3000
    }
  }

  # Allow inbound SSH from VCN (for management)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    description = "Allow SSH from within VCN"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow all outbound traffic (for NAT Gateway)
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all outbound traffic"
  }

  freeform_tags = local.common_tags
}

# Create Compute Instances for Backend API
resource "oci_core_instance" "bharatmart_backend" {
  count = var.compute_instance_count

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${var.project_name}-${var.environment}-backend-${count.index + 1}"
  shape               = var.compute_instance_shape

  create_vnic_details {
    subnet_id              = oci_core_subnet.private_subnet.id
    assign_public_ip       = false
    skip_source_dest_check = false
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      # Basic setup script - install Node.js
      yum update -y
      curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
      yum install -y nodejs
      # Note: Application deployment should be done separately or via user_data expansion
      EOF
    )
  }

  freeform_tags = merge(local.common_tags, {
    "Role" = "backend-api"
    "Type" = "bharatmart-backend"
  })
}

# Create Load Balancer
resource "oci_load_balancer_load_balancer" "bharatmart_lb" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-lb"
  shape          = var.load_balancer_shape
  is_private     = false

  shape_details {
    minimum_bandwidth_in_mbps = var.load_balancer_shape_min_mbps
    maximum_bandwidth_in_mbps = var.load_balancer_shape_max_mbps
  }

  subnet_ids = [
    oci_core_subnet.public_subnet.id
  ]

  freeform_tags = local.common_tags
}

# Create Backend Set for Load Balancer
resource "oci_load_balancer_backend_set" "bharatmart_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.bharatmart_lb.id
  name             = "bharatmart-api-backend"
  policy           = "ROUND_ROBIN"
  health_checker {
    protocol          = "HTTP"
    port              = 3000
    url_path          = "/api/health"
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
    return_code       = 200
  }
}

# Add Compute Instances as Backend Servers
resource "oci_load_balancer_backend" "bharatmart_backend_servers" {
  count = var.compute_instance_count

  load_balancer_id = oci_load_balancer_load_balancer.bharatmart_lb.id
  backendset_name  = oci_load_balancer_backend_set.bharatmart_backend_set.name
  ip_address       = oci_core_instance.bharatmart_backend[count.index].private_ip
  port             = 3000
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# Create Listener for Load Balancer (HTTP on port 80)
resource "oci_load_balancer_listener" "bharatmart_http_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.bharatmart_lb.id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.bharatmart_backend_set.name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "60"
  }
}

