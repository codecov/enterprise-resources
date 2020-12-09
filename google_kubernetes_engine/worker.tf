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
          role = google_container_node_pool.worker.node_config[0].labels.role
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
            value = "postgres://${google_sql_user.codecov.name}:${google_sql_user.codecov.password}@127.0.0.1:5432/${google_sql_database.codecov.name}"
          }
          env {
            name  = "SERVICES__REDIS_URL"
            value = "redis://${google_redis_instance.codecov.host}:${google_redis_instance.codecov.port}"
          }
          env {
            name  = "SERVICES__MINIO__HOST"
            value = "storage.googleapis.com"
          }
          env {
            name  = "SERVICES__MINIO__VERIFY_SSL"
            value = "true"
          }
          env {
            name  = "SERVICES__MINIO__BUCKET"
            value = google_storage_bucket.minio.name
          }
          env {
            name  = "SERVICES__MINIO__REGION"
            value = var.region
          }
          env {
            name = "SERVICES__MINIO__ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio-access-key.metadata[0].name
                key  = "MINIO_ACCESS_KEY"
              }
            }
          }
          env {
            name = "SERVICES__MINIO__SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio-secret-key.metadata[0].name
                key  = "MINIO_SECRET_KEY"
              }
            }
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

        # sidecar container use to allow worker containers access to the
        # postgres database.
        volume {
          name = "postgres-service-account"
          secret {
            secret_name = kubernetes_secret.postgres-service-account.metadata[0].name
          }
        }
        container {
          name  = "cloudsql-proxy"
          image = "gcr.io/cloudsql-docker/gce-proxy:1.11"
          command = [
            "/cloud_sql_proxy",
            "-instances=${var.gcloud_project}:${var.region}:${google_sql_database_instance.codecov.name}=tcp:5432",
            "-credential_file=/creds/postgres-credentials.json",
          ]
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
    strategy {
      type = "RollingUpdate"
    }
  }
}

