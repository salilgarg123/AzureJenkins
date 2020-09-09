module "jenkins_k8cluster" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  //source             = "../trg-terraform-build-aks"
  aks_info           = var.aks_info
  sp_app_id          = var.sp_app_id
  sp_client_secret   = var.sp_client_secret
  management_vnet_id = var.management_vnet_id
}

resource "helm_release" "trg_jenkins" {
  name    = "build-jenkins"
  repository = "https://charts.jenkins.io"
  chart    = "jenkins"
  version = "2.6.1"
  values = [<<EOF
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: slow
    provisioner: kubernetes.io/azure-disk
    parameters:
      skuName: Standard_LRS
      location: centralus
      storageAccount: stdevterraformstate002
    EOF
    ]
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

