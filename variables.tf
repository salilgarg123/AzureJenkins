/* variable "client_id" {}
variable "client_secret" {}
 */
variable "agent_count" {
  default = 3
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "k8stest"
}

variable cluster_name {
  default = "aks-dev-jenkins"
}

variable resource_group_name {
  default = "rg-aks-dev-001"
}

variable location {
  default = "Central US"
}

variable "aks_config" {
  type = map(string)
  default = {
    admin_group    = "cfd65789-4173-4e0a-ac4f-268da9cece28"
    network_plugin = "azure"
    network_policy = "azure"
    dns_prefix     = "optimize-dev-001"
  }
}

/* variable log_analytics_workspace_name {
  default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
  default = "PerGB2018"
} */