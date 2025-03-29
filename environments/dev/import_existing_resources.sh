#!/bin/bash

echo "\n⚠️ This script will DELETE and RECREATE conflicting Kubernetes resources managed by Terraform Helm and Kubernetes providers."
read -p "Type 'yes' to continue: " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "❌ Cancelled."
  exit 1
fi

# --- Cleanup for Helm releases ---
echo "\n🔥 Deleting Helm-managed ServiceAccounts with invalid ownership..."
kubectl delete serviceaccount istio-reader-service-account -n istio-system --ignore-not-found
kubectl delete serviceaccount argocd-application-controller -n argocd --ignore-not-found

# --- Deleting Helm-blocking resources ---
echo "\n🔥 Deleting conflicting Helm-managed namespaces..."
kubectl delete namespace istio-system --ignore-not-found
kubectl delete namespace argocd --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found

# --- Other K8s resources Terraform wants to recreate ---
echo "\n🧹 Deleting additional Kubernetes resources..."
kubectl delete networkpolicy default-deny -n security --ignore-not-found
kubectl delete networkpolicy allow-internal -n security --ignore-not-found
kubectl delete configmap app-config -n security --ignore-not-found
kubectl delete secret sensitive-data -n security --ignore-not-found
kubectl delete persistentvolume redis-pv --ignore-not-found
kubectl delete persistentvolume kafka-pv --ignore-not-found
kubectl delete persistentvolumeclaim postgresql-pvc -n default --ignore-not-found
kubectl delete persistentvolumeclaim redis-pvc -n default --ignore-not-found
# ❌ Skipping deletion of kafka PVC due to rate limiter error.

# ❌ Skipping deletion of clusterrole 'admin' due to aggregationRule validation error.

# --- Note: Terraform will recreate resources on apply ---
echo "\n✅ All applicable conflicting resources deleted. Run 'terraform apply' to recreate them."

