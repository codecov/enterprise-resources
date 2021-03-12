resource "kubernetes_deployment" "api" {
  metadata {
    name = "api"
    annotations = var.resource_tags
  }
  spec {
    replicas = var.api_resources["replicas"]
    selector {
      match_labels = {
        app = "api"
      }
    }
    template {
      metadata {
        labels = {
          app = "api"
        }
      }
      spec {
        node_selector = {
          #Run the api pods on the web nodes as they are lightweight. This can be split out if needed.
          "kubernetes.io/role" = "web"
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
          name  = "api"
          image = "codecov/enterprise-api:${var.codecov_version}"
          port {
            container_port = 8000
          }
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
          resources {
            limits {
              cpu    = var.api_resources["cpu_limit"]
              memory = var.api_resources["memory_limit"]
            }
            requests {
              cpu    = var.api_resources["cpu_request"]
              memory = var.api_resources["memory_request"]
            }
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = "8000"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
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
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name = "api"
    annotations = var.resource_tags
  }
  spec {
    port {
      protocol    = "TCP"
      port        = "8000"
      target_port = "8000"
    }
    selector = {
      app = "api"
    }
  }
}
