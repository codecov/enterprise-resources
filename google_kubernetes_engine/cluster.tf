provider "google" {
  version = "~>2.5"
  project = "${var.gcloud_project}"
  region = "${var.region}"
  zone = "${var.zone}"
}

## Google Kubernetes Engine cluster and Node pool

## Cluster ##
# 
# It is recommended to avoid using the default node pool with terraform
# because some node pool changes will force recreation of the cluster.
# See the terraform docs for more info:
# https://www.terraform.io/docs/providers/google/r/container_cluster.html

data "google_container_engine_versions" "gke" { 
  location = "${var.region}"
}

resource "google_container_cluster" "primary" {
  name     = "${var.cluster_name}"
  location = "${var.region}"

  min_master_version = "${data.google_container_engine_versions.gke.latest_master_version}"

  ip_allocation_policy {
    use_ip_aliases = "true"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = "true"
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }

  lifecycle {
    ignore_changes = [
      "master_auth.0.client_certificate_config.0.issue_client_certificate",
      "network"
    ]
  }
}

resource "google_container_node_pool" "web" {
  name = "web"
  location = "${var.region}"
  cluster = "${google_container_cluster.primary.name}"
  node_count = "${var.web_node_pool_count}"

  node_config {
    labels {
      role = "web"
    }

    preemptible = true
    machine_type = "${var.node_pool_machine_type}"

    metadata {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "worker" {
  name = "worker"
  location = "${var.region}"
  cluster = "${google_container_cluster.primary.name}"
  node_count = "${var.worker_node_pool_count}"

  node_config {
    labels {
      role = "worker"
    }

    preemptible = true
    machine_type = "${var.node_pool_machine_type}"

    metadata {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "minio" {
  name = "minio"
  location = "${var.region}"
  cluster = "${google_container_cluster.primary.name}"
  node_count = "${var.minio_node_pool_count}"

  node_config {
    labels {
      role = "minio"
    }

    preemptible = true
    machine_type = "${var.node_pool_machine_type}"

    metadata {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# Grabs the goole client config in order to auth the kubernetes provider below
data "google_client_config" "current" {}

provider "kubernetes" {
  version = "~>1.6"
  load_config_file = "false"
  host = "https://${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
  token = "${data.google_client_config.current.access_token}"
}
