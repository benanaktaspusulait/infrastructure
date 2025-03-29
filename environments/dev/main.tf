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
  name = "istio-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "base"
  version = "1.20.0"
  namespace = "istio-system"
  create_namespace = true
  force_update = true
  cleanup_on_fail = true
  replace = true
  atomic = true
  wait = true
  timeout = 600
}

resource "helm_release" "argocd" {
  name = "argocd-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "5.51.0"
  namespace = "argocd"
  create_namespace = true
  force_update = true
  cleanup_on_fail = true
  replace = true
  atomic = true
  wait = true
  timeout = 600
}

# Create namespaces
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(["gateway", "config", "fys", "stok", "frontend"])

  metadata {
    name = each.value
    labels = {
      name = each.value
    }
  }
  timeouts {
    delete = "10m"
  }
  timeouts {
    delete = "10m"
  }
}

# Create storage classes
resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }
  storage_provisioner = "k8s.io/minikube-hostpath"
  reclaim_policy     = "Retain"
  lifecycle {
    ignore_changes = [
      storage_provisioner,
      reclaim_policy
    ]
  }
} 