# Get the directory of the script and then the repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

# Configuration
RESOURCE_GROUP="scm-rg"
AKS_CLUSTER="scm-aks"
POSTGRES_SERVER="scm-postgres-server"
WEBAPP_NAME="scm-frontend-webapp"

# Redis runs on AKS now.


show_usage() {
    echo "Usage: $0 [start|stop]"
    exit 1
}

if [ "$#" -ne 1 ]; then
    show_usage
fi

ACTION=$1

if [ "$ACTION" == "start" ]; then
    echo "Starting Azure Resources in $RESOURCE_GROUP..."

    # 1. Start Multi-Agent Services (AKS)
    echo "Starting AKS Cluster: $AKS_CLUSTER..."
    az aks start --name $AKS_CLUSTER --resource-group $RESOURCE_GROUP --no-wait

    # 2. Start PostgreSQL/Redis (Containerized in AKS - auto-started with AKS)
    echo "Note: PostgreSQL and Redis are running as pods in AKS."

    # 3. Start Web App
    echo "Starting Web App: $WEBAPP_NAME..."
    az webapp start --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP

    echo "Start commands issued. It may take a few minutes for services to become fully available."

elif [ "$ACTION" == "stop" ]; then
    echo "Stopping Azure Resources in $RESOURCE_GROUP to save costs..."

    # 1. Stop Multi-Agent Services (AKS)
    echo "Stopping AKS Cluster: $AKS_CLUSTER..."
    az aks stop --name $AKS_CLUSTER --resource-group $RESOURCE_GROUP --no-wait

    # 2. Stop PostgreSQL/Redis (Containerized in AKS - auto-stopped with AKS)
    echo "Note: PostgreSQL and Redis are stopped when AKS stops."

    # 3. Stop Web App
    # Note: This stops the app from running, but the App Service Plan (B1/F1) may still exist.
    echo "Stopping Web App: $WEBAPP_NAME..."
    az webapp stop --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP

    echo "Stop commands issued."

else
    show_usage
fi
