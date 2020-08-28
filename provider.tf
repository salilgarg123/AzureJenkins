provider "azurerm" {
  version = "=2.5.0"
  features {}
}
provider "kubernetes" {

  host = "https://k8stest-3d454ce5.hcp.centralus.azmk8s.io"

  client_certificate     = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
  client_key             = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
  cluster_ca_certificate = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
}