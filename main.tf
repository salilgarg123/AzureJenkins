module "jenkins_k8cluster" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  //source            = "..//trg-terraform-build-aks"
  aks_info           = var.aks_info
  management_vnet_id = var.management_vnet_id
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
  
//  set {
//    name  = "persistence.storageClass"
//    value = "managed-premium-retain"
//  }

   set {
    name  = "persistence.existingClaim"
    value = "azure-managed-disk"
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
  depends_on = [module.jenkins_k8cluster]
}
