# Azure Kubernetes Service Example

This is an example Codecov stack deployed to Azure Kubernetes Service via
terraform.  It consists of:
- A Kubernetes Service cluster
- A Postgres instance
- A Redis instance
- A storage account for coverage report storage.

This stack will get you started with a fully functional Codecov enterprise
stack, but we suggest you review 
[Best practices for Terraform and Codecov](#best-practices-for-terraform-and-codecov) 
for a fully robust deployment.

## Getting Started

- Install the Azure [az
  cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
  tool.
- Log in with the Azure cli tool: `az login`
- Create an Active Directory service principal:
    ```
    az ad sp create-for-rbac --role="Contributor" \
        --scopes="/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    ```
  Save the output of this command, these credentials will be needed to
  configure the Azure provider and Kubernetes cluster.
- Export the following variables using your `~/.bash_profile` or a tool
  like [direnv](https://direnv.net/).  After the kubernetes cluster is
  created, a .kubeconfig file will be created in the current directory for use
  with `kubectl`.  For more information, see [Configuring the Service Principal in
  Terraform](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html#configuring-the-service-principal-in-terraform).
    ```
    export ARM_CLIENT_ID="appId from the above output"
    export ARM_CLIENT_SECRET="password from the above output"
    export ARM_SUBSCRIPTION_ID="the subscription ID you used to create the SP"
    export ARM_TENANT_ID="tenant from the above output"
    export KUBECONFIG=.kubeconfig
    ```
- For more information on this and other ways to configure access for the `azurerm`
  provider, see [Azure Provider](https://www.terraform.io/docs/providers/azurerm/index.html)
  in the terraform documentation.
- You will need a DNS A record to assign to the load balancer address (ex:
  `codecov.yourdomain.com`).  Instructions on how to set this up are below in
  the [Executing terraform](#executing-terraform) section.

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
| `location` | Azure location | eastus |
| `azurerm_client_id` | `appId` from the SP creation output | |
| `azurerm_client_secret` | `password` from the SP creation output | |
| `codecov_version` | Version of codecov enterprise to deploy | 4.4.7 |
| `cluster_name` | Google Kubernetes Engine (GKE) cluster name | default-codecov-cluster |
| `node_pool_count` | Number of nodes to configure in the node pool | 5 |
| `node_pool_vm_size` | VM size to use for node pool nodes | Standard_B2s |
| `postgres_sku` | PostgreSQL SKU (instance size and type) | See `variables.tf` |
| `postgres_storage_profile` | PostgreSQL size and type of disk storage | See `variables.tf` |
| `web_replicas` | Number of web replicas to execute | 2 |
| `worker_replicas` | Number of worker replicas to execute | 2 |
| `minio_replicas` | Number of minio replicas to execute | 4 |
| `traefik_replicas` | Number of traefik replicas to deploy | 2 |
| `codecov_yml` | Path to your codecov.yml | codecov.yml |
| `ingress_host` | Hostname used for http(s) ingress | |
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
1. Wait... this will take a little while.  If everything goes well, you will
   see something like this:
     ```
     [...]
     
     Apply complete! Resources: 36 added, 0 changed, 0 destroyed.
     Outputs:
     
     ingress-lb-ip = xxx.xxx.xxx.xxx
     minio-access-key = xxxxxxxxxxx
     minio-secret-key = xxxxxxxxxxxxxxx
     ```
1. The ingress IP and minio API keys are output at the end of the run.
   Create a DNS A record for the `ingress_host` above pointing at the
   resulting `ingress-lb-ip`.  If you wish to use a tool to access your
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
