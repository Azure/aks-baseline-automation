# terraform

This folder contains IaC code for terraform and instructions on how to deploy AKS and the Azure resources it depends on.
It leverages the [CAF Terraform modules](https://github.com/aztfmod/terraform-azurerm-caf).

To build the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline/blob/main/04-networking.md) manually using Azure CLI commands and the CAF terraform modules, follow these [deploymeny instructions](https://github.com/Azure/caf-terraform-landingzones-starter/tree/starter/enterprise_scale/construction_sets/aks/online/aks_secure_baseline/standalone).

To automate the deployment using a GitHub Action pipeline, follow these steps:

1- Fork this repository

2- Set the following secrets in the forked GitHub repository:
| Secret | Description |Sample|
|--------|-------------|------|
|ENVIRONMENT| Name of the environment where you are deploying the Azure resources|non-prod|
|SERVICE_PRINCIPAL_ID| Service Principal which will be used to provision resources||
|SERVICE_PRINCIPAL_PWD| Service Principal secret||
|SUBSCRIPTION_ID| Azure subscription id||
|TENANT| Azure tenant id||
|FLUX_TOKEN| [GitHub Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for Flux V2||

3- Copy the files from this directory <https://github.com/Azure/caf-terraform-landingzones-starter/tree/starter/enterprise_scale/construction_sets/aks/online/aks_secure_baseline/standalone> to the forked repository.

4- Run the workflow located in this repository under [./github/Workflows/IaC-terraform-standalone.yml](]./github/Workflows/IaC-terraform-standalone.yml).

Note that the [trigger](https://docs.github.com/en/actions/using-workflows/triggering-a-workflow) for this workflow is set by default to [workflow_dispatch](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow) to run it manually. Feel free to change it to run automatically based on your specific needs.
