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
  
  environment = "prod"
  cluster_name = "prod-cluster"
  node_count = 5
  node_size = "Standard_D16s_v3"
}

module "networking" {
  source = "../../modules/networking"
  
  environment = "prod"
  cluster_id = module.kubernetes.cluster_id
  vpc_cidr = "10.3.0.0/16"
}

module "storage" {
  source = "../../modules/storage"
  
  environment = "prod"
  cluster_id = module.kubernetes.cluster_id
  storage_class = "standard"
}

module "monitoring" {
  source = "../../modules/monitoring"
  
  environment = "prod"
  cluster_id = module.kubernetes.cluster_id
}

module "security" {
  source = "../../modules/security"
  
  environment = "prod"
  cluster_id = module.kubernetes.cluster_id
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