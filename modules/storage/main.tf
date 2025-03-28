# Create Storage Classes
resource "kubernetes_storage_class" "standard" {
  metadata {
    name = "standard"
  }
  storage_provisioner = "kubernetes.io/standard"
  reclaim_policy     = "Retain"
}

resource "kubernetes_storage_class" "fast" {
  metadata {
    name = "fast"
  }
  storage_provisioner = "kubernetes.io/fast"
  reclaim_policy     = "Retain"
}

# Create Persistent Volumes
resource "kubernetes_persistent_volume" "postgresql" {
  metadata {
    name = "postgresql-pv"
  }
  spec {
    capacity = {
      storage = "100Gi"
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.standard.metadata[0].name
    persistent_volume_source {
      host_path {
        path = "/data/postgresql"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "redis" {
  metadata {
    name = "redis-pv"
  }
  spec {
    capacity = {
      storage = "50Gi"
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.fast.metadata[0].name
    persistent_volume_source {
      host_path {
        path = "/data/redis"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "kafka" {
  metadata {
    name = "kafka-pv"
  }
  spec {
    capacity = {
      storage = "200Gi"
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.fast.metadata[0].name
    persistent_volume_source {
      host_path {
        path = "/data/kafka"
        type = "DirectoryOrCreate"
      }
    }
  }
}

# Create Persistent Volume Claims
resource "kubernetes_persistent_volume_claim" "postgresql" {
  metadata {
    name = "postgresql-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.standard.metadata[0].name
    resources {
      requests = {
        storage = "100Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "redis" {
  metadata {
    name = "redis-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.fast.metadata[0].name
    resources {
      requests = {
        storage = "50Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "kafka" {
  metadata {
    name = "kafka-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.fast.metadata[0].name
    resources {
      requests = {
        storage = "200Gi"
      }
    }
  }
}

# Outputs
output "storage_classes" {
  value = {
    standard = kubernetes_storage_class.standard.metadata[0].name
    fast     = kubernetes_storage_class.fast.metadata[0].name
  }
}

output "persistent_volumes" {
  value = {
    postgresql = kubernetes_persistent_volume.postgresql.metadata[0].name
    redis      = kubernetes_persistent_volume.redis.metadata[0].name
    kafka      = kubernetes_persistent_volume.kafka.metadata[0].name
  }
}

output "persistent_volume_claims" {
  value = {
    postgresql = kubernetes_persistent_volume_claim.postgresql.metadata[0].name
    redis      = kubernetes_persistent_volume_claim.redis.metadata[0].name
    kafka      = kubernetes_persistent_volume_claim.kafka.metadata[0].name
  }
} 