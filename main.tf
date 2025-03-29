resource "kubernetes_namespace" "namespaces" {
  // ...existing code...
  lifecycle {
    ignore_changes = [metadata]
  }
}
