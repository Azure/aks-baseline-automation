# ASP.Net - Docker Build and Push Scenario

## Overview

This sample uses Docker to build a container image on the GitHub runner from source, before pushing the image to an Azure Container Registry. The workflow then uses several GitHub actions from the [Azure org](https://github.com/Azure) to deploy the application.

The application is the [ASP.Net Hello World](https://github.com/mspnp/aks-baseline/tree/main/workload), which is used in the [AKS baseline Reference Implementation](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks). It is a simple ASP.Net Core web application that displays Hello World and some information from the cluster.

## Sample info

The Azure Credentials required are that of OpenID Connect (OIDC) based Federated Identity Credentials, please see [here](/docs/oidc-federated-credentials.md) for more information.

To create this workflow, just copy the [App-Flask-DockerBuild.yml](/.github/workflows/App-Flask-DockerBuild.yml) file and then update in the last step of the workflow the parameters of the action **k8s-deploy** to list the manifest files for the aspnet application deployment. These file are located under this [folder](../../aspnet/).

## Scenario Components

### Docker Build and Push

Using Docker to build container images is a very familiar process for most developers. This example uses standard docker commands to build and push to an Azure Container Registry. The authentication with the Azure Container Registry works not through a standard username/password in GitHub secrets, but through retrieving the access token which is available after authenticating with Azure.

### Azure GitHub Actions

Using GitHub actions as part of your workflow abstracts the Kubernetes binaries and commands from the deployment process. The Azure GitHub actions provide a simple but powerful method of deploying.

## Prerequisites for running this workflow
In order for this workflow to successfully deploy the application on the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline), you will need to change the "Networking" settings of your ACR to allow [public access](https://learn.microsoft.com/azure/container-registry/data-loss-prevention#azure-cli). Otherwise the GitHub runner hosted in the Cloud won't be able to access your ACR to push the docker image. You will also need to enable [Admin account](https://learn.microsoft.com/azure/container-registry/container-registry-authentication?tabs=azure-cli#admin-account) in your ACR so that "docker login" can be used with a token to authenticate. 

Note that both of these steps will weaken the security of your ACR as well as the security of the workloads running on your cluster. Therefore, a better approach is to keep the ACR default settings and instead deploy [Self-hosted GitHub Runners](#self-hosted-github-runners) in your Azure Virtual Network so that they can access your ACR securely through [Private Endpoints](https://learn.microsoft.com/azure/container-registry/container-registry-private-link).     
