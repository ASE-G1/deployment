resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.scm.name
  location            = azurerm_resource_group.scm.location
  os_type             = "Linux"
  sku_name            = "B1" # B1 is lowest paid, F1 is free but has limitations. B1 is safer for Node.
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
  }

  app_settings = {
    "WEBSITES_PORT" = "3000" # If serving with `serve -s build`, verify port.
  }
}
