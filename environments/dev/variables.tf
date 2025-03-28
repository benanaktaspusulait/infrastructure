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