#!/bin/bash
set -e # Exit on error

# Get the directory of the script and then the repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
RESOURCE_GROUP="scm-rg"
ACR_NAME="asescmacr"
AKS_CLUSTER="scm-aks"
IMAGE_NAME="scm-backend"
TAG="latest"
NAMESPACE="scm-app"

# 0. Azure Login / ACR Login
echo "Logging into Azure Container Registry..."
az acr login --name $ACR_NAME

# 1. Build Docker Image
echo "Building Docker image..."
cd "$REPO_ROOT/scm_backend"
docker build --platform=linux/amd64 -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG .

# 2. Push to ACR
echo "Pushing image to ACR..."
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG

# 3. Connect to AKS
echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --overwrite-existing

# 4. Deploy to AKS
echo "Ensuring namespace $NAMESPACE exists..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying manifests to AKS..."
cd "$REPO_ROOT"
kubectl apply -f deployment/scm-k8s/ -n $NAMESPACE

echo "Restarting deployments to pull new image..."
kubectl rollout restart deployment/django-api -n $NAMESPACE
kubectl rollout restart deployment/celery-worker -n $NAMESPACE
kubectl rollout restart deployment/celery-beat -n $NAMESPACE

echo "Backend Deployment complete!"
