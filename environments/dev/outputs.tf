output "cluster_endpoint" {
  description = "The endpoint of the Kubernetes cluster"
  value       = module.kubernetes.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate of the Kubernetes cluster"
  value       = module.kubernetes.cluster_ca_certificate
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = module.kubernetes.cluster_name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = module.networking.subnet_ids
}

output "storage_class" {
  description = "The default storage class"
  value       = module.storage.storage_class
}

output "monitoring_endpoint" {
  description = "The endpoint of the monitoring stack"
  value       = module.monitoring.endpoint
}

output "argocd_server_url" {
  description = "The URL of the ArgoCD server"
  value       = helm_release.argocd.metadata[0].annotations["argocd.argoproj.io/server-url"]
}

output "istio_ingress_gateway" {
  description = "The Istio ingress gateway endpoint"
  value       = helm_release.istio.metadata[0].annotations["istio.io/ingress-gateway"]
} 