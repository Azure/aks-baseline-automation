# Azure Vote - Docker Build and Push Scenario

## Overview

This sample uses Docker to build a container image on the GitHub runner from source, before pushing the image to an Azure Container Registry. The workflow then uses several GitHub actions from the [Azure org](https://github.com/Azure) to deploy the application.

The application is the [AKS Voting App](https://github.com/Azure-Samples/azure-voting-app-redis), which is used in the [AKS Getting Started Guide](https://docs.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-cli). It is a 2 container application that allows the user to use a Web UI to vote between Cats/Dogs, the votes are recorded in a Redis cache.

## Sample info

This sample is a GitHub Reusable Workflow, as an asset in a public repository it can be targeted directly or simply copied into your own repo.

The Azure Credentials required are that of OpenID Connect (OIDC) based Federated Identity Credentials, please see [here](/docs/oidc-federated-credentials.md) for more information.

The reusable workflow file is located [here](/.github/workflows/App-AzureVote-DockerBuild-Actions.yml). To call it from your own workflow, use the code snippet below or just run the workflow [App-Test-All.yml](/.github/workflows/App-Test-All.yml): 

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

## Prerequisites for running this workflow
In order for this workflow to successfully deploy the application on the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline), you will need to change the "Networking" settings of your ACR to allow [public access](https://docs.microsoft.com/en-us/azure/container-registry/data-loss-prevention#azure-cli). Otherwise the GitHub runner hosted in the Cloud won't be able to access your ACR to push the docker image. You will also need to enable [Admin account](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli#admin-account) in your ACR so that "docker login" can be used with a token to authenticate. 

Note that both of these steps will weaken the security of your ACR as well as the security of the workloads running on your cluster. Therefore, a better approach is to keep the ACR default settings and instead deploy [Self-hosted GitHub Runners](#self-hosted-github-runners) in your Azure Virtual Network so that they can access your ACR securely through [Private Endpoints](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-private-link).     
