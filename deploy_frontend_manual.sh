#!/bin/bash
set -e # Exit on error

# Get the directory of the script and then the repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
RESOURCE_GROUP="scm-rg"
WEBAPP_NAME="scm-frontend-webapp"

echo "Starting Manual Frontend Deployment..."

# Ensure the web app is started
echo "Checking if Web App is started..."
az webapp start --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME

# 1. Build
echo "Installing dependencies and building..."
cd "$REPO_ROOT/scm_frontend"
npm install
npm run build

# 2. Package
echo "Creating optimized deployment package..."
rm -rf "$REPO_ROOT/deploy_temp"
mkdir -p "$REPO_ROOT/deploy_temp"
cp -r build "$REPO_ROOT/deploy_temp/"
cp server.js "$REPO_ROOT/deploy_temp/"

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
}' > "$REPO_ROOT/deploy_temp/package.json"

echo "Installing production dependencies..."
cd "$REPO_ROOT/deploy_temp"
npm install --production --no-package-lock

echo "Zipping (including node_modules)..."
ZIP_FILE="$REPO_ROOT/release_frontend.zip"
rm -f "$ZIP_FILE"
zip -qr "$ZIP_FILE" .

# 3. Deploy
echo "Deploying to Azure App Service ($WEBAPP_NAME)..."

echo "Configuring App Settings (Disable Remote Build)..."
az webapp config appsettings set --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --settings SCM_DO_BUILD_DURING_DEPLOYMENT=false
az webapp config appsettings delete --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --setting-names WEBSITES_PORT

echo "Configuring startup command and runtime..."
az webapp config set --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --startup-file "node server.js" --linux-fx-version "NODE|20-lts"

echo "Waiting 10 seconds for App Service to stabilize..."
sleep 10

echo "Executing Zip Deploy..."
az webapp deploy \
  --resource-group $RESOURCE_GROUP \
  --name $WEBAPP_NAME \
  --src-path "$ZIP_FILE" \
  --type zip

echo "Deployment completed!"
echo "You can access the frontend at: https://$WEBAPP_NAME.azurewebsites.net"
