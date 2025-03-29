terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"
  experiments {
    manifest_resource = true
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "docker-desktop"
  }
}

# Install Prometheus Operator using Helm
resource "helm_release" "prometheus_operator" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "45.7.1"
  namespace  = "monitoring"
  create_namespace = true
  force_update = true
  cleanup_on_fail = true
  replace = true
  atomic = true
  wait = true
  timeout = 600

  values = [
    file("${path.module}/values/prometheus-values.yaml")
  ]

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.prometheus_storage_size
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "${var.prometheus_retention_days}d"
  }

  set {
    name  = "grafana.persistence.size"
    value = var.grafana_storage_size
  }
}

# Create ServiceMonitor for monitoring
resource "kubernetes_manifest" "service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "monitoring"
      namespace = "monitoring"
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "prometheus"
          "app.kubernetes.io/instance" = "kube-prometheus-stack"
        }
      }
      endpoints = [
        {
          port = "http"
          interval = "15s"
          path = "/metrics"
          scheme = "http"
          tlsConfig = {
            insecureSkipVerify = true
          }
        }
      ]
    }
  }
  depends_on = [helm_release.prometheus_operator]
  timeouts {
    create = "5m"
  }
}

# Outputs
output "prometheus_endpoint" {
  value = "http://prometheus-server.monitoring.svc.cluster.local:9090"
}

output "grafana_endpoint" {
  value = "http://grafana.monitoring.svc.cluster.local:3000"
}

output "alertmanager_endpoint" {
  value = "http://alertmanager.monitoring.svc.cluster.local:9093"
}