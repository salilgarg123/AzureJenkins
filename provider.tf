provider "azurerm" {
  version = "=2.10.0" //"~> 2.5.0"
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  version = "1.2.4"
}