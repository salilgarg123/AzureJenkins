module "jenkins_k8cluster" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  //source            = "..//trg-terraform-build-aks"
  aks_info           = var.aks_info
  management_vnet_id = var.management_vnet_id
}

/* resource "azurerm_managed_disk" "jenkins_managed_disk" {
  lifecycle {
    prevent_destroy = false
  }
  name                 = "manageddisk_dev_jenkins"
  location             = var.aks_info.location
  resource_group_name  = module.jenkins_k8cluster.managed_rg_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "8"

  tags = {
    environment = var.aks_info.tag_environment
  }
} */

resource "helm_release" "trg_jenkins" {
  name       = "build-jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "2.6.1"
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
  /* set {
    name  = "persistence.enabled"
    value = true
  }*/
  set {
    name  = "persistence.storageClassName"
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
