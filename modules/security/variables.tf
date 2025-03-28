variable "environment" {
  description = "Environment name (dev, test, preprod, prod)"
  type        = string
}

variable "postgresql_password" {
  description = "Password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Password for Redis"
  type        = string
  sensitive   = true
}

variable "kafka_password" {
  description = "Password for Kafka"
  type        = string
  sensitive   = true
}

variable "enable_network_policies" {
  description = "Enable network policies"
  type        = bool
  default     = true
}

variable "enable_pod_security_policy" {
  description = "Enable pod security policy"
  type        = bool
  default     = true
}

variable "enable_rbac" {
  description = "Enable RBAC"
  type        = bool
  default     = true
}

variable "admin_groups" {
  description = "List of admin groups"
  type        = list(string)
  default     = ["admin"]
}

variable "allowed_namespaces" {
  description = "List of allowed namespaces"
  type        = list(string)
  default     = ["default", "monitoring", "security"]
} 