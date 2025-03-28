variable "environment" {
  description = "Environment name (dev, test, preprod, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "enable_versioning" {
  description = "Enable versioning for the state bucket"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption for the state bucket"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Block all public access to the state bucket"
  type        = bool
  default     = true
} 