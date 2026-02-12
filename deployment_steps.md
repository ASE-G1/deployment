#Azure Deployment Steps

1.Install Azure CLI and Terraform
2.After installing Azure CLI, run the command below to check available regions. Update the location variable in variable.tf as per your account:

   $ az policy assignment list --query "[].{Name:name, DisplayName:displayName, PolicyDefinitionId:policyDefinitionId, Parameters:parameters}"
3.Restart your system if you are using Windows.
4.Go to the Terraform directory:
   $ cd deployment/terraform
5.Initialize Terraform:
   $ terraform init
6.Review the plan:
   $ terraform plan
7.Deploy the resources:
   $ terraform apply
8.Deploy the frontend:
 scm_frontend folder should be there and run this script deploy_frontend_manual.sh



