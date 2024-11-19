#!/bin/bash

# Navigate to terraform directory
cd terraform

# Function to write file content
write_file() {
    echo "Writing $1..."
    cat > "$1"
}

# ACR Module Files
write_file "modules/acr/main.tf" << 'EOF'
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                = "Standard"
  admin_enabled      = true
  tags               = var.tags
}
EOF

write_file "modules/acr/variables.tf" << 'EOF'
variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the ACR"
  type        = map(string)
  default     = {}
}
EOF

write_file "modules/acr/outputs.tf" << 'EOF'
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}
EOF

# Cosmos DB Module Files
write_file "modules/cosmos-db/main.tf" << 'EOF'
resource "azurerm_cosmosdb_account" "db" {
  name                = var.cosmos_db_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}
EOF

write_file "modules/cosmos-db/variables.tf" << 'EOF'
variable "cosmos_db_name" {
  description = "Name of the Cosmos DB account"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to Cosmos DB"
  type        = map(string)
  default     = {}
}
EOF

write_file "modules/cosmos-db/outputs.tf" << 'EOF'
output "cosmos_db_connection_string" {
  value     = azurerm_cosmosdb_account.db.connection_strings[0]
  sensitive = true
}

output "cosmos_db_endpoint" {
  value = azurerm_cosmosdb_account.db.endpoint
}
EOF

# Container Apps Module Files
write_file "modules/container-apps/main.tf" << 'EOF'
resource "azurerm_container_app_environment" "env" {
  name                       = var.environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_container_app" "app" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name         = var.resource_group_name
  revision_mode               = "Single"

  template {
    container {
      name   = "app"
      image  = var.container_image
      cpu    = var.cpu_cores
      memory = var.memory_size

      env {
        name        = "MONGODB_URI"
        secret_name = "mongodb-connection"
      }

      env {
        name        = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "appinsights-connection"
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }

  secret {
    name  = "mongodb-connection"
    value = var.mongodb_connection_string
  }

  secret {
    name  = "appinsights-connection"
    value = var.appinsights_connection_string
  }

  ingress {
    external_enabled = true
    target_port     = 3000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags
}
EOF

write_file "modules/container-apps/variables.tf" << 'EOF'
variable "environment_name" {
  description = "Name of the Container Apps Environment"
  type        = string
}

variable "app_name" {
  description = "Name of the Container App"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 0.5
}

variable "memory_size" {
  description = "Memory size in Gi"
  type        = string
  default     = "1Gi"
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 3
}

variable "mongodb_connection_string" {
  description = "MongoDB connection string"
  type        = string
  sensitive   = true
}

variable "appinsights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to container resources"
  type        = map(string)
  default     = {}
}
EOF

write_file "modules/container-apps/outputs.tf" << 'EOF'
output "app_url" {
  value = azurerm_container_app.app.latest_revision_fqdn
}
EOF

# Monitoring Module Files
write_file "modules/monitoring/main.tf" << 'EOF'
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                = "PerGB2018"
  retention_in_days   = 30
  tags               = var.tags
}

resource "azurerm_application_insights" "appinsights" {
  name                = var.appinsights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
  tags               = var.tags
}
EOF

write_file "modules/monitoring/variables.tf" << 'EOF'
variable "workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "appinsights_name" {
  description = "Name of the Application Insights instance"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to monitoring resources"
  type        = map(string)
  default     = {}
}
EOF

write_file "modules/monitoring/outputs.tf" << 'EOF'
output "appinsights_connection_string" {
  value     = azurerm_application_insights.appinsights.connection_string
  sensitive = true
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.workspace.id
}
EOF

# Root Module Files
write_file "main.tf" << 'EOF'
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
  source                       = "./modules/container-apps"
  environment_name             = var.environment_name
  app_name                     = var.app_name
  resource_group_name         = azurerm_resource_group.rg.name
  location                     = var.location
  log_analytics_workspace_id   = module.monitoring.workspace_id
  container_image             = "${module.acr.acr_login_server}/${var.container_image}"
  mongodb_connection_string    = module.cosmos_db.cosmos_db_connection_string
  appinsights_connection_string = module.monitoring.appinsights_connection_string
  cpu_cores                   = var.cpu_cores
  memory_size                 = var.memory_size
  min_replicas               = var.min_replicas
  max_replicas               = var.max_replicas
  tags                        = var.tags
}
EOF

write_file "variables.tf" << 'EOF'
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry name"
  type        = string
}

variable "cosmos_db_name" {
  description = "Cosmos DB account name"
  type        = string
}

variable "workspace_name" {
  description = "Log Analytics workspace name"
  type        = string
}

variable "appinsights_name" {
  description = "Application Insights name"
  type        = string
}

variable "environment_name" {
  description = "Container Apps Environment name"
  type        = string
}

variable "app_name" {
  description = "Container App name"
  type        = string
}

variable "container_image" {
  description = "Container image name and tag"
  type        = string
}

variable "cpu_cores" {
  description = "CPU cores for Container App"
  type        = number
}

variable "memory_size" {
  description = "Memory size for Container App"
  type        = string
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
EOF

write_file "outputs.tf" << 'EOF'
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
EOF

write_file "providers.tf" << 'EOF'
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
EOF

# Environment Files
write_file "environments/dev/terraform.tfvars" << 'EOF'
environment         = "dev"
location            = "eastus"
resource_group_name = "rg-devops-dev"
acr_name           = "acrdevopsdev"
cosmos_db_name     = "cosmos-devops-dev"
workspace_name     = "log-devops-dev"
appinsights_name   = "appins-devops-dev"
environment_name   = "env-devops-dev"
app_name           = "app-devops-dev"
container_image    = "demo-app:latest"
cpu_cores          = 0.5
memory_size        = "1Gi"
min_replicas       = 1
max_replicas       = 3

tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  Project     = "DevOpsDemo"
}
EOF

write_file "environments/prod/terraform.tfvars" << 'EOF'
environment         = "prod"
location            = "eastus"
resource_group_name = "rg-devops-prod"
acr_name           = "acrdevopsprod"
cosmos_db_name     = "cosmos-devops-prod"
workspace_name     = "log-devops-prod"
appinsights_name   = "appins-devops-prod"
environment_name   = "env-devops-prod"
app_name           = "app-devops-prod"
container_image    = "demo-app:latest"
cpu_cores          = 1.0
memory_size        = "2Gi"
min_replicas       = 2
max_replicas       = 5

tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  Project     = "DevOpsDemo"
}
EOF

echo "All Terraform files have been populated successfully!"
