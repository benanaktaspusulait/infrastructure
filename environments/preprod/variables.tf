variable "environment" {
  description = "Environment name (dev, test, preprod, prod)"
  type        = string
  default     = "preprod"
}

variable "postgresql_password" {
  description = "Password for PostgreSQL database"
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