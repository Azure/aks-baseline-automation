# Workflows

This folder contains all the GitHub Action workflows used to deploy the different components of the AKS solution. The naming convention for the workflow yaml files is as follow:
**[IaC|shared-servies|app]-[purpose].yml**.
For example a GitHub workflow intended to provision all the Azure resources under the hub Resource Group using bicep will be called "IaC-bicep-rg-hub.yml".

## Reusable Workflows

All of the samples provided in this repo are written for GitHub. Many can easily be adapted for other systems by extracting the script logic used.

GitHub has a concept of [Reusable Workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows), which as the name suggests promotes effective reuse of the workflow logic. Most of the samples in this repo are authored as Reusable Workflows to accelerate using them in your Action Workflow.

## IaC Workflow Scenarios
The following sample workflows are provided for IaC deployments:
1. **IaC-bicep-AKS.yml** for the deployment of AKS and all the Azure infrastructure resources that AKS depends on using [bicep CARML modules](https://aka.ms/CARML).
2. **IaC-terraform-AKS.yml** for the deployment of AKS and all the Azure infrastructure resources that AKS depends on using [CAF CAF modules](https://github.com/aztfmod/terraform-azurerm-caf). 
## Shared-Services Workflow Scenarios
TODO
## Workloads Workflow Scenarios

The following sample workflows are provided for the deployment of the [Azure Voting App](https://github.com/Azure-Samples/azure-voting-app-redis/). 
Sample App | Scenario | Description | Tags
---------- | -------- | ----------- | ----
App-AzureVote-HelmRunCmd.yml| [AKS Run Command](/docs/app-azurevote-helmruncmd.md) | This sample deploys an existing container image using native Kubernetes tooling, executed in AKS using the AKS Run Command. | `Aks Run Command` `Playwright web tests` `Helm`
App-AzureVote-HelmRunCmd-LegacyAuth.yml| [AKS Run Command](/docs/app-azurevote-helmruncmd.md) | Same as the previous sample but the workflow is using legacy Service Principal and password to authenticate to Azure instead of Federated Identity| `Aks Run Command` `Playwright web tests` `Helm`
App-AzureVote-BuildOnACR-Actions.yml| [ACR Build](/docs/app-azurevote-acrbuild.md) | This sample leverages an Azure Container Registry to builds a container image from code. Deployment is done using the Azure Kubernetes GitHub actions. | `Azure Container Registry` `GitHub Actions`
App-AzureVote-DockerBuild-Actions.yml| [Docker Build](/docs/app-azurevote-dockerbuildpush.md) | This sample builds a container image from code on the runner then pushes to a registry. Deployment is done using the Azure Kubernetes GitHub actions. | `Azure Container Registry` `GitHub Actions`
