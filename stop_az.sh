#!/usr/bin/env bash
set -e

RG="scm-rg"
AKS_NAME="scm-aks"
WEBAPP_NAME="ase-scm"
PG_NAME="scm-postgres"      # flexible-server name

echo "Stopping App Service: $WEBAPP_NAME"
az webapp stop --name "$WEBAPP_NAME" --resource-group "$RG" || echo "Webapp stop failed/ not found"

echo "Stopping AKS: $AKS_NAME"
az aks stop --name "$AKS_NAME" --resource-group "$RG" || echo "AKS stop failed / not supported"

echo "Stopping Postgres flexible server: $PG_NAME"
az postgres flexible-server stop --name "$PG_NAME" --resource-group "$RG" || echo "Postgres stop failed / maybe not flexible-server?"

echo "Stopping all VMs in RG (if any)"
for vm in $(az vm list --resource-group "$RG" --query "[].name" -o tsv); do
  echo "Deallocating VM: $vm"
  az vm deallocate --name "$vm" --resource-group "$RG" || echo "Failed to deallocate $vm"
done

echo "Done."