resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.scm.name
  location            = azurerm_resource_group.scm.location
  sku                 = "Basic"
  admin_enabled       = true
}
