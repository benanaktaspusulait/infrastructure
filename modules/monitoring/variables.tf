variable "environment" {
  description = "Environment name (dev, test, preprod, prod)"
  type        = string
}

variable "prometheus_storage_size" {
  description = "Storage size for Prometheus"
  type        = string
  default     = "50Gi"
}

variable "prometheus_retention_days" {
  description = "Number of days to retain Prometheus data"
  type        = number
  default     = 15
}

variable "grafana_storage_size" {
  description = "Storage size for Grafana"
  type        = string
  default     = "10Gi"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
  default     = "admin"  # Should be changed in production
}

variable "alertmanager_storage_size" {
  description = "Storage size for Alert Manager"
  type        = string
  default     = "10Gi"
}

variable "enable_prometheus" {
  description = "Enable Prometheus deployment"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Enable Grafana deployment"
  type        = bool
  default     = true
}

variable "enable_alertmanager" {
  description = "Enable Alert Manager deployment"
  type        = bool
  default     = true
}

variable "alertmanager_config" {
  description = "Alert Manager configuration"
  type        = map(string)
  default     = {}
} 