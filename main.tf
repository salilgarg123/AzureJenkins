resource "azurerm_kubernetes_cluster" "k8s" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  private_cluster_enabled = true
  
  identity {
    type = "SystemAssigned"
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

# Link the Bastion Vnet to the Private DNS Zone generated to resolve the Server IP from the URL in Kubeconfig
resource "azurerm_private_dns_zone_virtual_network_link" "link_bastion_cluster" {
  name = "dnslink-bastion-cluster"
  private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.k8s.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.k8s.private_fqdn))))
  resource_group_name   = "MC_rg-aks-dev-001_k8stest_centralus"
  //resource_group_name   = "MC_${var.resource_group_name}_${azurerm_kubernetes_cluster.k8s.name}_${var.location}"
  //virtual_network_id    = azurerm_virtual_network.vnet_bastion.id
  virtual_network_id    = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/rg-internalnetwork-dev-001/providers/Microsoft.Network/bastionHosts/trg-dev-bastion"
}

resource "kubernetes_ingress" "k8_ingress" {
  metadata {
    name = "k8-ingress"
  }

  spec {
    backend {
      service_name = "MyApp1"
      service_port = 8080
    }

    rule {
      http {
        path {
          backend {
            service_name = "MyApp1"
            service_port = 8080
          }

          path = "/app1/*"
        }

        path {
          backend {
            service_name = "MyApp2"
            service_port = 8080
          }

          path = "/app2/*"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}

/*******************
jenkins deployment 
********************/

/* resource "kubernetes_pod" "jenkins" {
  metadata {
    name = "jenkins-instance-dev-001"
    labels = {
      App = "jenkins-instance"
    }
  }

  spec {
    container {
      image = "jenkins/jenkins"
      name  = "jenkins-container-dev-001"

      port {
        container_port = 8080
      }
    }
  }
} */

resource "kubernetes_deployment" "jenkins_deployment" {
  metadata {
    name = "jenkins-instance-dev-001"
    labels = {
      App = "jenkins-instance"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        App = "jenkins-instance"
      }
    }

    template {
      metadata {
        labels = {
          App = "jenkins-instance"
        }
      }

      spec {
        container {
          name  = "jenkins-container-dev-001"
          image = "jenkins/jenkins"
        }
      }
    }
  }
}


resource "kubernetes_service" "jenkins_service" {
  metadata {
    name = "jenkins-service-dev-001"
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-internal"        = "true"
      "service.beta.kubernetes.io/azure-load-balancer-internal-subnet" = "snet-dev-build-centralus-001"
    }
  }
  spec {
    selector = {
      App = kubernetes_deployment.jenkins_deployment.metadata.0.labels.App
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type       = "ClusterIP"
    cluster_ip = "10.1.0.11"
  }
} 
