terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"  # or your local context name
}

# Create security namespace
resource "kubernetes_namespace" "security" {
  metadata {
    name = "security"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  timeouts {
    delete = "10m"
  }
  depends_on = []
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      metadata[0].name
    ]
  }
}

# Create admin cluster role
resource "kubernetes_cluster_role" "admin" {
  metadata {
    name = "admin"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
  aggregation_rule {
    cluster_role_selectors {
      match_labels = {
        "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      }
    }
  }
  depends_on = []
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      rule,
      metadata[0].name,
      aggregation_rule
    ]
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      role_ref,
      subject,
      metadata[0].name
    ]
  }
}

# Create Network Policies
resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny"
    namespace = "default"
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
  depends_on = []
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      spec[0].pod_selector,
      spec[0].policy_types,
      metadata[0].name,
      metadata[0].namespace
    ]
  }
}

resource "kubernetes_network_policy" "allow_internal" {
  metadata {
    name      = "allow-internal"
    namespace = "default"
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
    ingress {
      from {
        namespace_selector {}
      }
    }
    egress {
      to {
        namespace_selector {}
      }
    }
  }
  depends_on = []
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      spec[0].pod_selector,
      spec[0].policy_types,
      spec[0].ingress,
      spec[0].egress,
      metadata[0].name,
      metadata[0].namespace
    ]
  }
}

# Create Secret for sensitive data
resource "kubernetes_secret" "sensitive_data" {
  metadata {
    name      = "sensitive-data"
    namespace = kubernetes_namespace.security.metadata[0].name
  }
  data = {
    "postgresql-password" = base64encode(var.postgresql_password)
    "redis-password"      = base64encode(var.redis_password)
    "kafka-password"      = base64encode(var.kafka_password)
  }
}

# Create ConfigMap for non-sensitive configuration
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.security.metadata[0].name
  }
  data = {
    "application.properties" = <<-EOT
      spring.datasource.url=jdbc:postgresql://postgresql:5432/appdb
      spring.redis.host=redis
      spring.redis.port=6379
      kafka.bootstrap-servers=kafka:9092
    EOT
  }
}

# Outputs
output "security_namespace" {
  value = kubernetes_namespace.security.metadata[0].name
}

output "network_policies" {
  value = {
    default_deny  = kubernetes_network_policy.default_deny.metadata[0].name
    allow_internal = kubernetes_network_policy.allow_internal.metadata[0].name
  }
} 
