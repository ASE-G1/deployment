# Module 4: Managed Data Services (Postgres & Redis)

Your apps are "stateless"—meaning if they restart, they forget everything. To keep data safe, we use dedicated services: **PostgreSQL** for your database and **Redis** for your cache.

## 1. Why "Flexible Server"?
In your code ([postgres.tf](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/postgres.tf)), you are using `azurerm_postgresql_flexible_server`. 
- **Freedom**: It gives you better control over updates and maintenance windows.
- **Savings**: You can "stop" a Flexible Server to save money when you aren't developing. Single servers don't always support this.

## 2. Managing Access (The Firewall)
Azure databases are locked down by default. Nothing can talk to them unless you open a "hole" in the firewall.
- **Critical lines in `postgres.tf`**:
  - `start_ip_address = "0.0.0.0"` and `end_ip_address = "0.0.0.0"`: This is a special Azure rule that allows *other Azure services* (like your AKS cluster or Web App) to connect.
  - `allow_all` (0.0.0.0 to 255.255.255.255): This is for development ease, allowing your local computer to connect. 
  - **Expert Warning**: In a real production environment, you should only whitelist specific IPs or use a "VNet" to keep the database completely off the public internet.

## 3. Redis: The "Flash Module"
Redis is an in-memory database. It is incredibly fast.
- **Purpose**: It stores session data or temporary calculations so the main database doesn't get overwhelmed.
- **In your code**: [redis.tf](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/redis.tf) sets up a `Basic` SKU. This is the cheapest option and is perfect for dev environments.

## 4. Expert Insight: SSL
Look at [redis.tf](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/redis.tf), line 8: `enable_non_ssl_port = false`.
- This means your app MUST connect using an encrypted connection (SSL/TLS). This is a security best practice that you've already implemented!

---
**Next Module**: [Module 5: Automation & Maintenance](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/learning/LEARNING_AUTOMATION.md)
