variable "environment" {
  description = "Environment name (dev, test, preprod, prod)"
  type        = string
}

variable "postgresql_storage_size" {
  description = "Storage size for PostgreSQL"
  type        = string
  default     = "100Gi"
}

variable "redis_storage_size" {
  description = "Storage size for Redis"
  type        = string
  default     = "50Gi"
}

variable "kafka_storage_size" {
  description = "Storage size for Kafka"
  type        = string
  default     = "200Gi"
}

variable "storage_reclaim_policy" {
  description = "Reclaim policy for storage classes"
  type        = string
  default     = "Retain"
}

variable "enable_backup" {
  description = "Enable backup for persistent volumes"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
} 