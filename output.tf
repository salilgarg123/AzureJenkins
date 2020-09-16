output "client_key" {
  value = module.jenkins_k8cluster.kube_config.client_key
  sensitive = true
}

output "client_certificate" {
  value = module.jenkins_k8cluster.kube_config.client_certificate
  sensitive = true
}

output "cluster_ca_certificate" {
  value = module.jenkins_k8cluster.kube_config.cluster_ca_certificate
  sensitive = true
}

output "cluster_username" {
  value = module.jenkins_k8cluster.kube_config.username
}

output "cluster_password" {
  value = module.jenkins_k8cluster.kube_config.password
  sensitive = true
}

output "kube_config" {
  value = module.jenkins_k8cluster.kube_config_raw
  sensitive = true
}

output "host" {
  value = module.jenkins_k8cluster.host
}

output "jenkins_managed_disk_id" {
  description = "The ID of the Managed Disk."
  value = azurerm_managed_disk.jenkins_managed_disk.id
}
