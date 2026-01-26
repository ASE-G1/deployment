resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = var.postgres_server_name
  resource_group_name    = azurerm_resource_group.scm.name
  location               = azurerm_resource_group.scm.location
  version                = "13"
  administrator_login    = var.postgres_admin_user
  administrator_password = var.postgres_admin_password
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7

  # For cost saving in dev/test, use Burrowable (B) tier. 
  # Check availability in region.
}

resource "azurerm_postgresql_flexible_server_database" "scm_db" {
  name      = "scm"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Allow access from Azure services (0.0.0.0-0.0.0.0) is not directly supported in the same way as single server
# For flexible server, we usually whitelist client IP or use VNet integration.
# "Allow public access from any Azure service within Azure to this server" equivalent
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow all IPs for testing purposes (NOT RECOMMENDED FOR PROD, but simplifies initial access)
# Or user's current IP should be added. warning about this.
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
