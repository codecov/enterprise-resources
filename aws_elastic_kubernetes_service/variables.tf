variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "codecov_version" {
  description = "Version of codecov enterprise to deploy"
  default     = "4.5.0"
}

variable "cluster_name" {
  description = "Google Kubernetes Engine (GKE) cluster name"
  default     = "default-codecov-cluster"
}

variable "postgres_instance_class" {
  description = "Instance class for PostgreSQL RDS instance"
  default     = "db.t3.micro"
}

variable "postgres_skip_final_snapshot" {
  type = bool
  description = "Whether to skip taking a final snapshot when destroying the Postgres DB"
  default     = "true"
}

variable "redis_node_type" {
  description = "Node type to use for redis cluster nodes"
  default     = "cache.t3.micro"
}

variable "redis_num_nodes" {
  description = "Number of nodes to run in the redis cluster"
  default     = "1"
}

variable "web_nodes" {
  description = "Number of web nodes to create"
  default     = "2"
}

variable "web_node_type" {
  description = "Instance type to use for web nodes"
  default     = "t3.medium"
}

variable "worker_nodes" {
  description = "Number of worker nodes to create"
  default     = "2"
}

variable "worker_node_type" {
  description = "Instance type to use for worker nodes"
  default     = "t3.large"
}

variable "web_resources" {
  type = map
  default = {
    replicas = 2
    cpu_limit = "256m"
    memory_limit = "512M"
    cpu_request = "32m"
    memory_request = "64M"
  }
}

variable "worker_resources" {
  type = map
  default = {
    replicas = 4
    cpu_limit = "512m"
    memory_limit = "2048M"
    cpu_request = "256m"
    memory_request = "2048M"
  }
}

variable "traefik_resources" {
  type = map
  default = {
    replicas = 2
    cpu_limit = "256m"
    memory_limit = "512M"
    cpu_request = "32m"
    memory_request = "64M"
  }
}

variable "codecov_yml" {
  description = "Path to your codecov.yml"
  default     = "codecov.yml"
}

variable "ingress_host" {
  description = "Hostname used for http(s) ingress"
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
  default = ""
}
