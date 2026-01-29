# Module 1: Mastering Terraform (Infrastructure as Code)

Welcome to your first step toward becoming a Cloud Infrastructure Expert. Terraform is the industry-standard tool for **Infrastructure as Code (IaC)**.

## 1. What is Terraform?
Instead of clicking buttons in the Azure Portal, you write code that describes what you want. This code is:
- **Declarative**: You say "I want a database," and Terraform figures out how to make it happen.
- **Version Controlled**: You can save it in Git and see exactly who changed what and when.
- **Reproducible**: You can deploy the exact same environment to "Dev," "Staging," and "Production" with minimal changes.

## 2. The Core Building Blocks

### A. Providers
Providers are plugins that tell Terraform how to talk to a specific cloud (like Azure, AWS, or GCP).
- **In your code**: See [providers.tf](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/providers.tf). It tells Terraform to use the `azurerm` provider.

### B. Resources
Resources are the "things" you are building—a Virtual Machine, a Database, or a Network.
- **Syntax**: `resource "type" "local_name" { ... }`
- **In your code**: Look at [webapp.tf](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/webapp.tf):
  ```hcl
  resource "azurerm_linux_web_app" "frontend" {
    name = var.webapp_name
    ...
  }
  ```

### C. Variables
Variables allow you to avoid hard-coding values, making your code flexible.
- **In your code**: See [variables.tf](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/variables.tf). For example, the `location` variable defaults to `uksouth`.

### D. The State File
This is the most critical part of Terraform. It keeps a record of everything it created in a file called `terraform.tfstate`. 
- **Expert Tip**: Never edit this file manually. It is Terraform's "memory."

## 3. The Lifecycle (How to run it)

To be an expert, you must master these four commands:

1.  `terraform init`: Downloads the providers (run this first).
2.  `terraform plan`: Shows you a "preview" of what will happen. **Always run this before applying.**
3.  `terraform apply`: Actually builds the resources in Azure.
4.  `terraform destroy`: Deletes everything.

## 4. Deep Dive: How your code is connected

Your infrastructure is not just a list of files; it's a web of dependencies.

1.  **The Resource Group**: Defined in `main.tf`. Almost every other file starts by referencing `azurerm_resource_group.scm.name`. This ensures everything is placed in the same "folder" in Azure.
2.  **The Registry Connection**: In `aks.tf`, there is a `azurerm_role_assignment`. This is advanced! It tells Azure: "Give this specific Kubernetes cluster permission to pull images from this specific Container Registry."

## 5. Knowledge Check: Try this!
Open your terminal in the `deployment/terraform` directory and run:
```bash
terraform plan
```
Read the output carefully. Does it say "No changes are needed" or does it want to create something? Understanding the `plan` output is the difference between a beginner and an expert.

---
**Next Module**: [Module 2: Containerization & ACR](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/learning/LEARNING_CONTAINERS.md)
