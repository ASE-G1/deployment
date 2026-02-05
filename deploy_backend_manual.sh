# Get the directory of the script and then the repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Configuration
RESOURCE_GROUP="scm-rg"
ACR_NAME="asescmacr"
AKS_CLUSTER="scm-aks"
IMAGE_NAME="scm-backend"
TAG="latest"

# 1. Build Docker Image
echo "Building Docker image..."
cd scm_backend
docker build --platform=linux/amd64 -t $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG .
cd "$REPO_ROOT"

# 2. Push to ACR
echo "Pushing image to ACR..."
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:$TAG

# 3. Connect to AKS
echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --overwrite-existing

# 4. Deploy to AKS
echo "Deploying to AKS..."
# Restart deployments to pull new image
kubectl rollout restart deployment/django-api -n scm-app
kubectl rollout restart deployment/celery-worker -n scm-app
kubectl rollout restart deployment/celery-beat -n scm-app

# Apply manifests (idempotent)
kubectl apply -f deployment/scm-k8s/

echo "Backend Deployment complete!"
