variable "environment" {
  description = "Environment name (dev, test, preprod, prod)"
  type        = string
}

variable "backup_provider" {
  description = "Backup provider (aws, azure, gcp)"
  type        = string
  default     = "aws"
}

variable "backup_storage_location" {
  description = "Name of the backup storage location"
  type        = string
  default     = "default"
}

variable "backup_bucket" {
  description = "Name of the backup bucket"
  type        = string
}

variable "backup_region" {
  description = "Region for backup storage"
  type        = string
}

variable "backup_s3_url" {
  description = "S3 URL for backup storage"
  type        = string
}

variable "volume_snapshot_location" {
  description = "Name of the volume snapshot location"
  type        = string
  default     = "default"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "backup_schedule" {
  description = "Cron schedule for backups"
  type        = string
  default     = "0 1 * * *"  # Daily at 1 AM
}

variable "include_namespaces" {
  description = "Namespaces to include in backup"
  type        = list(string)
  default     = ["default", "monitoring", "security"]
}

variable "exclude_namespaces" {
  description = "Namespaces to exclude from backup"
  type        = list(string)
  default     = ["kube-system", "backup"]
} 