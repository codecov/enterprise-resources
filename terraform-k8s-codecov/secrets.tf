resource "kubernetes_secret" "codecov-yml" {
  metadata {
    name        = "codecov-yml"
    annotations = var.resource_tags
  }
  data = {
    "codecov.yml" = file(var.codecov_yml)
  }
}

resource "kubernetes_secret" "scm-ca-cert" {
  metadata {
    name        = "scm-ca-cert"
    annotations = var.resource_tags
  }
  data = {
    "scm_ca_cert.pem" = var.scm_ca_cert != "" ? file(var.scm_ca_cert) : ""
  }
}
