# terraform

This folder contains IaC code for terraform and instructions on how to deploy AKS and the Azure resources it depends on.
It leverages the [CAF Terraform modules](https://github.com/aztfmod/terraform-azurerm-caf).

## Manual deployment
To build the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline) manually using Azure CLI commands and the CAF terraform modules, follow these [deployment instructions](https://github.com/Azure/caf-terraform-landingzones-starter/tree/starter/enterprise_scale/construction_sets/aks/online/aks_secure_baseline/standalone).

## Standalone automated deployment with GitHub Actions
To automate the deployment using a GitHub Action pipeline, follow these steps:

1- Fork this repository

2- Set the following secrets in the forked GitHub repository:
| Secret | Description |Sample|
|--------|-------------|------|
|ENVIRONMENT| Name of the environment where you are deploying the Azure resources|non-prod|
|ARM_CLIENT_ID| Service Principal which will be used to provision resources||
|ARM_CLIENT_SECRET| Service Principal secret||
|ARM_SUBSCRIPTION_ID| Azure subscription id||
|ARM_TENANT_ID| Azure tenant id||
|FLUX_TOKEN| [GitHub Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for Flux V2||

Note: do not modify the names of these secrets in the workflow yaml file as they are expected in terraform to be named as shown above.

3- Clone the repository https://github.com/Azure/caf-terraform-landingzones-starter.git and copy the following folders from this repository to your working repository under the ./IaC/terraform folder:
 - ./enterprise_scale/construction_sets/aks/online/aks_secure_baseline/standalone
 - ./enterprise_scale/construction_sets/aks/online/aks_secure_baseline/test

4- Run the following workflow pipeline from your working repository to deploy all the Azure resources: [.github/Workflows/IaC-terraform-standalone.yml](../../.github/workflows/IaC-terraform-standalone.yml).

## Landingzone automated deployment with GitHub Actions