#!/bin/bash

# Configuration - Variables must match terraform.tfvars
RESOURCE_GROUP="scm-rg"
AKS_CLUSTER="scm-aks"
POSTGRES_SERVER="scm-postgres-server"
WEBAPP_NAME="scm-frontend-webapp"
WEBAPP_NAME="scm-frontend-webapp"
# Redis name for reference, but it cannot be paused.
# REDIS_NAME="scm-redis-cache"

echo "Stopping Azure Resources in $RESOURCE_GROUP..."

# 1. Stop AKS Cluster
echo "Stopping AKS Cluster: $AKS_CLUSTER..."
az aks stop --name $AKS_CLUSTER --resource-group $RESOURCE_GROUP

# 2. Stop PostgreSQL Flexible Server
echo "Stopping PostgreSQL Flexible Server: $POSTGRES_SERVER..."
az postgres flexible-server stop --name $POSTGRES_SERVER --resource-group $RESOURCE_GROUP

# 3. Stop Web App
# Note: This stops the app from running, but the App Service Plan (B1/F1) may still exist.
# For F1, there is no hourly cost, but for B1 there is.
echo "Stopping Web App: $WEBAPP_NAME..."
az webapp stop --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP

# Note on Redis:
# Azure Cache for Redis (Basic Tier) does NOT support a "stop" or "pause" state. 
# It runs on dedicated VMs and is billed while it exists. 
# To stop paying for Redis, you must delete it (terraform destroy -target=azurerm_redis_cache.redis), 
# but you will lose data and have to recreate it.

echo "Resources stopped."
