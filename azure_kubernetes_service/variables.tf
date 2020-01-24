variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default = "eastus"
}

variable "azurerm_client_id" {
  description = "Azure service principal client id to use for kubernetes cluster"
}

variable "azurerm_client_secret" {
  description = "Azure service principal client secret to use for kubernetes cluster"
}

variable "codecov_version" {
  description = "Version of codecov enterprise to deploy"
  default = "4.4.7"
}

variable "cluster_name" {
  description = "Google Kubernetes Engine (GKE) cluster name"
  default = "default-codecov-cluster"
}

variable "node_pool_count" {
  description = "The number of nodes to execute in the kubernetes node pool"
  default = "5"
}

variable "node_pool_vm_size" {
  description = "The vm size to use for the node pool instances"
  default = "Standard_B2s"
}

variable "postgres_sku" {
  description = "PostgreSQL DB SKU"
  default = {
    name = "GP_Gen5_2"
    capacity = "2"
    tier = "GeneralPurpose"
    family = "Gen5"
  }
}

variable "postgres_storage_profile" {
  description = "Storage profile for PostgreSQL DB"
  default = {
    storage_mb = "5120"
    backup_retention_days = "7"
    geo_redundant_backup = "Disabled"
  }
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

variable "traefik_replicas" {
  description = "Number of traefik replicas to deploy"
  default = "2"
}

variable "codecov_yml" {
  description = "Path to your codecov.yml"
  default = "codecov.yml"
}

variable "ingress_host" {
  description = "Hostname used for http(s) ingress"
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
