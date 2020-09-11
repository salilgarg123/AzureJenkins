module "jenkins_k8cluster" {
  source = "git@bitbucket.org:mavenwave/trg-terraform-build-aks"
  //source             = "../trg-terraform-build-aks"
  aks_info           = var.aks_info
  sp_app_id          = var.sp_app_id
  sp_client_secret   = var.sp_client_secret
  management_vnet_id = var.management_vnet_id
}

resource "kubernetes_secret" "jenkins_k8secret" {
  metadata {
    name = "basic-auth"
  }

  data = {
    username = "admin"
    password = "P4ssw0rd"
  }

  type = "kubernetes.io/basic-auth"
}

resource "azurerm_managed_disk" "jenkins_managed_disk" {
  name                 = "manageddisk_dev_jenkins"
  location             = var.aks_info.aks-dev-jenkins.location
  resource_group_name  = var.aks_info.aks-dev-jenkins.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = var.aks_info.aks-dev-jenkins.tag_environment
  }
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
      storageAccount: manageddisk_dev_jenkins
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
  depends_on = [azurerm_managed_disk.jenkins_managed_disk, module.jenkins_k8cluster]
}

