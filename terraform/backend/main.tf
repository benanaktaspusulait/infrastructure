terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create namespaces
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(["gateway", "config", "fys", "stok", "frontend", "argocd", "monitoring", "security"])

  metadata {
    name = each.value
    labels = {
      name = each.value
    }
  }
}

# Create storage classes
resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }
  storage_provisioner = "k8s.io/minikube-hostpath"
  reclaim_policy     = "Retain"
}

# Create persistent volumes
resource "kubernetes_persistent_volume" "local_pvs" {
  for_each = {
    kafka-data = "200Gi"
    redis-data = "50Gi"
    postgresql-data = "100Gi"
  }

  metadata {
    name = each.key
  }
  spec {
    capacity = {
      storage = each.value
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.local_storage.metadata[0].name
    persistent_volume_source {
      host_path {
        path = "/data/${each.key}"
        type = "DirectoryOrCreate"
      }
    }
  }
}

# Create S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "your-terraform-state-bucket"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
} 