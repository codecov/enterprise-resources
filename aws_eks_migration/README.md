# Elastic Kubernetes Service Example

This is an example Codecov stack deployed to AWS Elastic Kubernetes Service via
terraform.  It consists of:
- An EKS kubernetes cluster
- An Elasticache Redis instance

This stack is intended for use by existing Codecov Enterprise users who wish
to migrate to this stack while maintaining their existing VPC, subnets, 
PostgreSQL database and S3 bucket.  It differs from our other [turn-key AWS
stack](https://github.com/codecov/enterprise-resources/blob/master/aws_elastic_kubernetes_service/README.md)
in that these resources are provided as variables instead of configured 
for you in terraform.

This stack will get you started with a fully functional Codecov enterprise
stack, but we suggest you review 
[Best practices for Terraform and Codecov](#best-practices-for-terraform-and-codecov) 
for a fully robust deployment.

## Getting Started

- Install the [aws
  cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
  tool.
- Install the
  [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
  utility.
- Create a new [IAM
  user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html).
- Attach the [AdministratorAccess
  policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_administrator) to your newly created user.
- [Create access
  keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html?icmpid=docs_iam_console)
  for your IAM user.
- [Configure your aws
  cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration) 
  to use the above access keys.  It is recommended to install these keys in
  a profile (ex: `aws configure --profile codecov`).
- Export AWS_PROFILE and KUBECONFIG variables using your `~/.bash_profile` or a tool
  like [direnv](https://direnv.net/).  Your kubeconfig will be named
  `kubeconfig_${var.cluster_name}`.
    ```
    export AWS_PROFILE=codecov
    export KUBECONFIG=kubeconfig_default-codecov-cluster
    ```
- You will need a DNS CNAME to assign to the load balancer address (ex:
  `codecov.yourdomain.com`).  Instructions on how to set this up are below in
  the [Executing terraform](#executing-terraform) section.
- It is assumed you have a VPC with both public and private subnets configured,
  as well as a PostgreSQL database and S3 bucket accessible within this VPC.

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
| `region` | AWS region | us-east-1 |
| `vpc_id` | ID of VPC containing your PostgreSQL instance. This VPC will be used for EKS | |
| `vpc_private_subnet_ids` | List of private subnet IDs to use for EKS nodes | `[]` |
| `codecov_version` | Version of codecov enterprise to deploy | 4.4.7 |
| `cluster_name` | Google Kubernetes Engine (GKE) cluster name | default-codecov-cluster |
| `postgres_url` | URL for your postgres instance | |
| `s3_bucket` | S3 bucket name used for report storage | |
| `redis_node_type` | Node type to use for redis cluster nodes | cache.t2.micro |
| `redis_num_nodes` | Number of nodes to run in the redis cluster | 1 |
| `web_nodes` | Number of web nodes to create | 2 |
| `web_node_type` | Instance type to use for web nodes | t2.medium |
| `worker_nodes` | Number of worker nodes to create | 2 |
| `worker_node_type` | Instance type to use for worker nodes | t2.medium |
| `minio_nodes` | Number of minio nodes to create | 4 |
| `minio_node_type` | Instance type to use for minio nodes | t2.medium |
| `web_replicas` | Number of web replicas to execute | 2 |
| `worker_replicas` | Number of worker replicas to execute | 2 |
| `minio_replicas` | Number of minio replicas to execute | 4 |
| `codecov_yml` | Path to your codecov.yml | codecov.yml |
| `ingress_host` | Hostname used for http(s) ingress | |
| `traefik_replicas` | Number of traefik replicas to deploy | 2 |
| `enable_https` | Enables https ingress.  Requires TLS cert and key | 0 |
| `tls_key` | Path to private key to use for TLS | required if enable_https=1 |
| `tls_cert` | Path to certificate to use for TLS | required if enable_https=1 |

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
1. Due to limitations of the current version of Terraform, the `apply` will
   likely encounter an error when attempting to create kubernetes resources.
   This is due to a race condition between the EKS module and the kubernetes
   provider.  Repeating the `plan`, then `apply` procedure above will complete
   creation of the kubernetes resources.
1. Wait... this will take a little while.  If everything goes well, you will
   see something like this:
     ```
     [...]
     
     Apply complete! Resources: 36 added, 0 changed, 0 destroyed.
     Outputs:
     
     ingress-lb-hostname = xxxx.elb.amazonaws.com
     minio-access-key = xxxxxxxxxxx
     minio-secret-key = xxxxxxxxxxxxxxx
     ```
1. The ingress hostname and minio API keys are output at the end of the run.
   Create a DNS CNAME record for the `ingress_host` above pointing at the
   resulting `ingress-lb-hostname`.  If you wish to use a tool to access your
   reports through minio, you can use the key pair above to access it
   using an s3-compatible tool like the [minio
   client](https://docs.min.io/docs/minio-client-quickstart-guide).

## Destroying

If you want to remove your Codecov Enterprise stack, execute `terraform
destroy`.  *This will remove all of your enterprise configuration and uploaded
coverage reports.*  All resources created with terraform will be removed, so
please use with caution.

## Best practices for Terraform and Codecov

This is intended to be an example terraform stack.  As such, it ignores some
terraform best practices such as remote state storage and locking.  For more
info on running a robust terraform stack see [Terraform Recommended
Practices](https://www.terraform.io/docs/enterprise/guides/recommended-practices/index.html).

Please review Codecov [Self-hosted Best
Practices](https://docs.codecov.io/docs/best-practices) as well.
