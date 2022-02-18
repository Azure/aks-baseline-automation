# Azure Vote - ACR Build Scenario

## Sample info

This sample is a GitHub Reusable Workflow, as an asset in a public repository it can be targetted directly or simply copied into your own repo.

Location of the [Resuable workflow file](.github/workflows/App-AzureVote-BuildOnACR-Actions.yml)

```yaml
  #Here's how to call the reusable workflow from your workflow
  AcrBuild:
    needs: [ReusableWF]
    uses: ./.github/workflows/App-AzureVote-BuildOnACR-Actions.yml
    with:
      RG: ${{ needs.ReusableWF.outputs.RG }}
      AKSNAME: ${{ needs.ReusableWF.outputs.AKSNAME }}
      ACRNAME: ${{ needs.ReusableWF.outputs.ACRNAME }}
      APPNAME: basevote1
    secrets:
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
```

> This sample is designed to be run on a GitHub runner that has network access to your Azure Container Registry and AKS API endpoint. Where these have been configured as private or network restricted, a self hosted GitHub runner should be leveraged.

## Scenario Components

## Aks Voting App

The Aks Voting app is the application used in most Aks Getting Started guides. It is a 2 container application that allows the user to vote between Cats/Dogs.

## Azure GitHub Actions

Several Azure GitHub actions are leveraged

Action | Description
------ | -----------
Azure/login | Uses credentials to authenticate with the Azure Control Plane
azure/setup-kubectl | Installs the cli for Kubernetes
azure/aks-set-context | Gets the credentials and sets up Kubernetes context to interact with your cluster
azure/k8s-deploy | Performs deployment operations on the cluster

## Key Steps in the Action Workflow

### ACR Build

The primary responsibility of the Azure Container Registry is to store a container image. ACR can also take code and