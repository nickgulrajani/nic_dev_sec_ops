# modules/container-apps/variables.tf
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

variable "acr_id" {
  description = "Azure Container Registry ID"
  type        = string
}

variable "acr_server" {
  description = "Azure Container Registry server URL"
  type        = string
}

variable "acr_username" {
  description = "ACR admin username"
  type        = string
}

variable "acr_password" {
  description = "ACR admin password"
  type        = string
  sensitive   = true
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
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}