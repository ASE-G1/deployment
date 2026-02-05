# Get the directory of the script and then the repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Configuration
RESOURCE_GROUP="scm-rg"
WEBAPP_NAME="scm-frontend-webapp"

echo "Starting Manual Frontend Deployment..."

# 1. Build
echo "Installing dependencies and building..."
cd scm_frontend
npm install
npm run build

# 2. Package
echo "Creating optimized deployment package..."
rm -rf deploy_temp
mkdir -p deploy_temp
cp -r build deploy_temp/
cp server.js deploy_temp/

# Create a minimal package.json for production server
echo '{
  "name": "scm-frontend-prod",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}' > deploy_temp/package.json

echo "Installing production dependencies..."
cd deploy_temp
npm install --production --no-package-lock

echo "Zipping (including node_modules)..."
zip -qr ../release_frontend.zip .
cd ../scm_frontend

# 3. Deploy
echo "Deploying to Azure App Service ($WEBAPP_NAME)..."

echo "Configuring App Settings (Disable Remote Build)..."
az webapp config appsettings set --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --settings SCM_DO_BUILD_DURING_DEPLOYMENT=false
az webapp config appsettings delete --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --setting-names WEBSITES_PORT

echo "Configuring startup command and runtime..."
az webapp config set --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --startup-file "node server.js" --linux-fx-version "NODE|20-lts"

echo "Waiting 20 seconds for App Service to restart..."
sleep 20

cd "$REPO_ROOT"
az webapp deploy \
  --resource-group $RESOURCE_GROUP \
  --name $WEBAPP_NAME \
  --src-path release_frontend.zip \
  --type zip

echo "Deployment completed!"
echo "You can access the frontend at: https://$WEBAPP_NAME.azurewebsites.net"

echo "Waiting 20 seconds for App Service to restart..."
sleep 20

cd ..
az webapp deploy \
  --resource-group $RESOURCE_GROUP \
  --name $WEBAPP_NAME \
  --src-path release_frontend.zip \
  --type zip

echo "Deployment completed!"
echo "You can access the frontend at: https://$WEBAPP_NAME.azurewebsites.net"

