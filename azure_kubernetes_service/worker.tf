resource "kubernetes_deployment" "worker" {
  metadata {
    name        = "worker"
    annotations = var.resource_tags
  }
  spec {
    replicas = var.worker_resources["replicas"]
    selector {
      match_labels = {
        app = "worker"
      }
    }
    template {
      metadata {
        labels = {
          app = "worker"
        }
      }
      spec {
        volume {
          name = "codecov-yml"
          secret {
            secret_name = kubernetes_secret.codecov-yml.metadata[0].name
          }
        }
        volume {
          name = "scm-ca-cert"
          secret {
            secret_name = kubernetes_secret.scm-ca-cert.metadata[0].name
          }
        }
        container {
          name  = "workers"
          image = "codecov/enterprise-worker:v${var.codecov_version}"
          args  = ["worker", "--queue celery,uploads", "--concurrency 1"]
          env {
            name = "STATSD_HOST"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }
          env {
            name  = "STATSD_PORT"
            value = "8125"
          }
          env {
            name  = "DATABASE_USERNAME"
            value = local.postgres_username
          }
          env {
            name  = "DATABASE_PASSWORD"
            value = local.postgres_password
          }
          env {
            name  = "DATABASE_HOST"
            value = local.postgres_host
          }
          env {
            name  = "SERVICES__REDIS_URL"
            value = local.redis_url
          }
          env {
            name  = "SERVICES__MINIO__HOST"
            value = "minio"
          }
          env {
            name  = "SERVICES__MINIO__PORT"
            value = "9000"
          }
          env {
            name = "SERVICES__MINIO__ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio-access-key.metadata.0.name
                key  = "MINIO_ACCESS_KEY"
              }
            }
          }
          env {
            name = "SERVICES__MINIO__SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio-secret-key.metadata.0.name
                key  = "MINIO_SECRET_KEY"
              }
            }
          }
          env {
            name  = "SERVICES__MINIO__BUCKET"
            value = azurerm_storage_account.minio.name
          }
          resources {
            limits {
              cpu    = var.worker_resources["cpu_limit"]
              memory = var.worker_resources["memory_limit"]
            }
            requests {
              cpu    = var.worker_resources["cpu_request"]
              memory = var.worker_resources["memory_request"]
            }
          }
          image_pull_policy = "Always"
          volume_mount {
            name       = "codecov-yml"
            read_only  = "true"
            mount_path = "/config"
          }
          volume_mount {
            name       = "scm-ca-cert"
            read_only  = "true"
            mount_path = "/cert"
          }
        }
      }
    }
    strategy {
      type = "RollingUpdate"
    }
  }
}

