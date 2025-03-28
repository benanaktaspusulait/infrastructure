# Create compliance namespace
resource "kubernetes_namespace" "compliance" {
  metadata {
    name = "compliance"
  }
}

# Deploy Falco for runtime security
resource "helm_release" "falco" {
  name       = "falco"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  version    = "2.0.0"
  namespace  = kubernetes_namespace.compliance.metadata[0].name
  create_namespace = true

  values = [
    file("${path.module}/values/falco-values.yaml")
  ]
}

# Deploy OPA Gatekeeper for policy enforcement
resource "helm_release" "gatekeeper" {
  name       = "gatekeeper"
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  version    = "3.13.0"
  namespace  = kubernetes_namespace.compliance.metadata[0].name
  create_namespace = true

  values = [
    file("${path.module}/values/gatekeeper-values.yaml")
  ]
}

# Deploy Trivy for vulnerability scanning
resource "helm_release" "trivy" {
  name       = "trivy"
  repository = "https://aquasecurity.github.io/helm-charts"
  chart      = "trivy-operator"
  version    = "0.18.0"
  namespace  = kubernetes_namespace.compliance.metadata[0].name
  create_namespace = true

  values = [
    file("${path.module}/values/trivy-values.yaml")
  ]
}

# Create compliance policies
resource "kubernetes_manifest" "pod_security_policy" {
  manifest = {
    apiVersion = "constraints.gatekeeper.sh/v1beta1"
    kind       = "K8sRequiredLabels"
    metadata = {
      name = "require-pod-labels"
    }
    spec = {
      match = {
        kinds = [
          {
            apiGroups = [""]
            kinds     = ["Pod"]
          }
        ]
      }
      parameters = {
        labels = ["app.kubernetes.io/name", "app.kubernetes.io/instance"]
      }
    }
  }
}

resource "kubernetes_manifest" "resource_limits" {
  manifest = {
    apiVersion = "constraints.gatekeeper.sh/v1beta1"
    kind       = "K8sResourceLimits"
    metadata = {
      name = "require-resource-limits"
    }
    spec = {
      match = {
        kinds = [
          {
            apiGroups = [""]
            kinds     = ["Pod"]
          }
        ]
      }
      parameters = {
        cpu    = "500m"
        memory = "512Mi"
      }
    }
  }
}

# Create compliance reports
resource "kubernetes_cron_job" "compliance_report" {
  metadata {
    name      = "compliance-report"
    namespace = kubernetes_namespace.compliance.metadata[0].name
  }
  spec {
    schedule = "0 0 * * *"  # Daily at midnight
    job_template {
      spec {
        template {
          spec {
            containers {
              name  = "report"
              image = "aquasec/trivy:latest"
              args  = ["image", "--severity", "HIGH,CRITICAL", "--format", "json", "--output", "/reports/vulnerabilities.json"]
              volume_mounts {
                name       = "reports"
                mount_path = "/reports"
              }
            }
            volumes {
              name = "reports"
              persistent_volume_claim {
                claim_name = "compliance-reports-pvc"
              }
            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}

# Outputs
output "compliance_namespace" {
  value = kubernetes_namespace.compliance.metadata[0].name
}

output "falco_status" {
  value = helm_release.falco.status
}

output "gatekeeper_status" {
  value = helm_release.gatekeeper.status
}

output "trivy_status" {
  value = helm_release.trivy.status
} 