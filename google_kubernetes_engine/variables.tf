variable "gcloud_project" {
  description = "Google cloud project"
}

variable "region" {
  description = "Google cloud region"
  default     = "us-east4"
}

variable "zone" {
  description = "Default Google cloud zone for zone-specific services"
  default     = "us-east4a"
}

variable "codecov_version" {
  description = "Version of codecov enterprise to deploy"
  default     = "4.5.5"
}

variable "cluster_name" {
  description = "Google Kubernetes Engine (GKE) cluster name"
  default     = "default-codecov-cluster"
}

variable "web_node_pool_count" {
  description = "Number of nodes to create in the default node pool"
  default     = "1"
}

variable "worker_node_pool_count" {
  description = "Number of nodes to create in the default node pool"
  default     = "1"
}

variable "node_pool_machine_type" {
  description = "Machine type to use for the default node pool"
  default     = "n1-standard-1"
}

variable "web_resources" {
  type = map
  default = {
    replicas       = 2
    cpu_limit      = "256m"
    memory_limit   = "512M"
    cpu_request    = "32m"
    memory_request = "64M"
  }
}

variable "worker_resources" {
  type = map
  default = {
    replicas       = 3
    cpu_limit      = "512m"
    memory_limit   = "1024M"
    cpu_request    = "256m"
    memory_request = "512M"
  }
}

variable "traefik_resources" {
  type = map
  default = {
    replicas       = 2
    cpu_limit      = "256m"
    memory_limit   = "512M"
    cpu_request    = "32m"
    memory_request = "64M"
  }
}

variable "enable_traefik" {
  description = "Whether or not to include Traefik ingress"
  default     = "1"
}

variable "minio_bucket_name" {
  description = "Name of GCS bucket to create for minio"
}

variable "minio_bucket_location" {
  description = "Location of GCS bucket"
  default     = "US"
}

variable "minio_bucket_force_destroy" {
  description = "Force is required to destroy the cloud sql bucket when it contains data"
  default     = "false"
}

variable "redis_memory_size" {
  description = "Memory size in GB for redis instance"
  default     = "5"
}

variable "postgres_instance_type" {
  description = "Instance type used for postgres instance"
  default     = "db-f1-micro"
}

variable "codecov_yml" {
  description = "Path to your codecov.yml"
  default     = "codecov.yml"
}

variable "ingress_host" {
  description = "Hostname used for http(s) ingress"
}

variable "traefik_replicas" {
  description = "Number of traefik replicas to deploy"
  default     = "2"
}

variable "enable_https" {
  description = "Enables https ingress.  Requires TLS cert and key"
  default     = "0"
}

variable "tls_key" {
  description = "Path to private key to use for TLS"
  default     = ""
}

variable "tls_cert" {
  description = "Path to certificate to use for TLS"
  default     = ""
}

variable "resource_tags" {
  type = map
  default = {
    application = "codecov"
    environment = "test"
  }
}

variable "scm_ca_cert" {
  description = "SCM CA certificate path"
  default     = ""
}
