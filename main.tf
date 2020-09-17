module "jenkins_k8cluster" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  //source            = "..//trg-terraform-build-aks"
  aks_info           = var.aks_info
  management_vnet_id = var.management_vnet_id
}

resource "azurerm_managed_disk" "jenkins_managed_disk" {
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
}

resource "kubernetes_persistent_volume" "example" {
  metadata {
    name = "azure-pv-aks"
  }
  spec {
    capacity = {
      storage = "8Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      azure_disk  {
        caching_mode = "ReadWrite"
        data_disk_uri = "/subscriptions/63a4467b-b46e-4f35-b623-1e5b076ef28c/resourceGroups/MC_rg-aks-dev-001_aks-dev-jenkins_centralus/providers/Microsoft.Compute/disks/manageddisk_dev_jenkins"
        disk_name  = "manageddisk_dev_jenkins"
      }
    }
  }
}



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
/*   set {
    name  = "persistence.storageClass"
    value = "Retain"
  } */
  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume.example.metadata.0.name
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
  depends_on = [azurerm_managed_disk.jenkins_managed_disk, module.jenkins_k8cluster]
}
