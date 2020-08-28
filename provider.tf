provider "azurerm" {
  version = "=2.5.0"
  features {}
}
provider "kubernetes" {

  //host = "https://k8stest-3d454ce5.hcp.centralus.azmk8s.io"
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  
  //username               = azurerm_kubernetes_cluster.k8s.kube_config.0.username
  //password               = azurerm_kubernetes_cluster.k8s.kube_config.0.password

  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)

}

