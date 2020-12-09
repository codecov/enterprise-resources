resource "kubernetes_deployment" "worker" {
  metadata {
    name = "worker"
    annotations = var.resource_tags
  }
  spec {
    replicas = var.worker_replicas
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
          resources {
            limits {
              cpu    = "512m"
              memory = "2048M"
            }
            requests {
              cpu    = "256m"
              memory = "2048M"
            }
          }
          image_pull_policy = "Always"
          volume_mount {
            name       = "codecov-yml"
            read_only  = "true"
            mount_path = "/config"
          }
        }
      }
    }
    strategy {
      type = "RollingUpdate"
    }
  }
}

