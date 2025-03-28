resource "kubernetes_cluster" "main" {
  name = var.cluster_name

  # Node pool configuration
  dynamic "node_pool" {
    for_each = var.node_pools
    content {
      name       = node_pool.value.name
      node_count = node_pool.value.node_count
      machine_type = node_pool.value.machine_type
      disk_size_gb = node_pool.value.disk_size_gb
      disk_type    = node_pool.value.disk_type
    }
  }

  # Network configuration
  network_config {
    network    = var.network
    subnetwork = var.subnetwork
  }

  # Master configuration
  master_config {
    version = var.kubernetes_version
  }

  # Security configuration
  security_config {
    enable_private_nodes = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }

  # Maintenance configuration
  maintenance_config {
    maintenance_window {
      recurring_window {
        start_time = var.maintenance_start_time
        end_time   = var.maintenance_end_time
        recurrence = var.maintenance_recurrence
      }
    }
  }

  # Monitoring configuration
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  # Logging configuration
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
}

# Output the cluster credentials
output "cluster_endpoint" {
  value = kubernetes_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  value     = kubernetes_cluster.main.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_name" {
  value = kubernetes_cluster.main.name
}

output "cluster_id" {
  value = kubernetes_cluster.main.id
} 