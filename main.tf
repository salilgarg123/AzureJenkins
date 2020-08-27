module "service_principal" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-service-principal.git"
  //source            = "../trg-terraform-build-service-principal"
  application_name  = var.application_name
  description       = var.description
  value             = var.value
  end_date_relative = var.end_date_relative
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.clustername
  location            = "centralus" //var.location //azurerm_resource_group.k8s.location
  resource_group_name = "rg-terraform-prod-001" //resource_group.   //var.k8_name  //to get it from remote state //azurerm_resource_group.k8s.name
  dns_prefix          = "trg-optimize" //var.dnspreffix
  default_node_pool {
    name       = "default"
    node_count =  "1"  //var.agentnode
    vm_size    = "Standard_D2_v2" //var.size
  }
/*   service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  } */
}