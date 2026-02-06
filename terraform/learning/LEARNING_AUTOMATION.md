# Module 5: Automation & Professional Maintenance

The final step to being an expert is realizing that **Manual Work is the Enemy.** Experts automate everything to reduce human error.

## 1. The Power of the Azure CLI (`az`)
While Terraform builds the "house," the Azure CLI is like the "remote control." You use it for daily actions.
- **In your code**: [manage_az_resources.sh](file:///Users/jayanandenm/Desktop/ASE/codebase/deployment/terraform/manage_az_resources.sh) uses the CLI to wake up or pause your servers.

## 2. Why use Shell Scripts?
You could type `az aks stop ...` every night, but you'll eventually forget. 
- **Documented Process**: A script is a living document of how a task should be done.
- **Speed**: One command (`./manage_az_resources.sh stop`) replaces five minutes of clicking in the portal.


## 3. The "State of Reality" Check
A key expert concept is the **Reconciliation Loop**.
- Terraform creates the resource based on your code.
- If someone manually changes a setting in the Azure Portal, your Terraform code is now "diverged."
- **Expert Move**: Run `terraform plan` frequently. It will show you exactly where the Portal and your Code have drifted apart.

## 4. Professional Checklist for Every Update
1.  **Code Change**: Update your app code.
2.  **Containerize**: Build and Push the new image.
3.  **Breathe**: Run `terraform plan` to ensure your infrastructure is still healthy.
4.  **Deploy**: Use `kubectl apply` to update the cluster.
5.  **Verify**: Check the logs (`kubectl logs ...`) to ensure the app started correctly.

## Final Words
You now have a production-grade Azure environment and the knowledge to manage it. You understand **Infrastructure as Code**, **Containerization**, **Orchestration**, and **Automation**.

### Resources for Further Learning:
- [Terraform Associate Certification](https://www.hashicorp.com/certification/terraform-associate)
- [Microsoft Certified: Azure Developer Associate (AZ-204)](https://learn.microsoft.com/en-us/credentials/certifications/azure-developer/)

You are now in control of the cloud. Go build something amazing!
