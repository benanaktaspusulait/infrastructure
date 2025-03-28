variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "node_pools" {
  description = "List of node pools to create"
  type = list(object({
    name         = string
    node_count   = number
    machine_type = string
    disk_size_gb = number
    disk_type    = string
  }))
  default = [
    {
      name         = "default-pool"
      node_count   = 3
      machine_type = "Standard_D4s_v3"
      disk_size_gb = 100
      disk_type    = "StandardSSD_LRS"
    }
  ]
}

variable "network" {
  description = "Network name for the cluster"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.28.0"
}

variable "enable_private_nodes" {
  description = "Enable private nodes"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master nodes"
  type        = string
  default     = "172.16.0.0/28"
}

variable "maintenance_start_time" {
  description = "Start time for maintenance window"
  type        = string
  default     = "2024-01-01T00:00:00Z"
}

variable "maintenance_end_time" {
  description = "End time for maintenance window"
  type        = string
  default     = "2024-01-01T04:00:00Z"
}

variable "maintenance_recurrence" {
  description = "Recurrence pattern for maintenance window"
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=SA,SU"
} 