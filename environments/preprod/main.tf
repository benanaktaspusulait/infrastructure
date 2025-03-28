terraform {
  required_version = ">= 1.0.0"
  
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Import modules
module "kubernetes" {
  source = "../../modules/kubernetes"
  
  cluster_name = "preprod-cluster"
  network = "preprod-network"
  subnetwork = "preprod-subnetwork"
  node_pools = [
    {
      name         = "default-pool"
      node_count   = 4
      machine_type = "Standard_D8s_v3"
      disk_size_gb = 200
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
  
  environment = "preprod"
  vpc_cidr = "10.2.0.0/16"
  region = "us-central1"
  enable_private_subnets = true
  enable_public_subnets = true
  subnet_count = 3
  enable_nat = true
}

module "storage" {
  source = "../../modules/storage"
  
  environment = "preprod"
  postgresql_storage_size = "50Gi"
  redis_storage_size = "20Gi"
  kafka_storage_size = "100Gi"
  storage_reclaim_policy = "Retain"
  enable_backup = true
  backup_retention_days = 30
}

module "monitoring" {
  source = "../../modules/monitoring"
  
  environment = "preprod"
  prometheus_storage_size = "100Gi"
  prometheus_retention_days = 30
  grafana_storage_size = "20Gi"
  alertmanager_storage_size = "20Gi"
  enable_prometheus = true
  enable_grafana = true
  enable_alertmanager = true
}

module "security" {
  source = "../../modules/security"
  
  environment = "preprod"
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