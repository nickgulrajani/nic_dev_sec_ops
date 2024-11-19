environment         = "prod"
location            = "eastus"
resource_group_name = "rg-devops-prod"
acr_name            = "acrdevopsprod"
cosmos_db_name      = "cosmos-devops-prod"
workspace_name      = "log-devops-prod"
appinsights_name    = "appins-devops-prod"
environment_name    = "env-devops-prod"
app_name            = "app-devops-prod"
container_image     = "demo-app:latest"
cpu_cores           = 1.0
memory_size         = "2Gi"
min_replicas        = 2
max_replicas        = 5

tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  Project     = "DevOpsDemo"
}
