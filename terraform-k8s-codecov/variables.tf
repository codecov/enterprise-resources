variable "codecov_version" {
  description = "Version of Codecov Enterprise to deploy"
  default     = "4.5.5"
}

variable "web_replicas" {
  description = "Number of web replicas to deploy"
  default     = "2"
}

variable "worker_replicas" {
  description = "Number of worker replicas to deploy"
  default     = "2"
}

variable "codecov_yml" {
  description = "Location of your codecov.yml file"
}

variable "resource_tags" {
  type = map
  default = {
    application = "codecov"
    environment = "test"
  }
}

# 
variable "scm_ca_cert" {
  description = "SCM CA certificate path"
  default     = ""
}
