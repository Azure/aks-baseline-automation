# Azure Vote - Docker Build and Push Scenario

## Overview

This sample uses Docker to build a container image on the GitHub runner from source, before pushing the image to an Azure Container Registry. The workflow then uses several GitHub actions from the Azure organisation to deploy the application.

The application is the Aks Voting app which is used in the Aks Getting Started guides. It is a 2 container application that allows the user to use a Web UI to vote between Cats/Dogs, the votes are recorded in a Redis cache.

## Sample info

This sample is a GitHub Reusable Workflow, as an asset in a public repository it can be targetted directly or simply copied into your own repo.

The Azure Credentials required are that of OpenID Connect (OIDC) based Federated Identity Credentials, please see [here](/docs/oidc-federated-credentials.md) for more information.

Location of the [Reusable workflow file](/.github/workflows/App-AzureVote-HelmRunCmd.yml)

```yaml
  #Here's how to call the reusable workflow from your workflow file
  deploy-azure-vote-app:
    uses: Azure/aks-baseline-automation/.github/workflows/App-AzureVote-DockerBuild-Actions.yml@main
    with:
      ENVIRONMENT: MyGitHubEnvironmentName
      RG: ResourceGroupToDeployTo
      AKSNAME: MyAksCluster
      ACRNAME: MyAzureContainerRegistry
      APPNAME: azure-vote
    secrets:
      AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Scenario Components

## Docker Build and Push

Using Docker to build container images is a very familiar process for most developers. This example uses standard docker commands to build and push to an Azure Container Registry. The authentication with the Azure Container Registry works not through a standard username/password in GitHub secrets, but through retrieving the access token which is available after authenticating with Azure.

## Azure GitHub Actions

Using GitHub actions as part of your workflow abstracts the Kubernetes binaries and commands from the deployment process. The Azure GitHub actions provide a simple but powerful method of deploying.
