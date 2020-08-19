**Note: This module is provided purely as an example and not as an
official Codecov Enterprise deployment strategy. If you want to use
this configuration to test Codecov Enterprise on your own internally
maintained cluster, that is fine. Codecov, however, _will not support_
its use in production environments, nor will we provide support for this
module's installation or continued use in any context.**

# Codecov terraform module for kubernetes

This module provides an example of how to set up Codecov Enterprise in a 
kubernetes cluster.

It is *highly* recommended to deploy Codecov Enterprise into a managed k8s
cluster on one of the major cloud providers: AWS, GCP, or Azure. Those
terraform configurations are supported and provided elsewhere in this
repository. Codecov will fully support these configurations if problems
arise as a result of their use.

## Prerequisites

- A working [kubernetes cluster](https://kubernetes.io/docs/home/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) configured
  to access your cluster.
- [terraform](https://www.terraform.io/downloads.html) version `0.12.x`

## Required services

- A postgresql v10 server configured to allow connections from your k8s cluster. 
- A redis server configured to allow connections from your k8s cluster.
- An S3-compatible object store such as [minio](https://min.io/download).
- A load balancer or other form of ingress into your k8s cluster.

## Module Parameters

| name | description | default |
| --- | --- | --- |
| `codecov_version` | Version of Codecov Enterprise to deploy | 4.5.5 |
| `web_replicas` | Number of web pod replicas to run | 2 |
| `worker_replicas` | Number of worker pod replicas to run | 2 |
| `codecov_yml` | Path to your enterprise [codecov.yml](https://docs.codecov.io/docs/configuration). [example](codecov.yml.example) | required |
| `resource_tags` | Map of tags to include in compatible resources | `{application=codecov, environment=test}` |
| `scm_ca_cert` | Optional SCM CA certificate path in PEM format | |

### `scm_ca_cert`

If `scm_ca_cert` is configured, it will be available to Codecov at
`/cert/scm_ca_cert.pem`.  Include this path in your `codecov.yml` in the scm
config.

## Setup

1. Install the module in your terraform project.
1. Configure the module
    ```
    # example module definition
    module "codecov" {
      source = "git@github.com:codecov/enterprise-resources.git//terraform-k8s-codecov"
      codecov_version = "4.5.5"
      web_replicas = "2"
      worker_replicas = "2"
      codecov_yml = "${path.module}/codecov.yml"
      resource_tags = {
        application = "codecov",
        environment = "test",
      }
      scm_ca_cert = "${path.module}/ca.pem"
    }
    ```
1. Run `terraform init` to import the module and the required terraform
   providers.
1. Carry on with normal [terraform usage](https://learn.hashicorp.com/terraform/getting-started/build.html) (`terraform plan`, `terraform apply`)
1. Point your load balancer at the `web` service IP and port.
