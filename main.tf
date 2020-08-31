module "jenkins_k8cluster" {
  //source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  source = "../trg-terraform-build-aks"
  aks_info = var.aks_info
  resource_group = data.terraform_remote_state.resource_group.outputs.id.value[2]
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
      App = kubernetes_pod.jenkins.metadata.0.labels.App
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type       = "ClusterIP"
    cluster_ip = "10.1.0.11"
  }
}
