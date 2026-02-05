# SCM Project - Manual Operations & Commands

## 1. Resource Management
**Script:** `deployment/terraform/manage_az_resources.sh`
- **Start:** `./deployment/terraform/manage_az_resources.sh start`
- **Stop:** `./deployment/terraform/manage_az_resources.sh stop`
  > **Note:** This controls the AKS cluster (Compute) and the Web App. PostgreSQL and Redis now run as containers within AKS and will automatically start/stop with the cluster.

## 2. Deployment
- **Frontend:** `./deployment/deploy_frontend_manual.sh`
  - Deploys static files + Node server to Azure App Service (F1 Tier).
- **Backend:** `./deployment/deploy_backend_manual.sh`
  - Builds Docker image, pushes to ACR, and restarts AKS deployments.

## 3. Kubernetes Operations (Internal DB/Cache)
**Run Migrations:**
```bash
kubectl exec -n scm-app -it $(kubectl get pods -n scm-app -l app=django-api -o jsonpath='{.items[0].metadata.name}') -- python manage.py migrate
```

**Create Bulk Users:**
```bash
kubectl exec -n scm-app -it $(kubectl get pods -n scm-app -l app=django-api -o jsonpath='{.items[0].metadata.name}') -- python -c "$(cat deployment/create_users.py)"
```

**Check Service Status:**
```bash
kubectl get pods -n scm-app
```

---

## 4. Debugging & Logs

### Pod Logs (Real-time)
```bash
# General Backend API logs
kubectl logs -f -l app=django-api -n scm-app

# Database logs
kubectl logs -f postgres-0 -n scm-app

# Redis logs
kubectl logs -f -l app=redis -n scm-app
```

### Ingress & Nginx Logs
```bash
# View Nginx controller logs (for routing/SSL issues)
kubectl logs -f -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx

# Check Ingress configuration status
kubectl describe ingress scm-ingress -n scm-app
```

### Deployment Status
```bash
# Check why a deployment might be failing to rollout
kubectl rollout status deployment/django-api -n scm-app
kubectl describe deployment django-api -n scm-app
```

### Frontend Logs (Azure App Service)
```bash
az webapp log tail --resource-group scm-rg --name scm-frontend-webapp
```


