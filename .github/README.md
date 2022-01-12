# Workflows

This folder contains all the GitHub Action workflows used to deploy the different compoents of the AKS solution.
 
## Reusable Workflows

All of the samples provided in this repo are written for GitHub. Many can easily be adapted for other systems by extracting the script logic used.

GitHub has a concept of [Reusable Workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows), which as the name suggests promotes effective reuse of the workflow logic. Most of the samples in this repo are authored as Reusable Workflows to accelerate using them in your Action Workflow.

## Scenarios

| Sample App     | Scenario                                                                     | Description                                                                                                                                                                     | Tags                                            |
| -------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| Aks Voting App | [Simple deployment](docs/app-azurevote-actions.md)                           | This sample uses the Azure K8S actions to authenticate and deploy the Azure Voting App.                                                                                         | `Azure Container Registry` `GitHub Actions`     |
| Aks Voting App | [Run Command deployment with verification](docs/app-azurevote-helmruncmd.md) | This sample uses a Helm Chart to deploy the AKS Voting Application. The deployment is executed by the AKS Run Command, which is a secure way to interact with private clusters. | `Aks Run Command` `Playwright web tests` `Helm` |
| Fabrikam Drone | Microservices                                                                | This sample uses several Helm Charts to deploy the Fabrikam Drone Delivery App. Because the Helm Charts are linked there is sequencing to the installation.                     | `Microservices`                                 |

