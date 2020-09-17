variable "management_vnet_id" {
  description = "The ID of the Virtual Network that should be linked to the DNS Zone."
  default     = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/rg-internalnetwork-dev-001/providers/Microsoft.Network/virtualNetworks/vnet-dev-internal-mgmt-centralus-001"
}

/* variable "sp_app_id" {
  default = "dd7a40f7-6ddd-443c-bb7f-2a2b3455891c"
}

variable "sp_client_secret" {
  default = "JmpSa8-3VfcO1_WPTaLLiAT-Xpn~3vfJ14"
} */

variable "aks_info" {
  type = object({
    name                               = string
    location                           = string
    resource_group_name                = string
    private_cluster_enabled            = bool
    node_pool_name                     = string
    node_pool_count                    = string
    node_pool_size                     = string
    node_pool_subnet_id                = string
    network_profile_load_balancer_sku  = string
    network_profile_service_cidr       = string
    network_profile_docker_bridge_cidr = string
    network_profile_dns_service_ip     = string
    tag_environment                    = string
    sp_app_name                        = string
    sp_description                     = string
    sp_end_date                        = string
    sp_scope                           = string
  })

  default = {
    name                               = "aks-dev-jenkins"
    location                           = "centralus"
    resource_group_name                = "rg-aks-dev-001"
    private_cluster_enabled            = true
    node_pool_name                     = "agentpool"
    node_pool_count                    = "1"
    node_pool_size                     = "Standard_D2_v2"
    node_pool_subnet_id                = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/rg-internalnetwork-dev-001/providers/Microsoft.Network/virtualNetworks/vnet-dev-internal-app-centralus-001/subnets/snet-dev-build-centralus-001"
    network_profile_load_balancer_sku  = "Standard"
    network_profile_service_cidr       = "10.1.0.0/18"
    network_profile_docker_bridge_cidr = "172.17.0.1/16"
    network_profile_dns_service_ip     = "10.1.0.10"
    tag_environment                    = "Development"
    sp_app_name                        = "Optimize Insights Build Jenkins DEV"
    sp_description                     = "Build Jenkins DEV"
    sp_end_date                        = "2099-01-01T01:02:03Z"
    sp_scope                           = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/rg-aks-dev-001"
  }
}

variable "jenkins_plugins" {
  default = [
    "kubernetes:1.25.7",
    "workflow-job:2.39",
    "workflow-aggregator:2.6",
    "credentials-binding:1.23",
    "git:4.2.2",
    "configuration-as-code:1.41"
  ]
}