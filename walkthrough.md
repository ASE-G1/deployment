# SCM Infrastructure & Deployment: Master Walkthrough

This guide provides the **actual** step-by-step flow of the infrastructure setup and the containerized consolidation we implemented for the **Sustainable City Management (SCM)** project.

---

## 🏗️ Phase 1: Infrastructure Provisioning (Terraform)
We use Terraform to define the managed resources in `deployment/terraform`.

1.  **Initialize**: `cd deployment/terraform && terraform init`
2.  **Provision**: Run `terraform apply` to create:
    - **Resource Group**: `scm-rg` (UK South)
    - **AKS Cluster**: `scm-aks` (vNet integrated, VM size: `Standard_B2s`)
    - **App Service**: `scm-frontend-webapp` (Free Tier F1 for the React frontend)
    - **ACR**: `asescmacr` (Container Registry)
    - *Note: Managed Postgres and Redis were removed in the optimization phase to save ~$30/mo.*

---

## ⚙️ Phase 2: Cluster Setup & Consolidation
Once the cluster is running, we configure the core services inside Kubernetes.

### 1. Ingress & Routing (`scm-ingress.yaml`)
We use the **Nginx Ingress Controller** to handle incoming traffic.
- **Host**: `albinbinu.dev`
- **Routing**: All traffic on this host is routed to the `django-service` on port 8000.
- **SSL**: Controlled via `cert-manager` using the `letsencrypt-prod` issuer.

### 2. Containerized Data Tier (The Cost Fix)
To save student credits, we moved the database and cache inside the cluster:
- **Redis**: Deployed as a `Deployment` using `redis.yaml`. Accessible internally at `redis-service:6379`.
- **PostgreSQL**: Deployed as a `StatefulSet` using `postgres.yaml`.
  - **Storage**: Uses a `PersistentVolumeClaim` (PVC) to reserve an Azure Disk.
  - **The "subPath" Fix**: We mount the volume into `/var/lib/postgresql/data` using `subPath: postgres` to avoid initialization errors caused by the default `lost+found` folder on new Azure Disks.

### 3. Application Configuration (Secrets)
Secrets are applied to the `scm-app` namespace via `scm-k8s/secrets.yaml`:
- **`scm-db-secret`**: Contains `DB_HOST` (set to `postgres-service`), credentials, and SSL disabled for internal cluster traffic.
- **`django-secret`**: Contains the `DJANGO_SECRET_KEY`.

---

## 🚀 Phase 3: Deployment & Operations

### 1. Deploying the Backend
Run `./deployment/deploy_backend_manual.sh`. This:
- Builds the `scm_backend` image.
- Pushes to ACR.
- Restarts the `django-api`, `celery-worker`, and `celery-beat` deployments.
- Re-applies the service and ingress manifests.

### 2. Deploying the Frontend
Run `./deployment/deploy_frontend_manual.sh`. This:
- Builds the React app.
- Packages it with a Node server.
- Deploys to Azure App Service via Zip Deploy with a 20s safety sleep to allow for instance recycling.

### 3. Database Initial Setup
Since the Postgres is now containerized and fresh:
1.  **Migrate**: `kubectl exec -it <django-pod> -- python manage.py migrate`
2.  **Seed Users**: `kubectl exec -it <django-pod> -- python -c "$(cat deployment/create_users.py)"`

---

## 🛠️ Lessons Learnt & Fixes
For a detailed breakdown of the technical challenges we solved (like the Postgres volume fix and Redis connection issues), see:
- [LESSONS_LEARNT.md](LESSONS_LEARNT.md)

---

## 📝 Troubleshooting Reference
- **Check Pod Status**: `kubectl get pods -n scm-app`
- **View Logs**: `kubectl logs -f <pod-name> -n scm-app`
- **Resource Management**: Use `manage_az_resources.sh` to stop the AKS Cluster and Web App when not in use to stop billing immediately.

*All detailed manual commands are located in [COMMANDS.md](COMMANDS.md).*
