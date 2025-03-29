#!/bin/bash

echo "⚠️ Deleting existing Kubernetes resources that conflict with Terraform..."
echo "⏳ This may take a while depending on your cluster size."

# --- Persistent Volumes ---
kubectl delete persistentvolume kafka-data --ignore-not-found
kubectl delete persistentvolume postgresql-data --ignore-not-found
kubectl delete persistentvolume redis-data --ignore-not-found

# --- Storage Classes ---
kubectl delete storageclass local-storage --ignore-not-found
kubectl delete storageclass standard --ignore-not-found
kubectl delete storageclass fast --ignore-not-found

# --- Cluster Roles ---
kubectl delete clusterrole admin --ignore-not-found

# --- Namespaces ---
kubectl delete namespace argocd --ignore-not-found
kubectl delete namespace config --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found
kubectl delete namespace stok --ignore-not-found
kubectl delete namespace gateway --ignore-not-found
kubectl delete namespace frontend --ignore-not-found
kubectl delete namespace fys --ignore-not-found
kubectl delete namespace security --ignore-not-found

# --- Network Policies ---
kubectl delete networkpolicy default-deny -n default --ignore-not-found
kubectl delete networkpolicy allow-internal -n default --ignore-not-found
kubectl delete networkpolicy default-deny -n security --ignore-not-found
kubectl delete networkpolicy allow-internal -n security --ignore-not-found

# --- Services ---
kubectl delete service internal-service -n default --ignore-not-found

# --- Prometheus CRDs or Custom Resources (example) ---
kubectl delete servicemonitor --all --ignore-not-found
# Helm Release (Istio)
helm uninstall istio -n istio-system || helm uninstall istio

# Namespace
kubectl delete namespace security --ignore-not-found

# Cluster Role Binding
kubectl delete clusterrolebinding admin --ignore-not-found

# Persistent Volumes
kubectl delete pv postgresql-pv --ignore-not-found
kubectl delete pv redis-pv --ignore-not-found
kubectl delete pv kafka-pv --ignore-not-found

# Persistent Volume Claims
kubectl delete pvc postgresql-pvc -n default --ignore-not-found
kubectl delete pvc redis-pvc -n default --ignore-not-found
kubectl delete pvc kafka-pvc -n default --ignore-not-found


kubectl delete pv postgresql-pv redis-pv kafka-pv
kubectl delete pvc postgresql-pvc redis-pvc kafka-pvc

echo "✅ Deletion complete. You can now safely run 'terraform apply'."
