#!/usr/bin/env bash
set -e

RG="scm-rg"

echo "=============================================="
echo " Checking resource status in Resource Group: $RG"
echo "=============================================="
echo ""

#############################################
# 1. APP SERVICES
#############################################
echo "== App Services (Web Apps) =="
APPS=$(az webapp list --resource-group $RG --query "[].name" -o tsv)

if [ -z "$APPS" ]; then
  echo "No App Services found."
else
  for app in $APPS; do
    state=$(az webapp show --name "$app" --resource-group $RG --query "state" -o tsv)
    url=$(az webapp show --name "$app" --resource-group $RG --query "defaultHostName" -o tsv)
    echo "- $app : $state | URL: https://$url"
  done
fi
echo ""

#############################################
# 2. AKS CLUSTERS
#############################################
echo "== AKS Clusters =="
AKS=$(az aks list --resource-group $RG --query "[].name" -o tsv)

if [ -z "$AKS" ]; then
  echo "No AKS clusters found."
else
  for aks in $AKS; do
    state=$(az aks show --name "$aks" --resource-group $RG --query "powerState.code" -o tsv)
    echo "- $aks : $state"
  done
fi
echo ""

#############################################
# 3. POSTGRES FLEXIBLE SERVERS
#############################################
echo "== Postgres Flexible Servers =="
PGS=$(az postgres flexible-server list --resource-group $RG --query "[].name" -o tsv)

if [ -z "$PGS" ]; then
  echo "No Postgres Flexible Servers."
else
  for pg in $PGS; do
    state=$(az postgres flexible-server show --name "$pg" --resource-group $RG --query "state" -o tsv)
    tier=$(az postgres flexible-server show --name "$pg" --resource-group $RG --query "sku.tier" -o tsv)
    echo "- $pg : $state | Tier: $tier"
  done
fi
echo ""

#############################################
# 4. VIRTUAL MACHINES
#############################################
echo "== Virtual Machines =="
VMS=$(az vm list --resource-group $RG --query "[].name" -o tsv)

if [ -z "$VMS" ]; then
  echo "No VMs found."
else
  for vm in $VMS; do
    power=$(az vm get-instance-view --name "$vm" --resource-group $RG --query "instanceView.statuses[?starts_with(code, 'PowerState')].displayStatus" -o tsv)
    echo "- $vm : $power"
  done
fi
echo ""

#############################################
# 5. REDIS
#############################################
echo "== Azure Cache for Redis =="
REDIS=$(az redis list --resource-group $RG --query "[].name" -o tsv)

if [ -z "$REDIS" ]; then
  echo "No Redis instances found."
else
  for r in $REDIS; do
    status=$(az redis show --name "$r" --resource-group $RG --query "provisioningState" -o tsv)
    tier=$(az redis show --name "$r" --resource-group $RG --query "sku.name" -o tsv)
    echo "- $r : $status | Tier: $tier"
  done
fi
echo ""

#############################################
# 6. STORAGE ACCOUNTS
#############################################
echo "== Storage Accounts =="
STOR=$(az storage account list --resource-group $RG --query "[].name" -o tsv)

if [ -z "$STOR" ]; then
  echo "No storage accounts found."
else
  for s in $STOR; do
    kind=$(az storage account show --name "$s" --resource-group $RG --query "kind" -o tsv)
    echo "- $s : $kind"
  done
fi
echo ""

#############################################
# 7. Containers / Container Instances
#############################################
echo "== Azure Container Instances =="
ACI=$(az container list --resource-group $RG --query "[].name" -o tsv)

if [ -z "$ACI" ]; then
  echo "No container instances found."
else
  for c in $ACI; do
    state=$(az container show --name "$c" --resource-group $RG --query "instanceView.state" -o tsv)
    echo "- $c : $state"
  done
fi
echo ""

#############################################
# 8. PUBLIC IPS
#############################################
echo "== Public IP Addresses =="
IPS=$(az network public-ip list --resource-group $RG --query "[].ipAddress" -o tsv)

if [ -z "$IPS" ]; then
  echo "No Public IPs."
else
  for ip in $IPS; do
    echo "- $ip"
  done
fi
echo ""

echo "=============================================="
echo " DONE — Status report complete."
echo "=============================================="
