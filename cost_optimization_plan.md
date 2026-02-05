# Cost Optimization Plan (Azure Student Edition)

Since you are on the **Azure Student Plan**, your goal is to maximize the $100 credit and utilize "Always Free" services.

## Current Monthly Cost Estimate (Approximate)
| Resource | SKU | Approx Cost | Notes |
| :--- | :--- | :--- | :--- |
| **Frontend** | App Service (F1) | **Free** | Correctly optimized. |
| **Backend Compute** | AKS (Standard_B2s Node) | ~$30/mo | The Cluster is free, but you pay for the VM. |
| **Database** | Postgres Flex (B1ms) | ~$13/mo | *Might* be free for first 12 months (check Azure Portal). |
| **Cache** | Redis (Basic C0) | ~$16/mo | **Most expensive relative to value.** No free tier. |
| **Registry** | ACR (Basic) | ~$5/mo | |
| **Total** | | **~$64/mo** | (Without intervention) |

---

## Strategy 1: The "Quick Fix" (Keep Architecture, Cut Inefficiency)
*Effort: Low | Savings: ~$16/mo*

1.  **Delete Managed Redis**: The Basic tier is too expensive for a student project.
    *   **Action**: Destroy `azurerm_redis_cache`.
    *   **Alternative**: Run Redis as a container inside your existing AKS cluster.
2.  **Aggressive Pausing**: Use the `manage_az_resources.sh` script I created to stop AKS and Postgres whenever you aren't working.
    *   **Savings**: If you only run usage for 40 hours/week, costs drop by ~75%.

## Strategy 2: Consolidation (Maximize Usage of Paid VM)
*Effort: Medium | Savings: ~$29/mo*

Since you are paying for the AKS Node (`Standard_B2s` has 2 vCPUs, 4GB RAM), you should put *everything* on it.
1.  **Containerize Postgres**: Stop paying for Flexible Server. Run a standard PostgreSQL container on AKS with a Persistent Volume.
2.  **Containerize Redis**: Run Redis on AKS.
3.  **Result**: You only pay for the **AKS Node (~$30)** and **ACR (~$5)**.
    *   *Total: ~$35/mo*

## Strategy 3: "Serverless" Migration (Maximum Free Tier)
*Effort: High | Savings: ~$64/mo (potentially $0)*

Move completely away from "always-on" resources (VMs) to "scale-to-zero" resources.
1.  **Drop AKS**: Kubernetes requires a running VM node.
2.  **Adopt Azure Container Apps (ACA)**:
    *   ACA allows "Scale to Zero" (pay $0 when no traffic).
    *   **Student Free Grant**: First 180,000 vCPU-seconds per month are FREE.
3.  **Database**: If your Student Subscription includes "12 months free Postgres Flexible Server", keep it. If not, use **Azure Cosmos DB for PostgreSQL** (free tier available) or a small VM.

## Recommendations
1.  **IMMEDIATE**: Delete the Azure Redis resource (`terraform destroy -target=azurerm_redis_cache.redis`). It wastes credit.
2.  **SHORT TERM**: Containerize Redis and Postgres onto your AKS cluster. (Strategy 2).
3.  **LONG TERM**: Next time you rebuild, try Azure Container Apps instead of AKS.

### Proposed Next Step
I recommend **Strategy 2 (Consolidation)** for now, starting with **removing Redis**.
Shall I generate a plan to replacing the managed Redis with a containerized Redis on AKS?
