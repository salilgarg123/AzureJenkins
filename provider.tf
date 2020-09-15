provider "azurerm" {
  version = "=2.10.0" //"~> 2.5.0"
  features {}
}

provider "kubernetes" {
/*   host                   = module.jenkins_k8cluster.output.host
  client_certificate     = base64decode(module.jenkins_k8cluster.client_certificate)
  client_key             = base64decode(module.jenkins_k8cluster.client_key)
  cluster_ca_certificate = base64decode(module.jenkins_k8cluster.cluster_ca_certificate)
 */}

provider "helm" {
  kubernetes {
  /*   host                   = module.jenkins_k8cluster.host
    client_certificate     = base64decode(module.jenkins_k8cluster.client_certificate)
    client_key             = base64decode(module.jenkins_k8cluster.client_key)
    cluster_ca_certificate = base64decode(module.jenkins_k8cluster.cluster_ca_certificate)
 */  }
}

/* provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  }
}
 */