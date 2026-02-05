resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.scm.name
  location            = azurerm_resource_group.scm.location
  os_type             = "Linux"
  sku_name            = "F1" # Free Tier
}

resource "azurerm_linux_web_app" "frontend" {
  name                = var.webapp_name
  resource_group_name = azurerm_resource_group.scm.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      node_version = "20-lts"
    }
    always_on = false # F1 tier does not support Always On
  }

  app_settings = {
    "WEBSITES_PORT" = "3000"
  }
}
