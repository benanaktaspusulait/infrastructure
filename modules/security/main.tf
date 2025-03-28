# Create security namespace
resource "kubernetes_namespace" "security" {
  metadata {
    name = "security"
  }
}

# Create RBAC roles and bindings
resource "kubernetes_cluster_role" "admin" {
  metadata {
    name = "admin"
  }
  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
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
        pod_selector {}
      }
    }
    egress {
      to {
        pod_selector {}
      }
    }
  }
}

# Create Pod Security Policy
resource "kubernetes_pod_security_policy" "restricted" {
  metadata {
    name = "restricted"
  }
  spec {
    privileged                 = false
    allow_privilege_escalation = false
    required_drop_capabilities = ["ALL"]
    volumes                    = ["configMap", "emptyDir", "projected", "secret", "downwardAPI"]
    host_network               = false
    host_ipc                   = false
    host_pid                   = false
    run_as_user {
      rule = "MustRunAsNonRoot"
    }
    se_linux {
      rule = "RunAsAny"
    }
    supplemental_groups {
      rule = "MustRunAs"
      ranges {
        min = 1
        max = 65535
      }
    }
    fs_group {
      rule = "MustRunAs"
      ranges {
        min = 1
        max = 65535
      }
    }
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

output "pod_security_policy" {
  value = kubernetes_pod_security_policy.restricted.metadata[0].name
}

output "network_policies" {
  value = {
    default_deny  = kubernetes_network_policy.default_deny.metadata[0].name
    allow_internal = kubernetes_network_policy.allow_internal.metadata[0].name
  }
} 