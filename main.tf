resource "random_password" "password" {
  length = 12
}

module "jenkins_k8cluster" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  //source            = "..//trg-terraform-build-aks"
  aks_info           = var.aks_info
  management_vnet_id = var.management_vnet_id
}

data "azurerm_container_registry" "trg-acr" {
  name                = var.container_registry_name
  resource_group_name = var.container_registry_resource_group_name
}

resource "azurerm_role_assignment" "aks_sp_container_registry" {
  scope                = data.azurerm_container_registry.trg-acr.id
  role_definition_name = "AcrPull"
  principal_id         = "84d62cc9-9485-43a0-998f-ce6a3559c794" //module.jenkins_k8cluster.sp_object_id
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name = var.pvc
  }
  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "8Gi"
      }
    }
    storage_class_name = var.storageclass
  }
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      metadata
    ]
  }
}

resource "kubernetes_secret" "jenkins-secret" {
  metadata {
    name = "jenkins-admin"
  }
  data = {
    jenkins-admin-user = var.jenkins-admin-user
    jenkins-admin-password = random_password.password.result
  }

}

resource "kubernetes_storage_class" "sc" {
  metadata {
    name = var.storageclass
  }
  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy      = "Retain"
  allow_volume_expansion = false
}

resource "helm_release" "trg_jenkins" {
  name       = "build-jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "2.6.1"

  set{
    name = "master.admin.existingSecret"
    value =  kubernetes_secret.jenkins-secret.metadata[0].name
  }

   set {
    name  = "persistence.existingClaim"
    value = var.pvc
   } 

  set {
    name  = "master.ingress.enabled"
    value = true
  }
  set {
    name  = "master.ingress.path"
    value = "/"
  }
  set {
    name  = "master.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }
  set {
    name  = "master.ingress.apiVersion"
    value = "networking.k8s.io/v1beta1"
  }
  set {
    name  = "master.installPlugins"
    value = "{${join(",", var.jenkins_plugins)}}"
  }

  set {
    name  = "master.numExecutors"
    value =  5
  }

  set {
    name  = "master.executorMode"
    value = "EXCLUSIVE"
  }
  set {
    name = "master.enableXmlConfig"
    value = "true"
  }
  set {
    name = "master.overwriteConfig"
    value ="true"
  }
 
  values = [
    templatefile("${path.root}/values.yml", { trgclient = var.trgclient })
  ]
 
//     depends_on = [module.jenkins_k8cluster]
}
