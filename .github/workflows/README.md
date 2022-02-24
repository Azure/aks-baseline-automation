# Workflows

This folder contains all the GitHub Action workflows used to deploy the different components of the AKS solution. The naming convention for the workflow yaml files is as follow:
**[IaC|shared-servies|app]-[purpose].yml**.
For example a GitHub workflow intended to provision all the Azure resources under the hub Resource Group using bicep will be called "IaC-bicep-rg-hub.yml".

## Reusable Workflows

All of the samples provided in this repo are written for GitHub. Many can easily be adapted for other systems by extracting the script logic used.

GitHub has a concept of [Reusable Workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows), which as the name suggests promotes effective reuse of the workflow logic. Most of the samples in this repo are authored as Reusable Workflows to accelerate using them in your Action Workflow.

## IaC Workflow Scenarios
TODO
## Shared-Services Workflow Scenarios
TODO
## Workloads Workflow Scenarios

Sample App | Scenario | Description | Tags
---------- | -------- | ----------- | ----
Aks Voting App | [AKS Run Command](/docs/app-azurevote-helmruncmd.md) | This sample deploys an existing container image using native Kubernetes tooling, executed in AKS using the AKS Run Command. | `Aks Run Command` `Playwright web tests` `Helm`
Aks Voting App | [ACR Build](/docs/app-azurevote-acrbuild.md) | This sample leverages an Azure Container Registry to builds a container image from code. Deployment is done using the Azure Kubernetes GitHub actions. | `Azure Container Registry` `GitHub Actions`
Aks Voting App | [Docker Build](/docs/app-azurevote-dockerbuildpush.md) | This sample builds a container image from code on the runner then pushes to a registry. Deployment is done using the Azure Kubernetes GitHub actions. | `Azure Container Registry` `GitHub Actions`
