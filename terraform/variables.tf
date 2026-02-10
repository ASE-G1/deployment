variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "scm-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "swedencentral"
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
