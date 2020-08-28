/* module "service_principal" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-service-principal.git"
  //source            = "../trg-terraform-build-service-principal"
  application_name  = var.application_name
  description       = var.description
  value             = var.value
  end_date_relative = var.end_date_relative
} */

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  identity {
    type = "SystemAssigned"
  }

  /*   azure_active_directory {
    managed                = true
    admin_group_object_ids = var.aks_config.admin_group
  } */

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  /*     service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    } */

  addon_profile {
    oms_agent {
      enabled = false
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    Environment = "Development"
  }
}