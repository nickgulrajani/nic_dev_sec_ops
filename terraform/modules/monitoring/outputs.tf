output "appinsights_connection_string" {
  value     = azurerm_application_insights.appinsights.connection_string
  sensitive = true
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.workspace.id
}
