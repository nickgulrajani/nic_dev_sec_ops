# modules/container-apps/main.tf
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

  registry {
    server               = var.acr_server
    username            = var.acr_username
    password_secret_name = "registry-password"
  }

  secret {
    name  = "registry-password"
    value = var.acr_password
  }

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