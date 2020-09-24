locals {
  node_resource_group_name = "codecov-enterprise-nodes"
}

resource "azurerm_resource_group" "codecov-enterprise" {
  name     = "codecov-enterprise"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "codecov-enterprise" {
  name                = var.cluster_name
  location            = azurerm_resource_group.codecov-enterprise.location
  resource_group_name = azurerm_resource_group.codecov-enterprise.name
  node_resource_group = local.node_resource_group_name
  dns_prefix          = "codecov-enterprise"

  default_node_pool {
    name            = "codecov"
    node_count      = var.node_pool_count
    vm_size         = var.node_pool_vm_size
    os_disk_size_gb = "30"
    vnet_subnet_id  = azurerm_subnet.codecov.id
  }

  service_principal {
    client_id     = var.azurerm_client_id
    client_secret = var.azurerm_client_secret
  }

  network_profile {
    network_plugin = "azure"
  }

  linux_profile {
    admin_username = "codecov"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  lifecycle {
    ignore_changes = [windows_profile]
  }

  tags = var.resource_tags
}

data "azurerm_public_ip" "egress-ip" {
  name                = split("/", sort(azurerm_kubernetes_cluster.codecov-enterprise.network_profile[0].load_balancer_profile[0].effective_outbound_ips)[0])[8]
  resource_group_name = local.node_resource_group_name
}

output "egress-ip" {
  value = data.azurerm_public_ip.egress-ip.ip_address
}

# write out a .kubeconfig for kubectl
resource "local_file" "kubeconfig" {
  content  = azurerm_kubernetes_cluster.codecov-enterprise.kube_config_raw
  filename = "${path.module}/.kubeconfig"
}

provider "kubernetes" {
  version          = "~>1.11"
  load_config_file = "false"
  host             = azurerm_kubernetes_cluster.codecov-enterprise.kube_config[0].host
  cluster_ca_certificate = base64decode(
    azurerm_kubernetes_cluster.codecov-enterprise.kube_config[0].cluster_ca_certificate,
  )
  client_certificate = base64decode(
    azurerm_kubernetes_cluster.codecov-enterprise.kube_config[0].client_certificate,
  )
  client_key = base64decode(
    azurerm_kubernetes_cluster.codecov-enterprise.kube_config[0].client_key,
  )
}

