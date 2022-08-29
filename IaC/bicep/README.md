# bicep

This folder contains IaC code for bicep to deploy AKS and the Azure resources that AKS depends on, as well as instructions on how to customize them and automate their deployment using GitHub Action workflows.

## Prerequisites

Make sure these [prerequisites](../../docs/IaC-prerequisites.md) are in place before proceeding.

## Customize the bicep templates

To customize the sample bicep templates provided based on your specific needs, follow the steps below:

1. Fork this repo so that you can customize it and run GitHub Action workflows.
2. Make sure that a CARML module for each Azure resource you want to deploy is present under the ./IaC/bicep/CARML folder. If not, copy them from https://aka.ms/CARML.

3. Review the sample parameter files and bicep template orchestration files provided under the following two folders:

    - ./IaC/bicep/rg-hub: contains the customized files used to build the resources in the hub resource group per the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline).
    - ./IaC/bicep/rg-spoke: contains the customized files used to build the resources in the spoke resource group per the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline).

   Customize these files based on your specific deployment requirements for each resource.

4. Test the deployment of each Azure resource individually using the [Azure CLI](https://docs.microsoft.com/azure/azure-resource-manager/bicep/deploy-cli) or [PowerShell command](https://docs.microsoft.com/azure/azure-resource-manager/bicep/deploy-powershell).
   
   For example to deploy the cluster with Azure CLI in eastus2 run:

   ```bash
   az deployment sub create --location eastus2 --template-file ./cluster.bicep  --parameters ./cluster.parameters.json
   ```
4. Customize the GitHub repo settings for flux so that it picks up your customized yaml files when deploying the shared services for your cluster. You need to change these settings in the file [`cluster.parameters.json`](../../IaC/bicep/rg-spoke/cluster.parameters.json) to point to your forked GitHub repo.
    
## Customize the GitHub Action Workflows
To customize the sample GitHub pipeline provided based on your specific needs, follow the instructions below:

1. Create your workflow [GitHub Environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment?msclkid=62181fb1ab7511ec9be085113913a757) to store the environment variables for your workflow.

2. Customize the GitHub Action workflow [IaC-bicep-AKS.yml](https://github.com/Azure/aks-baseline-automation/blob/main/.github/workflows/IaC-bicep-AKS.yml) under the .github\workflows folder to automate the deployment of your Azure resources through the GitHub pipeline using the bicep parameter and orchestration files that you previously updated.

    Note that this sample workflow file deploys Azure resources respectively in the hub and spoke resource groups as specified in the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline).

3. Configure the GitHub Actions to access Azure resources through [Workload Identity federation with OpenID Connect](https://docs.microsoft.com/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#use-the-azure-login-action-with-openid-connect). This is a more secure access method than using Service Principals because you won't have to manage any secret. Use [this script](../../docs/oidc-federated-credentials.md) to set it up.


## Kick-iff the GitHub Action Workflow
As the workflow trigger is set to "workflow_dispatch", you can manually start it by clicking on [Actions](https://github.com/Azure/aks-baseline-automation/actions) in this Repo, find the workflow [IaC-bicep-AKS.yml](https://github.com/Azure/aks-baseline-automation/blob/main/.github/workflows/IaC-bicep-AKS.yml), and run it by clicking on the "Run Workflow" drop down.

As the workflow runs, monitor its logs for any error.
