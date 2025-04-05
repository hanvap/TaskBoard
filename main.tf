terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate123456"  # Сложи реално име
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "87f801c3-700a-4754-a4ee-8a9717d57752"
  features {}
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "sp" {
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "lwa" {
  name                = "${var.app_service_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.sp.location
  service_plan_id     = azurerm_service_plan.sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqlBD.name};User ID=${azurerm_mssql_server.sqlserver.administrator_login};Password=${azurerm_mssql_server.sqlserver.administrator_login_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }

}

resource "azurerm_app_service_source_control" "git" {
  app_id                 = azurerm_linux_web_app.lwa.id
  repo_url               = "https://github.com/hanvap/TaskBoard"
  branch                 = "main"
  use_manual_integration = true
}
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${var.mssql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.mssql_server_location
  version                      = "12.0"
  administrator_login          = var.mssql_server_administrator_ligin
  administrator_login_password = var.mssql_server_administrator_password
  minimum_tls_version          = "1.2"

}
resource "azurerm_mssql_database" "sqlBD" {
  name           = "${var.mssql_database_name}${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  read_scale     = false
  sku_name       = "Basic"
  zone_redundant = false
}
resource "azurerm_mssql_firewall_rule" "frule" {
  name             = var.mssql_firewall_rule_name
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
