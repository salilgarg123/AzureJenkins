provider "azurerm" {
  version = "=2.10"
  features {}
}

provider "helm" {
  kubernetes {
    host                   = module.jenkins_k8cluster.host
    client_certificate     = base64decode(module.jenkins_k8cluster.client_certificate)
    client_key             = base64decode(module.jenkins_k8cluster.client_key)
    cluster_ca_certificate = base64decode(module.jenkins_k8cluster.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = module.jenkins_k8cluster.host
  client_certificate     = base64decode(module.jenkins_k8cluster.client_certificate)
  client_key             = base64decode(module.jenkins_k8cluster.client_key)
  cluster_ca_certificate = base64decode(module.jenkins_k8cluster.cluster_ca_certificate)
}