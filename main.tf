resource "azurerm_kubernetes_cluster" "k8s" {
  name                    = "aks-dev-jenkins"
  location                = "centralus"
  resource_group_name     = "rg-aks-dev-001"
  dns_prefix              = "k8stest"
  private_cluster_enabled = true


  service_principal {
    client_id     = "dd7a40f7-6ddd-443c-bb7f-2a2b3455891c"
    client_secret = "JmpSa8-3VfcO1_WPTaLLiAT-Xpn~3vfJ14"
  }

  default_node_pool {
    name           = "agentpool"
    node_count     = "3"
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/rg-internalnetwork-dev-001/providers/Microsoft.Network/virtualNetworks/vnet-dev-internal-app-centralus-001/subnets/snet-dev-build-centralus-001"
  }

  addon_profile {
    oms_agent {
      enabled = false
    }
    kube_dashboard {
      enabled = false
    }
  }

  network_profile {
    load_balancer_sku  = "Standard"
    network_plugin     = "azure"
    service_cidr       = "10.1.0.0/18"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.1.0.10"
  }

  tags = {
    Environment = "Development"
  }
}

# Link the Bastion Vnet to the Private DNS Zone generated to resolve the Server IP from the URL in Kubeconfig
resource "azurerm_private_dns_zone_virtual_network_link" "link_bastion_cluster" {
  name                  = "dnslink-bastion-cluster"
  private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.k8s.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.k8s.private_fqdn))))
  resource_group_name   = "MC_rg-aks-dev-001_aks-dev-jenkins_centralus"
  virtual_network_id = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/rg-internalnetwork-dev-001/providers/Microsoft.Network/virtualNetworks/vnet-dev-internal-mgmt-centralus-001"
}

resource "helm_release" "trg_ingress" {
  name = "nginx-ingress"
  repository = "https://kubernetes-charts.storage.googleapis.com/"
  chart      = "nginx-ingress"
  version    = "1.27.0"
  set {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = true
  }
}

/* module "jenkins_k8cluster" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  //source             = "../trg-terraform-build-aks"
  aks_info           = var.aks_info
  management_vnet_id = var.management_vnet_id
}
 */
/* resource "kubernetes_secret" "jenkins_k8secret" {
  metadata {
    name = "basic-auth"
  }

  data = {
    username = "admin"
    password = "P4ssw0rd"
  }

  type = "kubernetes.io/basic-auth"
} */

resource "azurerm_managed_disk" "jenkins_managed_disk" {
    lifecycle {
          prevent_destroy = true
    }
  name                 = "manageddisk_dev_jenkins"
  location             = var.aks_info.aks-dev-jenkins.location
  resource_group_name  = var.aks_info.aks-dev-jenkins.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "8"

  tags = {
    environment = var.aks_info.aks-dev-jenkins.tag_environment
  }
}

resource "helm_release" "trg_jenkins" {
  name    = "build-jenkins"
  repository = "https://charts.jenkins.io"
  chart    = "jenkins"
  version = "2.6.1"
  /* values = [<<EOF
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: slow
    provisioner: kubernetes.io/azure-disk
    parameters:
      skuName: Standard_LRS
      location: centralus
      storageAccount: manageddisk_dev_jenkins
    EOF
    ] */
  set {
    name = "persistence.enabled"
    value = true
  }
  set {
    name = "persistence.existingClaim"
    value = "manageddisk_dev_jenkins"
  }
  set {
    name = "persistence.storageClass"
    value = ""
  }
  set {
    name = "master.ingress.enabled"
    value = true
  }
  set {
    name = "master.ingress.path"
    value = "/"
  }
  set {
    name = "master.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }
  set {
    name = "master.ingress.apiVersion"
    value = "networking.k8s.io/v1beta1"
  }
  set {
    name = "master.JCasC.enabled"
    value = true
  }
  set {
    name = "master.JCasC.defaultConfig"
    value = true
  }
  set {
    name = "master.JCasC.securityRealm"
    value = "legacy"
  }
  set {
    name = "master.installPlugins"
    value = "{${join(",", var.jenkins_plugins)}}"
  }
  set {
    name = "master.JCasC.authorizationStrategy.loggedInUsersCanDoAnything.allowAnonymousRead"
    value = false
  }
  depends_on = [azurerm_managed_disk.jenkins_managed_disk, azurerm_kubernetes_cluster.k8s]
}

