variable "environment" {
  description = "Environment name (dev, test, preprod, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "Region where resources will be created"
  type        = string
  default     = "us-central1"
}

variable "enable_private_subnets" {
  description = "Enable private subnets"
  type        = bool
  default     = true
}

variable "enable_public_subnets" {
  description = "Enable public subnets"
  type        = bool
  default     = true
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 3
}

variable "enable_nat" {
  description = "Enable Cloud NAT"
  type        = bool
  default     = true
} 