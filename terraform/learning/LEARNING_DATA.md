# Module 4: Containerized Data Services (Postgres & Redis)

Your apps are "stateless"—meaning if they restart, they forget everything. To keep data safe and accessible, we use **PostgreSQL** for your database and **Redis** for your cache.

## 1. Why Containerized on AKS?
Previously, we used managed services (`azurerm_postgresql_flexible_server` and `azurerm_redis_cache`). However, to optimize costs in a development environment, we've moved these services inside your **AKS cluster**.

- **Cost Efficiency**: You don't pay for separate server instances; they share the resources of your AKS nodes.
- **Unified Management**: When you stop your AKS cluster using `manage_az_resources.sh stop`, your database and cache stop automatically, saving you money.
- **Portability**: The configuration is defined in Kubernetes YAML files, making it easy to move between clusters.

## 2. Managing Data in Kubernetes
In Kubernetes, data is handled using **Persistent Volumes**. Even if a Postgres "Pod" restarts, the data remains safe on a managed disk attached to the cluster.

- **Check your cluster**: You can see these services running by using:
  ```bash
  kubectl get pods -n scm-app
  ```
- **Internal Access**: Other apps in the cluster (like the backend) connect to `postgres-service` and `redis-service` using internal DNS, keeping the traffic off the public internet.

## 3. Redis: The "Flash Module"
Redis is an in-memory database. It is incredibly fast.
- **Purpose**: It stores session data or temporary calculations so the main database doesn't get overwhelmed.
- **In your setup**: It runs as a lightweight pod, providing high performance without the cost of a managed Azure cache.

## 4. Expert Insight: Security
Even though these services are inside the cluster, we still protect them:
- **Secrets**: Passwords and connection strings are stored as **Kubernetes Secrets**, not in plain text in your code.
- **Network Policies**: You can restrict access so only the backend pod is allowed to talk to the database.

---
**Next Module**: [Module 5: Automation & Maintenance](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/learning/LEARNING_AUTOMATION.md)


---
**Next Module**: [Module 5: Automation & Maintenance](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/learning/LEARNING_AUTOMATION.md)
