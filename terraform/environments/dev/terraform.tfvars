environment         = "dev"
location            = "eastus"
resource_group_name = "rg-devops-dev"
acr_name            = "acrdevopsdev"
cosmos_db_name      = "cosmos-devops-dev"
workspace_name      = "log-devops-dev"
appinsights_name    = "appins-devops-dev"
environment_name    = "env-devops-dev"
app_name            = "app-devops-dev"
container_image     = "demo-app:latest"
cpu_cores           = 0.5
memory_size         = "1Gi"
min_replicas        = 1
max_replicas        = 3

tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  Project     = "DevOpsDemo"
}
