output "resource_group_name" {
  value = azurerm_resource_group.scm.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}





output "webapp_default_hostname" {
  value = azurerm_linux_web_app.frontend.default_hostname
}
