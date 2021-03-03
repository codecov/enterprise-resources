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
          role = google_container_node_pool.web.node_config[0].labels.role
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
            value = "postgres://${google_sql_user.codecov.name}:${google_sql_user.codecov.password}@127.0.0.1:5432/${google_sql_database.codecov.name}"
          }
          env {
            name  = "SERVICES__REDIS_URL"
            value = "redis://${google_redis_instance.codecov.host}:${google_redis_instance.codecov.port}"
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
        }

        # sidecar container use to allow web containers access to the
        # postgres database.
        volume {
          name = "postgres-service-account"
          secret {
            secret_name = kubernetes_secret.postgres-service-account.metadata[0].name
          }
        }
        container {
          name  = "cloudsql-proxy"
          image = "gcr.io/cloudsql-docker/gce-proxy:1.19.2-alpine"
          command = [
            "/cloud_sql_proxy",
            "-instances=${var.gcloud_project}:${var.region}:${google_sql_database_instance.codecov.name}=tcp:5432",
            "-credential_file=/creds/postgres-credentials.json",
          ]
          liveness_probe {
            exec {
              command = ["nc", "127.0.0.1", "5432"]
            }
          }
          readiness_probe {
            exec {
              command = ["nc", "127.0.0.1", "5432"]
            }
          }
          security_context {
            run_as_user                = "2"
            allow_privilege_escalation = "false"
          }
          volume_mount {
            name       = "postgres-service-account"
            mount_path = "/creds"
            read_only  = "true"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name = "api"
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

