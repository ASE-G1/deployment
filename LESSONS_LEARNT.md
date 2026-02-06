# SCM Project: Lessons Learnt & Key Fixes

This document tracks the technical challenges encountered during the infrastructure migration and the specific solutions implemented.

---

### 🐘 1. PostgreSQL Initialisation (The "lost+found" Error)
**Problem**: When mounting a fresh Azure Disk to a Kubernetes Pod, Azure automatically creates a `lost+found` directory in the root. PostgreSQL's `initdb` command fails if the data directory is not empty.
**Fix**: Use the `subPath` property in the `volumeMounts` section of the `postgres.yaml` manifest.
```yaml
volumeMounts:
- name: postgres-pvc
  mountPath: /var/lib/postgresql/data
  subPath: postgres # This creates a clean subfolder inside the disk
```

### 💎 2. Cost Consolidation Optimization
**Problem**: Managed services (Azure Redis & Postgres Flexible Server) have high baseline costs (~$30/mo combined) that eat into student credits even with zero traffic.
**Fix**: Terminate managed services and host them as containers within the existing AKS cluster. This leverages the compute power of the `Standard_B2s` node you are already paying for. 
**Result**: Total monthly costs dropped from ~$64/mo to ~$35/mo.

### 🌍 3. Redis Connection "Cooked" Errors
**Problem**: Hardcoded connection strings or old Azure Redis URLs caused the backend to crash with "Redis is cooked" (connection refused) errors.
**Fix**: 
- Centralized credentials into a Kubernetes Secret (`scm-db-secret`).
- Used internal Kubernetes service discovery. Instead of a long Azure URL, the backend now connects to `redis-service:6379`.
- Switched from `rediss://` (SSL) to `redis://` for internal cluster traffic to simplify configuration.

### 📁 4. Script Paths & Automation
**Problem**: Running deployment scripts from different directories (root vs deployment/) often broke relative paths to source code or manifests.
**Fix**: Added a `REPO_ROOT` detection block to the top of every `.sh` script:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)" # Adjust based on script depth
cd "$REPO_ROOT"
```
This makes the scripts robust and callable from any location.

### ⚡ 5. App Service Race Conditions
**Problem**: Using `az webapp deploy` immediately after a configuration change sometimes caused the deployment to fail because the App Service was still restarting.
**Fix**: Added a `sleep 20` buffer in `deploy_frontend_manual.sh` between configuration updates and the final zip deployment.
