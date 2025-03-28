terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"  # or your local context name
}

# Outputs
output "cluster_endpoint" {
  value = "https://kubernetes.default.svc.cluster.local"
}

output "cluster_ca_certificate" {
  value     = file("~/.kube/config")
  sensitive = true
}

output "cluster_name" {
  value = var.cluster_name
}

output "cluster_id" {
  value = var.cluster_name
} 