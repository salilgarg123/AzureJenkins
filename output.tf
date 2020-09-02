output "client_key" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
  sensitive   = true
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
  sensitive   = true
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.password
  sensitive   = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s.kube_config_raw
}

output "host" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}
/* 
output "load_balancer_ip" {
  value = "${kubernetes_service.jenkins_service.load_balancer_ingress.0.ip}"
} */

/*output "ingress_ip" {
  value = formatlist("%s ", kubernetes_ingress.k8_ingress.load_balancer_ingress.*.ip)
}*/

output "helm_values" {
  value = helm_release.trg_jenkins.values
}

output "helm_chart" {
  value = helm_release.trg_jenkins.chart
}

output "k8_namespace" {
  value = helm_release.trg_jenkins.namespace
}