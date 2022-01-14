# bicep

This folder contains IaC code for biecp and instructions on how to deploy AKS and the Azure resources it depends on.

To deploy an AKS environment in your own subscription,follow the steps below: 

1. Clone this repository

2. Make sure that a CARML module for each Azure resource you want to deploy is present under the ./bicep/CARML folder. If not, copy them from https://aka.ms/CARML.

3. Copy the sample parameter file from each CARML module to the folder represeting your resource group. For example copy the parameter file for the AKS module from "./CARML/Microsoft.ContainerService/managedClusters/.parameters/azure.parameters.json" to "./IaC/bicep/rg-spoke", assuming the resource group where you are going to deploy AKS is called "rg-spoke".

4. Customize these parameter files based on your specific deployment requirements for each resource.

5. Test the deployment of each Azure resource individually using the [Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli) or [PowerShell command](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-powershell).

6. Customize the default GitHub Action workflows provided under the .github\workflows fodler to deploy your Azure resources:
   - IaC-bicep-rg-hub.yml
   - IaC-bicep-rg-spoke.yml

    Note that these two sample workflow files provided deploy respectively the resources in the hub and spoke resource groups as specified in the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline/blob/main/04-networking.md).