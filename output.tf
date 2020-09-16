/* output "client_key" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.password
}
 */

output "kube_config" {
  value = module.jenkins_k8cluster.kube_config_raw
}

output "host" {
  value = module.jenkins_k8cluster.host
}

output "jenkins_managed_disk_id" {
  description = "The ID of the Managed Disk."
  value = azurerm_managed_disk.jenkins_managed_disk.id
}
