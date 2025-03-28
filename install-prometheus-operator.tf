provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" // Ensure this path is correct
    config_context = "your-context-name" // Replace with your kubeconfig context name
  }
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  namespace  = "monitoring"
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "51.2.0" // Use a stable version

  create_namespace = true
}
