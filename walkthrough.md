# SCM Infrastructure & Deployment: Comprehensive Walkthrough

This guide provides detailed steps for the infrastructure setup, configuration, deployment, and ongoing maintenance of the **Sustainable City Management (SCM)** project on Azure.

---

## 🏗️ Part 1: Infrastructure Provisioning (Terraform)

The core infrastructure is managed using Terraform in the `deployment/terraform` directory.

### Components Provisioned:
- **Resource Group:** `scm-rg` (UK South)
- **AKS Cluster:** `scm-aks` (vNet integrated)
- **PostgreSQL:** Flexible Server `scm-postgres-server`
- **Redis:** `scm-redis-cache`
- **ACR:** `asescmacr`
- **App Service:** `scm-frontend-webapp` (Linux, Node 20 LTS)

### Initialization & Deployment:
```bash
cd deployment/terraform
terraform init
terraform plan
terraform apply
```

---

## ⚙️ Part 2: Cluster Setup & Configuration

After the infrastructure reaches a "Successful" state, perform these one-time configuration steps.

### 1. Connect to your AKS Cluster
```bash
az aks get-credentials --resource-group scm-rg --name scm-aks
```

### 2. Install Ingress & Cert Manager
```bash
# Add Helm repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install Nginx Ingress
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# Install Cert Manager (for SSL)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
```

### 3. Application Secrets
Create the following secrets in the `scm-app` namespace:
```bash
# Create Namespace
kubectl create namespace scm-app

# Django Secret Key
kubectl create secret generic django-secret -n scm-app \
  --from-literal=DJANGO_SECRET_KEY="your-secret-key"

# Database & Redis Credentials
kubectl create secret generic scm-db-secret -n scm-app \
  --from-literal=DB_HOST="scm-postgres-server.postgres.database.azure.com" \
  --from-literal=DB_NAME="scm" \
  --from-literal=DB_USER="scmadmin" \
  --from-literal=DB_PASSWORD="Password@123" \
  --from-literal=DB_PORT="5432" \
  --from-literal=DB_SSLMODE="require" \
  --from-literal=REDIS_URL="redis://:password@scm-redis-cache.redis.cache.windows.net:6380/0"
```

---

## 🚀 Part 3: Deployment Scripts

We use custom scripts for fast, manual deployments from a local machine.

### 1. Backend (Django to AKS)
Builds, pushes, and updates the Kubernetes deployment.
```bash
./deploy_backend_manual.sh
```

### 2. Frontend (React to App Service)
Optimized build that excludes `node_modules` for fast upload.
```bash
./deploy_frontend_manual.sh
```

---

## 🛠️ Part 4: Critical Troubleshooting & Maintenance

### 🔓 1. Network Access (NSG)
By default, AKS might block external traffic to the Ingress. Use this to open ports 80/443:
```bash
az network nsg rule create \
  --resource-group MC_scm-rg_scm-aks_uksouth \
  --nsg-name aks-agentpool-23497160-nsg \
  --name AllowHTTP \
  --priority 1001 \
  --destination-port-ranges 80 443 \
  --access Allow --protocol Tcp
```

### 🗄️ 2. Database Migration Fixes
If you see "Table does not exist" but migrations show as applied, run this sequence:
```bash
# 1. Reset migration history for core apps
kubectl exec -n scm-app deploy/django-api -- sh -c "python manage.py migrate --fake sessions zero && python manage.py migrate --fake auth zero && python manage.py migrate --fake admin zero && python manage.py migrate --fake contenttypes zero"

# 2. Re-apply migrations properly
kubectl exec -n scm-app deploy/django-api -- python manage.py migrate --fake-initial
```

### 👤 3. Admin & User Management
**Reset Admin Password:**
```bash
kubectl exec -n scm-app deploy/django-api -- sh -c "echo \"from django.contrib.auth import get_user_model; User = get_user_model(); u = User.objects.get(username='admin'); u.set_password('Password@123'); u.save()\" | python manage.py shell"
```

**Import Static Users (`analyst`, `manager`, `provider`):**
```bash
# 1. Ensure create_users.py is present
# 2. Copy to pod
kubectl cp create_users.py scm-app/$(kubectl get pod -n scm-app -l app=django-api -o jsonpath='{.items[0].metadata.name}'):/app/create_users.py

# 3. Import via shell
kubectl exec -n scm-app deploy/django-api -- python manage.py shell -c "import create_users"
```

---

## 💰 Part 5: Utility Scripts (Resource Management)

To manage costs while not developing, use these commands:

### 🔻 Stop Resources (Save Money)
Stops the App Service, AKS Cluster, and Postgres Server.
```bash
./deployment/stop_az.sh
```

### 🔼 Start Resources (Resume Work)
Restarts all components. Wait ~5-10 mins for full availability.
```bash
./deployment/start_az.sh
```

---

## 🌐 Summary of URLs
- **Frontend App:** [https://scm-frontend-webapp.azurewebsites.net](https://scm-frontend-webapp.azurewebsites.net)
- **Backend API:** [https://albinbinu.dev](https://albinbinu.dev)
- **Django Admin:** [https://albinbinu.dev/admin/](https://albinbinu.dev/admin/)