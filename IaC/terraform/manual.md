# Manual Deployment of the AKS Baseline Reference Implementation using CAF Terraform


## Deployment

```bash
# Script to execute from bash shell

# Login to your Azure Active Directory tenant
az login -t {TENANTNID}

# Make sure you are using the right subscription
az account show -o table

# If you are not in the correct subscription, change it substituting SUBSCRIPTIONID with the proper subscription  id
az account set --subscription {SUBSCRIPTIONID}

# If you are running in Azure Cloud Shell, you need to run the following additional command:
# export TF_VAR_logged_user_objectId=$(az ad signed-in-user show --query objectId -o tsv)
```

Set the folder to Standalone

```bash
cd IaC/terraform
```

Clone the CAF terraform modules
```bash
git clone https://github.com/Azure/caf-terraform-landingzones.git landingzone
```

Deploy with Terraform

```bash
# Load the CAF module and related providers
terraform init -upgrade

# Define the configuration files to apply, all tfvars files within the above folder recursively except for launchpad subfolder which is not relevant for this standalone guide
parameter_files=$(find configuration -not -path "*launchpad*" | grep .tfvars | sed 's/.*/-var-file &/' | xargs)

# Create an execution plan so that you can preview the changes that Terraform will make to your infrastructure
eval terraform plan ${parameter_files} -out tfplan

# Deploy the infrastructure resources using the execution plan previously created
terraform apply tfplan

# Check on the status of the resources that you deployed
terraform state list

# Delete all the resources that were previously deployed
eval terraform destroy ${parameter_files}

```