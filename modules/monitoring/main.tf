# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Deploy Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.21.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = true

  values = [
    file("${path.module}/values/prometheus-values.yaml")
  ]

  set {
    name  = "server.persistentVolume.size"
    value = var.prometheus_storage_size
  }

  set {
    name  = "server.retention"
    value = var.prometheus_retention_days
  }
}

# Deploy Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.57.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = true

  values = [
    file("${path.module}/values/grafana-values.yaml")
  ]

  set {
    name  = "persistence.size"
    value = var.grafana_storage_size
  }

  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
    type  = "string"
  }
}

# Deploy Alert Manager
resource "helm_release" "alertmanager" {
  name       = "alertmanager"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "alertmanager"
  version    = "0.27.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = true

  values = [
    file("${path.module}/values/alertmanager-values.yaml")
  ]

  set {
    name  = "persistentVolume.size"
    value = var.alertmanager_storage_size
  }
}

# Create Service Monitor for applications
resource "kubernetes_manifest" "service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "application-metrics"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
    }
    spec = {
      selector = {
        matchLabels = {
          app = "monitored"
        }
      }
      endpoints = [
        {
          port = "metrics"
          interval = "15s"
        }
      ]
    }
  }
}

# Outputs
output "prometheus_endpoint" {
  value = "http://${helm_release.prometheus.name}-server.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:9090"
}

output "grafana_endpoint" {
  value = "http://${helm_release.grafana.name}.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:3000"
}

output "alertmanager_endpoint" {
  value = "http://${helm_release.alertmanager.name}.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local:9093"
} 