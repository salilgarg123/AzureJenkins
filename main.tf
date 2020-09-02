resource "azurerm_kubernetes_cluster" "k8s" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  private_cluster_enabled = true


  service_principal {
    client_id     = "dd7a40f7-6ddd-443c-bb7f-2a2b3455891c"
    client_secret = "JmpSa8-3VfcO1_WPTaLLiAT-Xpn~3vfJ14"
  }

  default_node_pool {
    name           = "agentpool"
    node_count     = var.agent_count
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/rg-internalnetwork-dev-001/providers/Microsoft.Network/virtualNetworks/vnet-dev-internal-app-centralus-001/subnets/snet-dev-build-centralus-001"
  }

  addon_profile {
    oms_agent {
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

// add to cluster module
# Link the Bastion Vnet to the Private DNS Zone generated to resolve the Server IP from the URL in Kubeconfig
resource "azurerm_private_dns_zone_virtual_network_link" "link_bastion_cluster" {
  name                  = "dnslink-bastion-cluster"
  private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.k8s.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.k8s.private_fqdn))))
  resource_group_name   = "MC_rg-aks-dev-001_${var.cluster_name}_centralus"
  //resource_group_name   = var.resource_group_name //"MC_${var.resource_group_name}_${azurerm_kubernetes_cluster.k8s.name}_${var.location}"
  //virtual_network_id    = azurerm_virtual_network.vnet_bastion.id
  virtual_network_id = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/rg-internalnetwork-dev-001/providers/Microsoft.Network/virtualNetworks/vnet-dev-internal-mgmt-centralus-001"
}
/*
resource "helm_release" "trg_ha_proxy" {
  name    = "build-ha-proxy"
  repository = "https://haproxytech.github.io/helm-charts"
  chart    = "kubernetes-ingress"
  version = "1.4.4"
  set {
    name = "controller.kind"
    value = "DaemonSet"
  }
  set {
    name = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name = "controller.service.loadBalancerIP"
    value = "10.0.31.201"
  }
  set {
    name = "controller.ingressClass"
    value = "haproxy"
  }
}
*/
resource "helm_release" "trg_jenkins" {
  name    = "build-jenkins"
  repository = "https://charts.jenkins.io"
  chart    = "jenkins"
  version = "2.6.1"
   set {
    name = "master.ingress.enabled"
    value = "true"
  }
  set {
    name = "master.ingress.hostname"
    value = "build-dev.optimize.trgscreen.com"
  }
}