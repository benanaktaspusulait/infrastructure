#!/bin/bash

echo "⚠️ This will DELETE Helm-managed resources with mismatched metadata AND import existing Kubernetes resources into Terraform."
read -p "Type 'yes' to continue: " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "❌ Cancelled."
  exit 1
fi

echo "🔍 Deleting Helm-blocking ServiceAccounts..."
kubectl delete serviceaccount istio-reader-service-account -n istio-system --ignore-not-found
kubectl delete serviceaccount argocd-application-controller -n argocd --ignore-not-found

echo "🧼 Deleting conflicting Helm-managed resources (leave Helm releases for re-deploy)..."
kubectl delete namespace istio-system --ignore-not-found
kubectl delete namespace argocd --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found

echo "🧹 Deleting remaining conflicting Kubernetes resources..."
kubectl delete service internal-service -n default --ignore-not-found
kubectl delete namespace security --ignore-not-found
kubectl delete clusterrole admin --ignore-not-found
kubectl delete networkpolicy default-deny -n security --ignore-not-found
kubectl delete networkpolicy allow-internal -n security --ignore-not-found
kubectl delete storageclass standard --ignore-not-found
kubectl delete storageclass fast --ignore-not-found

echo "🔄 Importing existing resources into Terraform state..."

# Helm (note: these may still fail if you plan to recreate them, you can skip importing and re-deploy via TF)
# Commenting out these imports for now; better to uninstall via Helm if possible, or delete their namespaces

# terraform import helm_release.istio istio
# terraform import helm_release.argocd argocd
# terraform import module.monitoring.helm_release.prometheus_operator prometheus-operator

# Kubernetes Namespaces
terraform import 'kubernetes_namespace.namespaces["stok"]' stok
terraform import 'kubernetes_namespace.namespaces["gateway"]' gateway
terraform import 'kubernetes_namespace.namespaces["fys"]' fys
terraform import 'kubernetes_namespace.namespaces["frontend"]' frontend
terraform import 'kubernetes_namespace.namespaces["config"]' config
terraform import module.security.kubernetes_namespace.security security

# Kubernetes Service
terraform import module.networking.kubernetes_service.internal default/internal-service

# Storage Classes
terraform import kubernetes_storage_class.local_storage local-storage
terraform import module.storage.kubernetes_storage_class.standard standard
terraform import module.storage.kubernetes_storage_class.fast fast

# RBAC
terraform import module.security.kubernetes_cluster_role.admin admin

# Network Policies
terraform import module.security.kubernetes_network_policy.default_deny security/default-deny
terraform import module.security.kubernetes_network_policy.allow_internal security/allow-internal

echo "✅ Script complete. Rerun 'terraform plan' and 'terraform apply' to confirm everything works."
