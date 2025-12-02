#!/usr/bin/env bash
set -e

RG="scm-rg"
AKS_NAME="scm-aks"
WEBAPP_NAME="ase-scm"
PG_NAME="scm-postgres"      # flexible-server name

echo "Starting Postgres flexible server: $PG_NAME"
az postgres flexible-server start --name "$PG_NAME" --resource-group "$RG" || echo "Postgres start failed / maybe not flexible-server?"

echo "Starting AKS: $AKS_NAME"
az aks start --name "$AKS_NAME" --resource-group "$RG" || echo "AKS start failed / not supported"

echo "Starting App Service: $WEBAPP_NAME"
az webapp start --name "$WEBAPP_NAME" --resource-group "$RG" || echo "Webapp start failed / not found"

echo "Starting all VMs in RG (if any)"
for vm in $(az vm list --resource-group "$RG" --query "[].name" -o tsv); do
  echo "Starting VM: $vm"
  az vm start --name "$vm" --resource-group "$RG" || echo "Failed to start $vm"
done

echo "Done."
