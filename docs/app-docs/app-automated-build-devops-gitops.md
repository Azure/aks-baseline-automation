**Overview**

In the [**Automated build & deployment of container applications using DevOps & GitOps**](http://TBDlink.com/) document we explored the options of push and pull based CI/CD options along with the pros and cons of each. In this section we are going deploy a scenario that explains these two options further. To explore the architecture in more detail, please check out the [reference architecture in Microsoft Docs](http://TBDlink.com/)

**Option \#1 Push-based CI/CD Architecture and Dataflow**

![](./pull-push-steps/media/5ef464b58b9ce8ab4499ed1c2aec882f.png)

Figure 1 - Option \#1 Push based Architecture with GitHub Actions for CI and CD

This scenario covers a push-based DevOps pipeline for a 2-tier web application with a front-end web component and a back-end Redis. This pipeline uses GitHub Actions for build push and deployment. The data flows through the scenario as follows:

1.  The Voting App code is developed.
2.  The Voting App code is committed to the GitHub git repository.
3.  GitHub Actions creates a new Azure Container Registry if it does not exist.
4.  GitHub Actions Builds a container image from the Voting App code and pushes the container image to Azure Container Registry.
5.  A GitHub Actions job deploys (pushes) the voting app to the AKS cluster via kubectl deployment of the voting app Kubernetes manifest files.

**Option \#2 Pull-based CI/CD Architecture and Dataflow**

![](./pull-push-steps/media/72be57feef5bb9b47658cfc16f3d779f.png)

Figure 2 - Option \#2 Pull based Architecture with GitHub Actions for CI and Argo CD for CD

This scenario covers a pull-based DevOps pipeline for a 2-tier web application with a front-end web component and a back-end Redis. This pipeline uses GitHub Actions for build and push it uses Argo CD a GitOps operator pull/sync for deployment. The data flows through the scenario as follows:

1.  The Voting App code is developed.
2.  The Voting App code is committed to the GitHub git repository.
3.  GitHub Actions creates a new Azure Container Registry if it does not exist.
4.  GitHub Actions Builds a container image from the Voting App code and pushes the container image to Azure Container Registry.
5.  GitHub Actions logs into the AKS cluster and creates a secret for connecting to ACR used by the image deployment.
6.  GitHub Actions Updates a Kubernetes Manifest Deployment file with the current image version based on the version number of the container image in the Azure Container Registry and updates the manifest with the Kubernetes Secret name used to pull the container image from the Azure Container Registry.
7.  The GitOps Operator Argo CD syncs / pulls with the Git repository.
8.  The GitOps Operator Argo CD deploys the voting app to the AKS cluster.

**Deploy this scenario**

Before deploying the push or pull based end to end scenario you need to ensure you have met the prerequisites for this scenario. These prerequisites are listed in this section:

**Prerequisites for these scenarios**

-   You must have an existing Azure account. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F) before you begin.
-   An ACR instance deployed
-   An AKS cluster
    -   It is highly recommended to utilize the [AKS Construction helper](https://azure.github.io/AKS-Construction/) to deploy your Azure Container Registry (ACR) and Azure Kubernetes Service (AKS) cluster. You can use this pre-configured link: [AKS Construction helper (pre-configured)](https://azure.github.io/AKS-Construction/?ops=managed&cluster.apisecurity=none&addons.ingress=none&addons.monitor=aci&addons.azurepolicy=none&addons.networkPolicy=none&addons.csisecret=none&deploy.location=EastUS2) to create a basic AKS cluster (not recommended for production) to use with this CI/CD scenario. This will create an ACR, and an AKS cluster that is AAD integrated and attached to the ACR
-   Argo CD installed on your AKS cluster ([Get Started with Argo CD](https://argo-cd.readthedocs.io/en/stable/getting_started/))
-   A GitHub account ([Getting started with your GitHub account](https://docs.github.com/en/get-started/onboarding/getting-started-with-your-github-account))
-   Fork the [AKS Baseline Automation repository](https://github.com/azure/aks-baseline-automation)