variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "scm-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "uksouth"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
  default     = "asescmacr"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "scm-aks"
}

variable "postgres_server_name" {
  description = "Name of the PostgreSQL Flexible Server (must be globally unique)"
  type        = string
  default     = "scm-postgres-server"
}

variable "postgres_admin_user" {
  description = "Admin username for PostgreSQL"
  type        = string
  default     = "scmadmin"
}

variable "postgres_admin_password" {
  description = "Admin password for PostgreSQL"
  type        = string
  sensitive   = true
}
variable "redis_name" {
  description = "Name of the Azure Cache for Redis (must be globally unique)"
  type        = string
  default     = "scm-redis-cache"
}



variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
  default     = "scm-asp"
}

variable "webapp_name" {
  description = "Name of the Web App (must be globally unique)"
  type        = string
  default     = "scm-frontend-webapp"
}
