output "cosmos_db_connection_string" {
  value     = azurerm_cosmosdb_account.db.connection_strings[0]
  sensitive = true
}

output "cosmos_db_endpoint" {
  value = azurerm_cosmosdb_account.db.endpoint
}
