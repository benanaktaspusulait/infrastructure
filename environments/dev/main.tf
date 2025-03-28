terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  }
  
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
  }
}

# Import modules
module "kubernetes" {
  source = "../../modules/kubernetes"
  
  cluster_name = "dev-cluster"
  network = "dev-network"
  subnetwork = "dev-subnetwork"
  node_pools = [
    {
      name         = "default-pool"
      node_count   = 3
      machine_type = "Standard_D4s_v3"
      disk_size_gb = 100
      disk_type    = "StandardSSD_LRS"
    }
  ]
  kubernetes_version = "1.28.0"
  enable_private_nodes = true
  enable_private_endpoint = true
  master_ipv4_cidr_block = "172.16.0.0/28"
}

module "networking" {
  source = "../../modules/networking"
  
  environment = "dev"
  vpc_cidr = "10.0.0.0/16"
  region = "us-central1"
  enable_private_subnets = true
  enable_public_subnets = true
  subnet_count = 3
  enable_nat = true
}

module "storage" {
  source = "../../modules/storage"
  
  environment = "dev"
  postgresql_storage_size = "10Gi"
  redis_storage_size = "5Gi"
  kafka_storage_size = "20Gi"
  storage_reclaim_policy = "Retain"
  enable_backup = true
  backup_retention_days = 30
}

module "monitoring" {
  source = "../../modules/monitoring"
  
  environment = "dev"
  prometheus_storage_size = "50Gi"
  prometheus_retention_days = 15
  grafana_storage_size = "10Gi"
  alertmanager_storage_size = "10Gi"
  enable_prometheus = true
  enable_grafana = true
  enable_alertmanager = true
}

module "security" {
  source = "../../modules/security"
  
  environment = "dev"
  postgresql_password = var.postgresql_password
  redis_password = var.redis_password
  kafka_password = var.kafka_password
  enable_network_policies = true
  enable_pod_security_policy = true
  enable_rbac = true
}

# Helm releases
resource "helm_release" "istio" {
  name = "istio"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "base"
  version = "1.20.0"
  namespace = "istio-system"
  create_namespace = true
}

resource "helm_release" "argocd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "5.51.0"
  namespace = "argocd"
  create_namespace = true
}

# Create namespaces
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(["gateway", "config", "fys", "stok", "frontend", "argocd", "istio-system"])

  metadata {
    name = each.value
    labels = {
      name = each.value
    }
  }
}

# Create storage classes
resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }
  storage_provisioner = "k8s.io/minikube-hostpath"
  reclaim_policy     = "Retain"
}

# Create local persistent volumes
resource "kubernetes_persistent_volume" "local_pvs" {
  for_each = {
    postgresql = { size = "100Gi", path = "/data/postgresql" }
    redis      = { size = "50Gi", path = "/data/redis" }
    kafka      = { size = "200Gi", path = "/data/kafka" }
  }

  metadata {
    name = "${each.key}-pv"
  }
  spec {
    capacity = {
      storage = each.value.size
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "standard"
    persistent_volume_source {
      host_path {
        path = each.value.path
        type = "DirectoryOrCreate"
      }
    }
  }
}

# Create local persistent volume claims
resource "kubernetes_persistent_volume_claim" "local_pvcs" {
  for_each = {
    postgresql = { size = "100Gi" }
    redis      = { size = "50Gi" }
    kafka      = { size = "200Gi" }
  }

  metadata {
    name = "${each.key}-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "standard"
    resources {
      requests = {
        storage = each.value.size
      }
    }
  }
} 