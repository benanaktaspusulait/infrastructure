# Create VPC
resource "kubernetes_network" "vpc" {
  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr
}

# Create subnets
resource "kubernetes_network_subnet" "private" {
  count = 3
  name  = "${var.environment}-private-subnet-${count.index + 1}"
  network = kubernetes_network.vpc.name
  cidr = cidrsubnet(var.vpc_cidr, 8, count.index)
  region = var.region
  private_ip_google_access = true
}

resource "kubernetes_network_subnet" "public" {
  count = 3
  name  = "${var.environment}-public-subnet-${count.index + 1}"
  network = kubernetes_network.vpc.name
  cidr = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  region = var.region
}

# Create firewall rules
resource "kubernetes_firewall" "internal" {
  name    = "${var.environment}-internal"
  network = kubernetes_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.vpc_cidr]
  target_tags   = ["internal"]
}

# Create Cloud NAT
resource "kubernetes_cloud_nat" "nat" {
  name    = "${var.environment}-nat"
  network = kubernetes_network.vpc.name
  region  = var.region

  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Outputs
output "vpc_id" {
  value = kubernetes_network.vpc.id
}

output "vpc_name" {
  value = kubernetes_network.vpc.name
}

output "subnet_ids" {
  value = concat(
    kubernetes_network_subnet.private[*].id,
    kubernetes_network_subnet.public[*].id
  )
}

output "private_subnet_ids" {
  value = kubernetes_network_subnet.private[*].id
}

output "public_subnet_ids" {
  value = kubernetes_network_subnet.public[*].id
} 