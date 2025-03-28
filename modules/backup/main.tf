# Create backup namespace
resource "kubernetes_namespace" "backup" {
  metadata {
    name = "backup"
  }
}

# Deploy Velero for backup and restore
resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = "5.1.3"
  namespace  = kubernetes_namespace.backup.metadata[0].name
  create_namespace = true

  values = [
    file("${path.module}/values/velero-values.yaml")
  ]

  set {
    name  = "configuration.provider"
    value = var.backup_provider
  }

  set {
    name  = "configuration.backupStorageLocation.name"
    value = var.backup_storage_location
  }

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = var.backup_bucket
  }

  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = var.backup_region
  }

  set {
    name  = "configuration.backupStorageLocation.config.s3ForcePathStyle"
    value = "true"
  }

  set {
    name  = "configuration.backupStorageLocation.config.s3Url"
    value = var.backup_s3_url
  }

  set {
    name  = "configuration.volumeSnapshotLocation.name"
    value = var.volume_snapshot_location
  }

  set {
    name  = "configuration.volumeSnapshotLocation.config.region"
    value = var.backup_region
  }
}

# Create backup schedules
resource "kubernetes_cron_job" "daily_backup" {
  metadata {
    name      = "daily-backup"
    namespace = kubernetes_namespace.backup.metadata[0].name
  }
  spec {
    schedule = "0 1 * * *"  # Run at 1 AM daily
    job_template {
      spec {
        template {
          spec {
            containers {
              name  = "backup"
              image = "velero/velero:v1.11.3"
              args  = ["backup", "create", "daily-backup", "--include-namespaces=default,monitoring,security"]
            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}

# Create disaster recovery procedures
resource "kubernetes_config_map" "dr_procedures" {
  metadata {
    name      = "dr-procedures"
    namespace = kubernetes_namespace.backup.metadata[0].name
  }
  data = {
    "dr-procedures.md" = <<-EOT
      # Disaster Recovery Procedures

      ## 1. Cluster Failure
      1. Identify the failed cluster
      2. Restore from the latest backup:
         ```bash
         velero restore create --from-backup daily-backup
         ```
      3. Verify cluster state
      4. Resume operations

      ## 2. Data Corruption
      1. Identify affected resources
      2. Restore specific resources:
         ```bash
         velero restore create --from-backup daily-backup --include-resources deployment,service
         ```
      3. Verify data integrity
      4. Resume operations

      ## 3. Network Issues
      1. Check network connectivity
      2. Verify DNS resolution
      3. Test service endpoints
      4. Restore network configurations if needed

      ## 4. Security Breach
      1. Isolate affected systems
      2. Revoke compromised credentials
      3. Restore from clean backup
      4. Update security policies
    EOT
  }
}

# Outputs
output "backup_namespace" {
  value = kubernetes_namespace.backup.metadata[0].name
}

output "velero_status" {
  value = helm_release.velero.status
} 