variable "region" {
  description = "AWS region"
  default = "us-east-1"
}

variable "vpc_id" {
  description = "ID of VPC containing your PostgreSQL instance. This VPC will be used for EKS"
}

variable "vpc_private_subnet_ids" {
  description = "List of private subnet IDs to use for EKS nodes"
  type = "list"
  # example = ["subnet-abcd1234","subnet-efgh5678"]
}

variable "codecov_version" {
  description = "Version of codecov enterprise to deploy"
  default = "4.4.7"
}

variable "cluster_name" {
  description = "Google Kubernetes Engine (GKE) cluster name"
  default = "default-codecov-cluster"
}

variable "postgres_url" {
  description = "URL for your postgres instance"
}

variable "s3_bucket" {
  description = "S3 bucket name used for report storage"
}

variable "redis_node_type" {
  description = "Node type to use for redis cluster nodes"
  default = "cache.t2.micro"
}

variable "redis_num_nodes" {
  description = "Number of nodes to run in the redis cluster"
  default = "1"
}

variable "web_nodes" {
  description = "Number of web nodes to create"
  default = "2"
}

variable "web_node_type" {
  description = "Instance type to use for web nodes"
  default = "t2.medium"
}

variable "worker_nodes" {
  description = "Number of worker nodes to create"
  default = "2"
}

variable "worker_node_type" {
  description = "Instance type to use for worker nodes"
  default = "t2.medium"
}

variable "minio_nodes" {
  description = "Number of minio nodes to create"
  default = "2"
}

variable "minio_node_type" {
  description = "Instance type to use for minio nodes"
  default = "t2.medium"
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
