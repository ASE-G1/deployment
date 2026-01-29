# Module 3: Orchestration (AKS & Kubernetes)

If Docker is the "Container," Kubernetes (K8s) is the "Crane" that moves them and the "Captain" of the ship. **Azure Kubernetes Service (AKS)** is a managed version of Kubernetes that makes it easier to run.

## 1. Why Kubernetes?
If you have 10 different backend services, how do you make sure they stay running? 
- **Self-Healing**: If a container crashes, K8s restarts it automatically.
- **Scaling**: If demand goes up, K8s adds more copies (Pods) of your app.
- **Load Balancing**: It distributes traffic evenly between those copies.

## 2. Key Terms to Know
- **Pod**: The smallest unit; it's basically your running container.
- **Deployment**: A set of instructions telling K8s how many copies of a Pod to keep running.
- **Service**: A permanent "phone number" for a group of Pods so they can talk to each other.
- **Node**: The actual server (VM) that the Pods live on.

## 3. How it looks in your code
Open [aks.tf](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/aks.tf).
- `default_node_pool`: This defines the "Fleet." You are using `Standard_B2s` machines.
- `identity`: This sets up a "Service Principal" (a virtual ID card) for the cluster so it can talk to other Azure services.

## 4. Deploying to AKS
In [deploy_backend_manual.sh](file:///Users/jayanandenm/Desktop/ASE/codebase/deploy_backend_manual.sh), look at these lines:
```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER
kubectl apply -f deployment/scm-k8s/
```
- `az aks get-credentials`: This "logs you in" to the cluster.
- `kubectl apply`: This is the most powerful command in Kubernetes. It says "Here is my plan (the YAML files), make the cluster look like this."

## 5. Expert Technique: Rollout Restart
Look at line 43 of `deploy_backend_manual.sh`:
```bash
kubectl rollout restart deployment/django-api -n scm-app
```
**Why do we do this?** If you push a new image with the same tag (like `latest`), Kubernetes won't notice a change. This command forces it to replace the old containers with the new ones immediately.

---
**Next Module**: [Module 4: Managed Data Services](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/LEARNING_DATA.md)
