# SCM Deployment — Azure Infrastructure

Full deployment reference for the Sustainable City Management platform on Azure. Covers infrastructure provisioning, Kubernetes setup, application deployment, and day-to-day operations.

---

## Architecture

| Layer          | Technology    | Hosting                                          |
| -------------- | ------------- | ------------------------------------------------ |
| Frontend       | React SPA     | Azure App Service (F1 — free)                    |
| Backend        | Django + DRF  | Azure Kubernetes Service (Standard_B2s, ~$30/mo) |
| Database       | PostgreSQL    | Containerised inside AKS (free — saves ~$15/mo)  |
| Cache / Broker | Redis         | Containerised inside AKS (free — saves ~$14/mo)  |
| Image Registry | Docker images | Azure Container Registry Basic (~$5/mo)          |
| **Total**      |               | **~$35/mo**                                      |

**Why containerised Postgres and Redis?** AKS pods share the cluster compute — no extra managed service cost. Data persists via PersistentVolumeClaims. The AKS cluster can be paused when not in use to save money.

---

## Prerequisites

- Azure CLI (`az`) — logged in with `az login`
- Terraform ≥ 1.5
- `kubectl`
- Docker

---

## Phase 1 — Infrastructure (Terraform)

Provisions: Resource Group, AKS cluster, ACR, App Service.

```bash
cd deployment/terraform
terraform init
terraform plan
terraform apply
```

After apply, connect kubectl to the new cluster:

```bash
az aks get-credentials --resource-group scm-rg --name scm-aks
kubectl get nodes   # verify
```

> **Note:** Managed Azure Postgres and Redis are NOT provisioned — removed to save costs. The `scm-k8s/postgres.yaml` and `redis.yaml` manifests handle data services inside AKS instead.

---

## Phase 2 — Cluster Setup

### 1. Install Nginx Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

### 2. Install cert-manager (HTTPS / Let's Encrypt)

```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true
```

### 3. Apply Secrets

Edit `scm-k8s/secrets.yaml` with base64-encoded values, then:

```bash
kubectl apply -f deployment/scm-k8s/secrets.yaml
```

Generate base64 values:

```bash
echo -n "your-value-here" | base64
```

### 4. Deploy Data Tier (Postgres + Redis)

```bash
kubectl apply -f deployment/scm-k8s/postgres.yaml
kubectl apply -f deployment/scm-k8s/redis.yaml
kubectl get pods   # wait for both to be Running
```

> **Redis:** Use the internal Kubernetes service name `redis-service:6379` in Django settings — not an Azure URL, and no SSL for internal cluster traffic.

> **Postgres known issue:** Azure Disk creates a `lost+found` directory that blocks Postgres initialisation. Fixed via `subPath: postgres` in the volumeMount — already set in `postgres.yaml`.

### 5. Apply Ingress

```bash
kubectl apply -f deployment/scm-k8s/scm-ingress.yaml
```

---

## Phase 3 — Application Deployment

### Backend

```bash
bash deployment/deploy_backend_manual.sh
```

Builds the Django Docker image, pushes to ACR, and rolls out to AKS. After deploy, run migrations:

```bash
bash deployment/manage_db.sh migrate
```

### Frontend

```bash
bash deployment/deploy_frontend_manual.sh
```

Builds the React app and deploys to Azure App Service via Zip Deploy.

> **Race condition:** App Service takes ~20s to recycle after deploy. The script includes a sleep buffer — do not cancel early.

### Celery Workers

```bash
kubectl apply -f deployment/scm-k8s/celery-worker.yaml
kubectl apply -f deployment/scm-k8s/celery-beat.yaml
```

### Full Deploy Order (fresh cluster)

```
1. terraform apply
2. az aks get-credentials
3. Install ingress-nginx + cert-manager (helm)
4. kubectl apply -f scm-k8s/secrets.yaml
5. kubectl apply -f scm-k8s/postgres.yaml && scm-k8s/redis.yaml
6. kubectl apply -f scm-k8s/scm-ingress.yaml
7. bash deploy_backend_manual.sh
8. bash manage_db.sh migrate
9. bash deploy_frontend_manual.sh
10. kubectl apply -f scm-k8s/celery-worker.yaml && celery-beat.yaml
11. kubectl get pods -n scm-app   # verify all Running
```

---

## Day-to-Day Operations

### Start / Stop (Cost Saving)

```bash
bash deployment/terraform/manage_az_resources.sh stop    # pause everything
bash deployment/terraform/manage_az_resources.sh start   # resume
```

Pauses the AKS cluster and App Service. Postgres data is preserved by the PVC.

### Pod / Service Status

```bash
kubectl get pods -n scm-app
kubectl get services -n scm-app
kubectl get ingress -n scm-app
```

### Logs

```bash
# Backend API
kubectl logs -f -l app=django-api -n scm-app

# Celery worker
kubectl logs -f -l app=celery-worker -n scm-app

# Celery beat
kubectl logs -l app=celery-beat -n scm-app --tail=50

# Nginx ingress
kubectl logs -f -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx

# Frontend (App Service)
az webapp log tail --resource-group scm-rg --name scm-frontend-webapp
```

### Force Pod Restart

```bash
kubectl rollout restart deployment/django-api -n scm-app
kubectl rollout restart deployment/celery-worker -n scm-app
```

### Database

```bash
bash deployment/manage_db.sh migrate   # run migrations
bash deployment/manage_db.sh shell     # Django shell inside cluster
python deployment/create_users.py      # bulk user creation
```

### Verify Persistent Volume

```bash
kubectl get pvc -n scm-app
kubectl describe pvc postgres-pvc -n scm-app
```

---

## Troubleshooting

| Symptom                                 | Likely Cause                      | Fix                                                                                          |
| --------------------------------------- | --------------------------------- | -------------------------------------------------------------------------------------------- |
| Postgres pod stuck in `Init`            | `lost+found` blocks data dir      | Confirm `subPath: postgres` in `postgres.yaml`                                               |
| Redis connection refused                | Wrong hostname in Django settings | Use `redis-service:6379`, not the Azure URL                                                  |
| Migration mismatch on new pod           | Stale migration state             | Run `manage_db.sh migrate` after each backend deploy; use `--fake` if histories are desynced |
| Frontend not updating after deploy      | App Service still recycling       | Wait 30s after script finishes, then hard-refresh                                            |
| Deployment script fails with path error | Script run from wrong directory   | Scripts auto-detect `REPO_ROOT` — safe to run from any directory                             |

---

## Manifests Reference

| File                 | Purpose                                          |
| -------------------- | ------------------------------------------------ |
| `django-api.yaml`    | Backend Deployment + Service + HPA               |
| `celery-worker.yaml` | Celery async task worker pods                    |
| `celery-beat.yaml`   | Celery Beat periodic task scheduler              |
| `postgres.yaml`      | PostgreSQL StatefulSet + PVC + Service           |
| `redis.yaml`         | Redis Deployment + Service                       |
| `scm-ingress.yaml`   | Nginx Ingress + cert-manager (Let's Encrypt TLS) |
| `secrets.yaml`       | DB credentials, API keys (base64-encoded)        |

## Terraform Reference

| File           | What It Creates                                               |
| -------------- | ------------------------------------------------------------- |
| `main.tf`      | Provider config, locals                                       |
| `providers.tf` | Azure provider setup                                          |
| `variables.tf` | Region, cluster name, SKUs                                    |
| `aks.tf`       | AKS cluster + node pool                                       |
| `acr.tf`       | Container Registry + AKS pull permission via Managed Identity |
| `webapp.tf`    | App Service plan + Linux web app                              |
