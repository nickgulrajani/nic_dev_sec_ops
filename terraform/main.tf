resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags
}

module "cosmos_db" {
  source              = "./modules/cosmos-db"
  cosmos_db_name      = var.cosmos_db_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  workspace_name      = var.workspace_name
  appinsights_name    = var.appinsights_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags
}

module "container_apps" {
  source                        = "./modules/container-apps"
  environment_name              = var.environment_name
  app_name                      = var.app_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  log_analytics_workspace_id    = module.monitoring.workspace_id
  container_image               = "${module.acr.acr_login_server}/${var.container_image}"
  mongodb_connection_string     = module.cosmos_db.cosmos_db_connection_string
  appinsights_connection_string = module.monitoring.appinsights_connection_string
  cpu_cores                     = var.cpu_cores
  memory_size                   = var.memory_size
  min_replicas                  = var.min_replicas
  max_replicas                  = var.max_replicas
  tags                          = var.tags
}