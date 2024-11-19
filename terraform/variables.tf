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
