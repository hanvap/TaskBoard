variable "resource_group_name" {
  type        = string
  description = "Resouce group neme in Azure"
}
variable "resource_group_location" {
  type        = string
  description = "Resouce group location in Azure"
}
variable "app_service_plan_name" {
  type        = string
  description = "App serce plan neme in Azure"
}
variable "app_service_name" {
  type        = string
  description = "App service name in Azure"
}
variable "mssql_server_name" {
  type        = string
  description = "Mssql server neme in Azure"
}
variable "mssql_server_location" {
  type        = string
  description = "mssql server lacotion in Azure"
}
variable "mssql_server_administrator_ligin" {
  type        = string
  description = "administrator_ligin in mssql"
}
variable "mssql_server_administrator_password" {
  type        = string
  description = "administrator_password in mssql"
}
variable "mssql_database_name" {
  type        = string
  description = "Database name in mssql"
}
variable "mssql_firewall_rule_name" {
  type        = string
  description = "Firewall rule in mssql"
}