# Sustainable City Management (SCM) - Deployment & Infrastructure

This repository contains the full deployment and infrastructure code for the **Sustainable City Management (SCM)** project. It utilizes a hybrid cloud architecture on Azure, combining **Kubernetes (AKS)** for the backend processing and **Azure App Service** for the frontend hosting, optimized for cost-effectiveness on the Azure Student Plan.

---

## 📚 Prerequisites: Learning Path
To understand and manage this repository, it is helpful to be familiar with the following topics:
- **Cloud Computing (Azure)**: Basics of Resource Groups, Virtual Machines, and Networking.
- **Infrastructure as Code (IaC)**: Using **Terraform** to provision and manage cloud resources.
- **Containerization**: **Docker** for packaging applications into images.
- **Container Orchestration**: **Kubernetes (AKS)** concepts like Pods, Deployments, Services, and StatefulSets.
- **Web Server & Routing**: **Nginx** and **Ingress Controllers** for traffic management.
- **TLS/SSL**: Managing certificates with `cert-manager`.
- **Database Management**: Running PostgreSQL in containerized environments with Persistence (PVCs).
- **Asynchronous Tasks**: Using **Redis** and **Celery** for background processing.

---

## 🏗️ Architecture Overview
The system is divided into three main components:
1.  **Frontend**: A React application hosted on **Azure App Service (Linux)**.
2.  **Backend API**: A Django application running inside **Azure Kubernetes Service (AKS)**.
3.  **Data Tier**: Containerized **PostgreSQL** and **Redis** instances also running within **AKS** to minimize managed service costs.

### Resource Map
- **Terraform** (`deployment/terraform`): Defines the Azure infrastructure.
- **Kubernetes** (`deployment/scm-k8s`): Defines the deployment manifests (Pods, Secrets, Ingress).
- **Scripts** (`deployment/`): Manual automation for deployment and resource management.

---

## 🚀 Implementation Flow

### 1. Infrastructure Provisioning
We use Terraform to define exactly what resources exist in Azure.
- **Location**: `deployment/terraform`
- **Action**: Run `terraform apply` to create the Resource Group, AKS Cluster, Container Registry (ACR), and App Service.

### 2. Cluster Setup
Once the cluster is up, we configure the "environment":
- **Ingress-Nginx**: The entry point for all web traffic to the backend.
- **Cert-Manager**: Automatically issues SSL certificates via Let's Encrypt.
- **Secrets**: Encrypted environment variables (`scm-db-secret`, `django-secret`) are applied to the `scm-app` namespace.

### 3. Application Deployment
- **Backend**: The `deploy_backend_manual.sh` script builds the Docker image, pushes it to ACR, and prompts AKS to pull the latest version and restart the API pods.
- **Frontend**: The `deploy_frontend_manual.sh` script bundles the React app and deploys it to the App Service using Zip Deploy.

---

## 🛠️ Issues Encountered & Fixes

| Issue | Root Cause | Resolution |
| :--- | :--- | :--- |
| **High Redis Costs** | Initial setup used Azure Managed Redis (~$16/mo). | **Consolidated**: Moved Redis into a container inside AKS. |
| **Postgres Start Failure** | Azure Disk root contains a `lost+found` folder; Postgres `initdb` requires an empty dir. | **subPath**: Updated `postgres.yaml` to mount into a `postgres/` sub-folder. |
| **Migration Desync** | Local vs Remote migration history mismatch. | **Fake Reset**: Ran `python manage.py migrate --fake` to align histories. |
| **Redis "Cooked"** | Hardcoded/Old connection strings in manifests. | **Environment variables**: Centralized credentials into a Kubernetes Secret. |
| **Script Path Confusion** | Deployment scripts were scattered in the root folder. | **Reorganization**: Moved everything into `deployment/` with robust `REPO_ROOT` detection. |

---

## 💻 Essential Commands

### Resource Management
Save your Azure credits by stopping the cluster when not in use:
```bash
# Start/Stop whole environment
./deployment/terraform/manage_az_resources.sh start
./deployment/terraform/manage_az_resources.sh stop
```

### Database Operations
```bash
# Apply Migrations
./deployment/manage_db.sh migrate  # (Or use the kubectl exec command in COMMANDS.md)

# Create Bulk Users
kubectl exec -n scm-app -it $(kubectl get pods -l app=django-api -n scm-app -o name) -- python -c "$(cat deployment/create_users.py)"
```

### Debugging & Logs
```bash
# Backend Logs
kubectl logs -f -l app=django-api -n scm-app

# Nginx/Ingress Logs
kubectl logs -f -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx

# Frontend Logs
az webapp log tail --resource-group scm-rg --name scm-frontend-webapp
```

---

## 📝 Detailed Deployment Outline

1.  **Configure Terraform**: Set your variables in `terraform.tfvars`.
2.  **Apply Infrastructure**: Run `terraform apply` in `deployment/terraform`.
3.  **Get Credentials**: `az aks get-credentials --resource-group scm-rg --name scm-aks`.
4.  **Install Base Cluster Dependencies**: (Ingress, Cert-Manager) as outlined in `walkthrough.md`.
5.  **Apply K8s Manifests**: `kubectl apply -f deployment/scm-k8s/`.
6.  **Run Initial Migration**: Ensure database schema is ready.
7.  **Deploy Code**: Run the manual deployment scripts for Frontend and Backend.
8.  **Verify**: Log in to the application and check service status via `kubectl get pods -n scm-app`.

---
*For a more technical dive into the cost strategies, refer to [cost_optimization_plan.md](deployment/cost_optimization_plan.md).*
