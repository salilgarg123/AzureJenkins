module "jenkins_k8cluster" {
  //source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  source = "../trg-terraform-build-aks"
  aks_info = var.aks_info
  resource_group = data.terraform_remote_state.resource_group.outputs.id.value[2]
}

resource "helm_release" "trg_jenkins" {
  name    = "build-jenkins"
  repository = "https://charts.jenkins.io"
  chart    = "jenkins"
  version = "2.6.1"
  
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
}
