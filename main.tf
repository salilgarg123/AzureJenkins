module "jenkins_k8cluster" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  //source            = "..//trg-terraform-build-aks"
  aks_info           = var.aks_info
  management_vnet_id = var.management_vnet_id
}
resource "kubernetes_persistent_volume_claim" "example" {
  metadata {
    name = "exampleclaimname"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.example.metadata.0.name}"
  }
}

resource "kubernetes_storage_class" "example" {
  metadata {
    name = "terraform-example"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  reclaim_policy      = "Retain"
  parameters = {
    type = "pd-standard"
  }
  mount_options = ["file_mode=0700", "dir_mode=0777", "mfsymlinks", "uid=1000", "gid=1000", "nobrl", "cache=none"]
}

resource "helm_release" "trg_jenkins" {
  name       = "build-jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "2.6.1"
  
  set {
    name  = "persistence.storageClass"
    value = "managed-premium-retain"
  } 
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
