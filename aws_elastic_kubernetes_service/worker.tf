resource "kubernetes_deployment" "worker" {
  metadata {
    name = "worker"
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
        node_selector = {
          "kubernetes.io/role" = "worker"
        }
        service_account_name = kubernetes_service_account.codecov.metadata[0].name
        volume {
          name = kubernetes_service_account.codecov.default_secret_name
          secret {
            secret_name = kubernetes_service_account.codecov.default_secret_name
          }
        }
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
          image = "codecov/enterprise-worker:${var.codecov_version}"
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
            name = "STATSD_PORT"
            value = "8125"
          }
          env {
            name  = "SERVICES__DATABASE_URL"
            value = local.postgres_url
          }
          env {
            name  = "SERVICES__REDIS_URL"
            value = local.redis_url
          }
          env {
            name  = "SERVICES__MINIO__HOST"
            value = "s3.amazonaws.com"
          }
          env {
            name  = "SERVICES__MINIO__BUCKET"
            value = aws_s3_bucket.minio.id
          }
          env {
            name  = "SERVICES__MINIO__IAM_AUTH"
            value = "true"
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

          # when using terraform, you must explicitly mount the service account secret volume
          # https://github.com/kubernetes/kubernetes/issues/27973
          # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38
          volume_mount {
            name       = kubernetes_service_account.codecov.default_secret_name
            read_only  = "true"
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }
        }
      }
    }
    strategy {
      type = "RollingUpdate"
    }
  }
}
