# Workflows

This folder contains all the GitHub action workflows used to deploy the different components of the AKS solution. The naming convention for the workflow yaml files is as follow:
**[IaC|shared-servies|app]-[purpose].yml**.
For example a GitHub workflow intended to provision all the Azure resources for AKS using bicep will be called "IaC-bicep-aks.yml".

## Reusable Workflows

All of the samples provided in this repo are written for GitHub. Many can easily be adapted for other systems by extracting the script logic used.

GitHub has a concept of [Reusable Workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows), which as the name suggests promotes effective reuse of the workflow logic. Some of the samples in this repo are authored as Reusable Workflows to accelerate using them in your Action Workflow.

## IaC Workflow Scenarios
The following sample workflows are provided for IaC deployments:
1. [IaC-bicep-AKS.yml](../workflows/IaC-bicep-AKS.yml) for the deployment of AKS and all the Azure infrastructure resources that AKS depends on using [bicep CARML modules](https://aka.ms/CARML).
2. [IaC-terraform-AKS.yml](../workflows/IaC-terraform-AKS.yml) for the deployment of AKS and all the Azure infrastructure resources that AKS depends on using [CAF terraform modules](https://github.com/aztfmod/terraform-azurerm-caf). 

For more information, see [IaC README](../../IaC/README.md).
## Shared-Services Workflow Scenarios
  * **Shared-Services-HelmDeployNginx.yaml** used to demonstrate the deployment of shared services through GitHub Actions. In this case NGINX is deployed. Note that there is also an option to deploy the ingress controller **Traefik** using GitOps (see [Shared Services](../../shared-services/README.md)  

## Workloads Workflow Scenarios

Multiple sample workflows are provided to demonstrate different patterns for deploying applications. For more information, see [Workload README](../../workloads/README.md).