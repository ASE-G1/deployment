#!/bin/bash

# Configuration
RESOURCE_GROUP="scm-rg"
AKS_CLUSTER="scm-aks"
POSTGRES_SERVER="scm-postgres-server"
WEBAPP_NAME="scm-frontend-webapp"
WEBAPP_NAME="scm-frontend-webapp"

echo "Starting Azure Resources in $RESOURCE_GROUP..."

# 1. Start AKS Cluster
echo "Starting AKS Cluster: $AKS_CLUSTER..."
az aks start --name $AKS_CLUSTER --resource-group $RESOURCE_GROUP

# 2. Start PostgreSQL Flexible Server
echo "Starting PostgreSQL Flexible Server: $POSTGRES_SERVER..."
az postgres flexible-server start --name $POSTGRES_SERVER --resource-group $RESOURCE_GROUP

# 3. Start Web App
echo "Starting Web App: $WEBAPP_NAME..."
az webapp start --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP

echo "Resources started. It may take a few minutes for services to become fully available."
