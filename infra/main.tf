resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

locals {
  name_suffix = "${var.project}-${random_string.suffix.result}"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-dev"
  location = var.location
}

resource "azurerm_service_plan" "main" {
  name                = "plan-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  site_config {
    always_on = false

    application_stack {
      node_version = "20-lts"
    }
  }
}

resource "azurerm_mssql_server" "main" {
  name                         = "sql-${local.name_suffix}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_database" "main" {
  name        = "sqldb-${var.project}"
  server_id   = azurerm_mssql_server.main.id
  sku_name    = "Basic"
  max_size_gb = 2
}

resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
