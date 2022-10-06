# Azure Vote - ACR Build Scenario

## Overview

This sample leverages Azure Container Registry to build a container image from source. The workflow then uses several GitHub actions from the [Azure org](https://github.com/Azure) to deploy the application.

The application is the [AKS Voting App](https://github.com/Azure-Samples/azure-voting-app-redis), which is used in the [AKS Getting Started Guide](https://learn.microsoft.com/azure/aks/learn/quick-kubernetes-deploy-cli). It is a 2 container application that allows the user to use a Web UI to vote between Cats/Dogs, the votes are recorded in a Redis cache.

## Sample info

This sample is a GitHub Reusable Workflow, as an asset in a public repository it can be targeted directly or simply copied into your own repo.

The Azure Credentials required are that of OpenID Connect (OIDC) based Federated Identity Credentials, please see [here](/docs/oidc-federated-credentials.md) for more information.

The reusable workflow file is located [here](/.github/workflows/app-azurevote-acrbuild.yml). To call it from your own workflow, use the code snippet below or just run the workflow [App-Test-All.yml](/.github/workflows/App-Test-All.yml):

```yaml
  #Here's how to call the reusable workflow from your workflow file
  deploy-azure-vote-app:
    uses: Azure/aks-baseline-automation/.github/workflows/App-AzureVote-BuildOnACRs.yml@main
    with:
      ENVIRONMENT: MyGitHubEnvironmentName
      RG: ResourceGroupToDeployTo
      AKSNAME: MyAksCluster
      ACRNAME: MyAzureContainerRegistry
      APPNAME: azure-vote-public
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Scenario Components

### ACR Build

The primary responsibility of the Azure Container Registry is to store a container image. ACR can also take a DockerFile and associated files to [build a container image](https://learn.microsoft.com/azure/container-registry/container-registry-quickstart-task-cli).

Using ACR to build the container image offloads build agent responsibility and allows the build to happen in isolation (if using a [dedicated agent pool](https://learn.microsoft.com/azure/container-registry/tasks-agent-pools)). It eliminates the need for storing extra credentials which are normally leveraged to do a Docker Push.

### Azure GitHub Actions

Using GitHub actions as part of your workflow abstracts the Kubernetes binaries and commands from the deployment process. The Azure GitHub actions provide a simple but powerful method of deploying.

## Prerequisites for running this workflow
In order for this workflow to successfully deploy the application on the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline), you will need to change the "Networking" settings of your ACR to allow [public access](https://learn.microsoft.com/azure/container-registry/data-loss-prevention#azure-cli). Otherwise the GitHub runner hosted in the Cloud won't be able to access your ACR to push the docker image. 

Note that this step will weaken the security of your ACR as well as the security of the workloads running on your cluster. Therefore, a better approach is to keep the ACR default settings and instead:
  1. Deploy [Self-hosted GitHub Runners](#self-hosted-github-runners) in your Azure Virtual Network so that they can access your ACR securely through [Private Endpoints](https://learn.microsoft.com/azure/container-registry/container-registry-private-link).
  2. Optionally also deploy an [ACR Task dedicated agent pool](https://learn.microsoft.com/azure/container-registry/tasks-agent-pools) so that your image is built on a runner within your Azure virtual network. 