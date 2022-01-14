# bicep

## Setting up the GitHub Pipeline
This folder contains IaC code for biecp and instructions on how to deploy AKS and the Azure resources it depends on.

To deploy an AKS environment in your own subscription,follow the steps below: 

1. Clone this repository

2. Make sure that a CARML module for each Azure resource you want to deploy is present under the ./IaC/bicep/CARML folder. If not, copy them from https://aka.ms/CARML.

3. Review the sample parameter files and bicep template orchestration files provided under the following two folders:

    - ./IaC/bicep/rg-hub: contains the customized files used to build the resources in the hub resource group per the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline/blob/main/04-networking.md).
    - ./IaC/bicep/rg-spoke: contains the customized files used to build the resources in the spoke resource group per the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline/blob/main/04-networking.md).

   Customize these files based on your specific deployment requirements for each resource.

4. Test the deployment of each Azure resource individually using the [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli) or [PowerShell command](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-powershell).

5. Customize the default GitHub Action workflows under the .github\workflows folder to automate the deployment of your Azure resources through the GitHub pipleine using the bicep parameter and orchestration files that you previously updated. There is one workflow file for each Azure resource group that needs to be built:
   - IaC-bicep-rg-hub.yml
   - IaC-bicep-rg-spoke.yml

    Note that these two sample workflow files deploy Azure resources respectively in the hub and spoke resource groups as specified in the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline/blob/main/04-networking.md).

6. Setup the Service principal and Secrets for the GitHub pipeline

   TODO

7. Run and troubleshoot the Github pipleine
   
   TODO

8. Optional: Use Github runners running in Azure rather than in GitHub cloud for better security

   TODO
