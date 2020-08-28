/* module "service_principal" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-service-principal.git"
  //source            = "../trg-terraform-build-service-principal"
  application_name  = var.application_name
  description       = var.description
  value             = var.value
  end_date_relative = var.end_date_relative
} */

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  identity {
    type = "SystemAssigned"
  }

  /*   azure_active_directory {
    managed                = true
    admin_group_object_ids = var.aks_config.admin_group
  } */

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  /*     service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    } */

  addon_profile {
    oms_agent {
      enabled = false
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    Environment = "Development"
  }
}

/*******************
jenkins deployment 
********************/

resource "kubernetes_pod" "jenkins" {
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
}


# resource "kubernetes_deployment" "jenkins_deployment" {
#   metadata {
#     name = "jenkins-deployment-dev-001"
#     labels = {
#       dev = "jenkins-dev-001"
#     }
#   }

#   spec {
#     replicas = 2

#     selector {
#       match_labels = {
#         dev = "jenkins-dev-001"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           dev = "jenkins-dev-001"
#         }
#       }

#       spec {
#         container {
#           image = "jenkins/jenkins"
#           name  = "jenkins-container-dev-001"

#           port {
#             container_port = 8080
#           }
#         }
#       }
#     }
#   }
# }

resource "kubernetes_service" "jenkins_service" {
  metadata {
    name = "jenkins-service-dev-001"
  }
  spec {
    selector = {
      App = kubernetes_pod.jenkins.metadata.0.labels.App
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}

output "load_balancer_ip" {
  value = "${kubernetes_service.jenkins_service.load_balancer_ingress.0.ip}"
}