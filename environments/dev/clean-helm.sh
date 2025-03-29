#!/bin/bash

echo "🚨 WARNING: This will delete Helm releases and Kubernetes resources Terraform is complaining about."
read -p "Type 'yes' to continue: " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "❌ Cancelled."
  exit 1
fi

echo "🔥 Uninstalling Helm releases..."
helm uninstall istio -n istio-system 2>/dev/null || true
helm uninstall argocd -n argocd 2>/dev/null || true
helm uninstall prometheus-operator -n monitoring 2>/dev/null || true

echo "🧼 Deleting namespaces..."
for ns in gateway fys frontend stok config security; do
  kubectl delete namespace $ns --ignore-not-found
done

echo "🧼 Deleting storage classes..."
for sc in local-storage standard fast; do
  kubectl delete storageclass $sc --ignore-not-found
done

echo "🧼 Deleting service..."
kubectl delete service internal-service -n default --ignore-not-found

echo "🧼 Deleting cluster roles..."
kubectl delete clusterrole admin --ignore-not-found

echo "🧼 Deleting network policies..."
kubectl delete networkpolicy default-deny -n security --ignore-not-found
kubectl delete networkpolicy allow-internal -n security --ignore-not-found

echo "🧼 Cleaning Terraform state for helm_release and k8s resources..."
for res in $(terraform state list | grep -E 'helm_release|kubernetes_namespace|kubernetes_storage_class|kubernetes_service|kubernetes_cluster_role|kubernetes_network_policy'); do
  terraform state rm "$res"
done

echo "✅ Cleanup complete. You can now run 'terraform apply' safely."
