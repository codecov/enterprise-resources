# Google Kubernetes Engine

This is an example Codecov stack deployed to Google Kubernetes Engine using
terraform.  It consists of:
- A kubernetes cluster
- 3 node groups (web, worker, minio)
- A cloud SQL Postgres instance
- A Redis instance
- A cloud storage bucket for coverage report storage.

This stack will get you started with a fully functional Codecov enterprise
stack, but we suggest you review 
[Best practices for Terraform and Codecov](#best-practices-for-terraform-and-codecov) 
for a fully robust deployment.

## Getting started

This stack requires a Google project and an associated project owner service
account.

- Create a new [Google cloud
  project](https://cloud.google.com/resource-manager/docs/creating-managing-projects).
  We recommend creating a new, dedicated project for Codecov Enterprise in
  order to isolate it from your other production environments.  This will
  ensure that the service account you create in the next step has only the
  permissions necessary to modify the Codecov project.
- Create a [service
  account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) for your project.
- Save the service account json.
- [Grant the project
  owner](https://cloud.google.com/iam/docs/granting-roles-to-service-accounts#granting_access_to_a_service_account_for_a_resource) role to your service account.
- Define `GOOGLE_CLOUD_KEYFILE_JSON=/path/to/service-account.json` to allow the 
  Google cloud terraform provider access to your project.
    ```
    # ~/.bashrc
    export GOOGLE_CLOUD_KEYFILE_JSON=/path/to/service-account.json
    ```
- You will need a DNS hostname to assign to the load balancer IP address (ex:
  `codecov.yourdomain.com`).

## Codecov configuration

Configuration of Codecov enterprise is handled through a YAML config file.
See [configuring codecov.yml](https://docs.codecov.io/docs/configuration) for 
more info.  Refer to this example [codecov.yml](../codecov.yml.example) for the
minimum necessary configuration.

The terraform stack is configured using terraform variables which can be
defined in a `terraform.tfvars` file.  More info on
[Terraform input variables](https://www.terraform.io/docs/configuration/variables.html).

| name | description | default |
| --- | --- | --- |
| `gcloud_project` | Google cloud project name | required |
| `region` | Google cloud region | us-east4 |
| `zone` | Default Google cloud zone for zone-specific services | us-east4a |
| `codecov_version` | Version of codecov enterprise to deploy | 4.4.7 |
| `cluster_name` | Google Kubernetes Engine (GKE) cluster name | default-codecov-cluster |
| `web_node_pool_count` | Number of nodes to create in the web node pool | 1 |
| `worker_node_pool_count` | Number of nodes to create in the worker node pool | 1 |
| `minio_node_pool_count` | Number of nodes to create in the minio default node pool | 1 |
| `node_pool_machine_type` | Machine type to use for the node pools | n1-standard-1 |
| `web_replicas` | Number of web replicas to execute | 2 |
| `worker_replicas` | Number of worker replicas to execute | 2 |
| `minio_replicas` | Number of minio replicas to execute | 4 |
| `traefik_replicas` | Number of traefik replicas to deploy | 2 |
| `minio_bucket_name` | Name of GCS bucket to create for minio | required |
| `minio_bucket_location` | Name of GCS bucket to create for minio | US |
| `minio_bucket_force_destroy` | Required to allow destroying a non-empty bucket | false |
| `redis_instance_name` | Name used for redis instance | required |
| `redis_memory_size` | Amount of memory in GB to allocate for redis instance | 5 |
| `postgres_instance_name` | Name used for postgres instance | required |
| `postgres_instance_type` | Instance type used for postgres | db-f1-micro |
| `codecov_yml` | Path to your codecov.yml | required |
| `ingress_host` | Hostname used for http(s) ingress. (ex: `codecov.yourdomain.com`) | |
| `enable_https` | Enables https ingress.  Requires TLS cert and key | 0 |
| `tls_key` | Path to private key to use for TLS | required if enable_https=1 |
| `tls_cert` | Path to certificate to use for TLS | required if enable_https=1  |

## Executing terraform

After configuring `codecov.yml` and `terraform.tfvars` you are ready to execute
terraform and create the stack following these steps:

1. Run `terraform init`.  This will download the necessary provider modules and
   prepare your terraform environment for execution.  [Terraform
   init](https://www.terraform.io/docs/commands/init.html)
1. Create a plan: `terraform plan -out=plan.out`.  This checks the current
   state and saves an execution plan to `plan.out`.  [Terraform
   plan](https://www.terraform.io/docs/commands/plan.html)
1. If you're satisfied with the execution plan, apply it.  `terraform apply
   plan.out`.  This will begin creating your stack.  [Terraform
   apply](https://www.terraform.io/docs/commands/apply.html)
1. Wait... this will take a little while.  If everything goes well, you will
   see something like this:
     ```
     [...]
     
     Apply complete! Resources: 36 added, 0 changed, 0 destroyed.
     Outputs:
     
     ingress-ip = xx.xx.xx.xx
     minio-access-key = xxxxxxxxxxx
     minio-secret-key = xxxxxxxxxxxxxxx
     ```
1. The ingress IP and minio API keys are output at the end of the run.
   Create a DNS A record for the `ingress_host` above pointing at the
   resulting `ingress-ip`.  If you wish to use a tool to access your 
   reports through minio, you can use the key pair above to access it 
   using an s3-compatible tool like the [minio
   client](https://docs.min.io/docs/minio-client-quickstart-guide).
1. To show the outputs again: `terraform output`
1. Google executes an upgrade on the cluster control plane after creation,
   so some operations (such as `plan` or `apply`) will be unable to 
   execute until this upgrade completes.

## Destroying

If you want to remove your Codecov Enterprise stack, a `destroy.sh` script is
provided.  *This will remove all of your enterprise configuration and uploaded
coverage reports.*  All resources created with terraform will be removed, so
please use with caution.

## Best practices for Terraform and Codecov

This is intended to be an example terraform stack.  As such, it ignores some
terraform best practices such as remote state storage and locking.  For more
info on running a robust terraform stack see [Terraform Recommended
Practices](https://www.terraform.io/docs/enterprise/guides/recommended-practices/index.html).

Please review Codecov [Self-hosted Best
Practices](https://docs.codecov.io/docs/best-practices) as well.
