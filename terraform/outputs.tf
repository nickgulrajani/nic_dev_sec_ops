output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "cosmos_db_endpoint" {
  value = module.cosmos_db.cosmos_db_endpoint
}

output "app_url" {
  value = module.container_apps.app_url
}
