# Cost Optimization Plan (Azure Student Edition)

Since you are on the **Azure Student Plan**, your goal is to maximize the $100 credit and utilize "Always Free" services.

## Current Monthly Cost Estimate (Consolidated)
| Resource | SKU | Approx Cost | Status |
| :--- | :--- | :--- | :--- |
| **Frontend** | App Service (F1) | **Free** | Optimized. |
| **Backend Compute** | AKS (Standard_B2s Node) | ~$30/mo | **Main Expense.** Pays for all containers. |
| **Database** | Containerized Postgres | **Free** | Hosted on AKS (Shared resources). |
| **Cache** | Containerized Redis | **Free** | Hosted on AKS (Shared resources). |
| **Registry** | ACR (Basic) | ~$5/mo | Required for storage. |
| **Total** | | **~$35/mo** | **(Achieved Savings: ~$29/mo)** |

---

## ✅ Phase 1: Consolidation (Completed)
We have successfully implemented **Strategy 2**.
1.  **Removed Managed Redis**: Deleted `azurerm_redis_cache` (~$16/mo saving).
2.  **Removed Managed Postgres**: Deleted `azurerm_postgresql_flexible_server` (~$13/mo saving).
3.  **Containerized Everything**: Both services now run as replicas inside your AKS node, sharing the compute power you already pay for.
4.  **Persistence**: Data is saved on a Persistent Volume (Azure Disk), so it survives pod restarts.

## 🚀 Strategy: "Serverless" Migration (Future Growth)
*Effort: High | Potential Savings: Additional ~$30/mo*

If you want to reach **$0/mo** (leaving the cluster behind), the next move is to exit the "Always-On" VM model.
1.  **Drop AKS**: Kubernetes requires a running VM node that costs $30/mo regardless of traffic.
2.  **Adopt Azure Container Apps (ACA)**:
    *   ACA allows "Scale to Zero" (pay $0 when no traffic).
    *   **Student Free Grant**: First 180,000 vCPU-seconds per month are FREE.
3.  **Database**: If you leave AKS, you would need a small VM for Postgres or use a free tier hosted DB service (like Neon.tech or similar).

## Operational Best Practices
1.  **Aggressive Pausing**: Use `./deployment/terraform/manage_az_resources.sh stop` whenever you aren't actively developing. This stops the AKS VM billing.
2.  **Data Safety**: The database is stored in an Azure Disk. Do not delete the `PersistentVolumeClaim` manually unless you want to wipe the DB.
3.  **Monitoring**: Use `kubectl get pods -n scm-app` to ensure your containers are healthy.
