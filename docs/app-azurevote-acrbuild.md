# Azure Vote - ACR Build Scenario

## Overview

This sample leverages Azure Container Registry to build a container image from source. The workflow then uses several GitHub actions from the Azure org to deploy the application.

The application is the Aks Voting app which is used in the Aks Getting Started guides. It is a 2 container application that allows the user to use a Web UI to vote between Cats/Dogs, the votes are recorded in a Redis cache.

## Sample info

This sample is a GitHub Reusable Workflow, as an asset in a public repository it can be targeted directly or simply copied into your own repo.

The Azure Credentials required are that of OpenID Connect (OIDC) based Federated Identity Credentials, please see [here](/docs/oidc-federated-credentials.md) for more information.

Location of the [Reusable workflow file](/.github/workflows/App-AzureVote-HelmRunCmd.yml)

```yaml
  #Here's how to call the reusable workflow from your workflow file
  deploy-azure-vote-app:
    uses: Azure/aks-baseline-automation/.github/workflows/App-AzureVote-BuildOnACR-Actions.yml@main
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

## ACR Build

The primary responsibility of the Azure Container Registry is to store a container image. ACR can also take a DockerFile and associated files to [build a container image](https://docs.microsoft.com/azure/container-registry/container-registry-quickstart-task-cli).

Using ACR to build the container image offloads build agent responsibility and allows the build to happen in isolation (if using a [dedicated agent pool](https://docs.microsoft.com/azure/container-registry/tasks-agent-pools)). It eliminates the need for storing extra credentials which are normally leveraged to do a Docker Push.

## Azure GitHub Actions

Using GitHub actions as part of your workflow abstracts the Kubernetes binaries and commands from the deployment process. The Azure GitHub actions provide a simple but powerful method of deploying.
