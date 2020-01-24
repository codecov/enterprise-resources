variable "gcloud_project" {
  description = "Google cloud project"
}

variable "region" {
  description = "Google cloud region"
  default = "us-east4"
}

variable "zone" {
  description = "Default Google cloud zone for zone-specific services"
  default = "us-east4a"
}

variable "codecov_version" {
  description = "Version of codecov enterprise to deploy"
  default = "4.4.7"
}

variable "cluster_name" {
  description = "Google Kubernetes Engine (GKE) cluster name"
  default = "default-codecov-cluster"
}

variable "web_node_pool_count" {
  description = "Number of nodes to create in the default node pool"
  default = "1"
}

variable "worker_node_pool_count" {
  description = "Number of nodes to create in the default node pool"
  default = "1"
}

variable "minio_node_pool_count" {
  description = "Number of nodes to create in the default node pool"
  default = "1"
}

variable "node_pool_machine_type" {
  description = "Machine type to use for the default node pool"
  default = "n1-standard-1"
}

variable "web_replicas" {
  description = "Number of web replicas to execute"
  default = "2"
}

variable "worker_replicas" {
  description = "Number of worker replicas to execute"
  default = "2"
}

variable "minio_replicas" {
  description = "Number of minio replicas to execute"
  default = "4"
}

variable "minio_bucket_name" {
  description = "Name of GCS bucket to create for minio"
}

variable "minio_bucket_location" {
  description = "Name of GCS bucket to create for minio"
  default = "US"
}

variable "minio_bucket_force_destroy" {
  description = "Force is required to destroy the cloud sql bucket when it contains data"
  default = "false"
}

variable "redis_instance_name" {
  description = "Name used for redis instance"
}

variable "redis_memory_size" {
  description = "Memory size in GB for redis instance"
  default = "5"
}

variable "postgres_instance_name" {
  description = "Name used for postgres instance"
}

variable "postgres_instance_type" {
  description = "Instance type used for postgres instance"
  default = "db-f1-micro"
}

variable "codecov_yml" {
  description = "Path to your codecov.yml"
  default = "codecov.yml"
}

variable "ingress_host" {
  description = "Hostname used for http(s) ingress"
}

variable "traefik_replicas" {
  description = "Number of traefik replicas to deploy"
  default = "2"
}

variable "enable_https" {
  description = "Enables https ingress.  Requires TLS cert and key"
  default = "0"
}

variable "tls_key" {
  description = "Path to private key to use for TLS"
  default = ""
}

variable "tls_cert" {
  description = "Path to certificate to use for TLS"
  default = ""
}
