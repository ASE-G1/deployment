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

output "postgres_server_host" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "postgres_admin_user" {
  value = azurerm_postgresql_flexible_server.postgres.administrator_login
}

output "redis_hostname" {
  value = azurerm_redis_cache.redis.hostname
}

output "redis_ssl_port" {
  value = azurerm_redis_cache.redis.ssl_port
}

output "redis_primary_access_key" {
  value     = azurerm_redis_cache.redis.primary_access_key
  sensitive = true
}

output "webapp_default_hostname" {
  value = azurerm_linux_web_app.frontend.default_hostname
}
