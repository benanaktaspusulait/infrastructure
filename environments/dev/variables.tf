variable "environment" {
  description = "Environment name (dev, test, preprod, prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "dev-cluster"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "node_size" {
  description = "Size of worker nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "storage_class" {
  description = "Default storage class for persistent volumes"
  type        = string
  default     = "standard"
}

variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "enable_security" {
  description = "Enable security features"
  type        = bool
  default     = true
}

variable "storage_path" {
  description = "Base path for persistent storage"
  type        = string
  default     = "/data"
}

variable "storage_sizes" {
  description = "Storage sizes for different services"
  type = map(string)
  default = {
    kafka-data = "20Gi"
    redis-data = "5Gi"
    postgresql-data = "10Gi"
  }
}

# Security module variables
variable "postgresql_password" {
  description = "Password for PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "kafka_password" {
  description = "Password for Kafka"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Password for Redis"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Secret key for JWT token generation"
  type        = string
  sensitive   = true
}

variable "encryption_key" {
  description = "Key for data encryption"
  type        = string
  sensitive   = true
}

# Additional security variables
variable "postgresql_user" {
  description = "Username for PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "kafka_user" {
  description = "Username for Kafka"
  type        = string
  sensitive   = true
}

variable "redis_user" {
  description = "Username for Redis"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Password for admin user"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API key for external service integration"
  type        = string
  sensitive   = true
}

variable "ssl_certificate" {
  description = "SSL certificate for HTTPS"
  type        = string
  sensitive   = true
}

variable "ssl_private_key" {
  description = "SSL private key for HTTPS"
  type        = string
  sensitive   = true
}

variable "ldap_password" {
  description = "Password for LDAP authentication"
  type        = string
  sensitive   = true
}

variable "vault_token" {
  description = "Token for HashiCorp Vault"
  type        = string
  sensitive   = true
}

variable "backup_encryption_key" {
  description = "Key for encrypting backups"
  type        = string
  sensitive   = true
}

variable "monitoring_password" {
  description = "Password for monitoring stack"
  type        = string
  sensitive   = true
}

variable "alertmanager_password" {
  description = "Password for Alertmanager"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

# Network Policy Variables
variable "network_policy_enabled" {
  description = "Enable network policies"
  type        = bool
  default     = true
}

variable "network_policy_default_deny" {
  description = "Enable default deny network policy"
  type        = bool
  default     = true
}

variable "network_policy_allow_internal" {
  description = "Allow internal network communication"
  type        = bool
  default     = true
}

# Security Policy Variables
variable "pod_security_policy_enabled" {
  description = "Enable pod security policies"
  type        = bool
  default     = true
}

variable "pod_security_context_enabled" {
  description = "Enable pod security context"
  type        = bool
  default     = true
}

variable "container_security_context_enabled" {
  description = "Enable container security context"
  type        = bool
  default     = true
}

# Kubernetes Configuration Variables
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.0"
}

variable "node_pools" {
  description = "Node pool configurations"
  type = list(object({
    name              = string
    machine_type      = string
    min_nodes         = number
    max_nodes         = number
    initial_node_count = number
  }))
  default = [
    {
      name              = "default"
      machine_type      = "e2-medium"
      min_nodes         = 1
      max_nodes         = 3
      initial_node_count = 1
    }
  ]
} 