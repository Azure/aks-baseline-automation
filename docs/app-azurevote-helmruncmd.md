# Azure Vote - Helm Run Command Scenario

## Overview

This sample leverages the AKS Run Command and performs comprehensive validation steps to ensure the application has been deployed properly.

The application is the Aks Voting app which is used in the Aks Getting Started guides. It is a 2 container application that allows the user to use a Web UI to vote between Cats/Dogs, the votes are recorded in a Redis cache.

## Workflow steps

```mermaid
%%{init:
{
  "theme": "default",
  "themeVariables": {
    "nodeBorder" : "#004990",
    "mainBkg" : "#c9d7e4",
    "actorBkg" : "#01A6F0",
    "signalColor" : "#F34F1C",
    "textColor" : "#747474",
    "loopTextColor" : "#C7C7C7",
    "labelTextColor" : "#C7C7C7",
    "labelBoxBorderColor" : "#7FBC00",
    "labelBoxBkgColor" : "#7FBC00",
    "noteBkgColor" : "#FFBA01",
    "noteBorderColor": "#FFBA01",
    "fontFamily": "Inter",
    "fontSize": "13px"
 }
}
}%%
sequenceDiagram
    participant GitHub Runner
    participant Azure
    participant AKS
    participant MCR
    participant App
    GitHub Runner->>Azure: Login
    Azure-->>GitHub Runner: Token
    GitHub Runner->>AKS: RunCmd: Check for existing install
    Note right of AKS: Conditionally<br/>Force Uninstall
    GitHub Runner->>AKS: RunCmd: Helm Install dry run
    GitHub Runner->>AKS: RunCmd: Helm Install
    AKS->>App: Deploy App
    AKS-->>MCR: Retrieve Container Images
    GitHub Runner->>AKS: RunCmd: Check deployment
    loop WaitForIP
        AKS->>AKS: Wait for IP Address
    end
    GitHub Runner->>App: Verify app reachable
    loop WaitFor200
        App->>App: Wait for App response
    end
    GitHub Runner->>App: Run Playwright UI tests
    GitHub Runner->>AKS: (optionally) RunCmd: Helm UnInstall
    AKS-->>App: (optionally) Uninstall App
    GitHub Runner->>GitHub Runner: Store logs as artifacts
```

## Sample info

This sample is a GitHub Reusable Workflow, as an asset in a public repository it can be targetted directly or simply copied into your own repo.

Location of the [Reusable workflow file](/.github/workflows/App-AzureVote-HelmRunCmd.yml)

```yaml
  #Here's how to call the reusable workflow from your workflow file
  deploy-azure-vote-app:
    uses: Azure/aks-baseline-automation/.github/workflows/App-AzureVote-HelmRunCmd.yml@main
    with:
      RG: ResourceGroupToDeployTo
      AKSNAME: MyAksCluster
      APPNAME: azure-vote-public
      INGRESSTYPE: "PublicLoadBalancer"
    secrets:
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
```

> This sample is directly leveraged in the [AKS Bicep Accelerator](https://github.com/Azure/Aks-Construction) for smoke-testing new Kubernetes clusters.

## Scenario Components

## Helm

[Helm](https://helm.sh/) is a package manager for Kubernetes, used to package and deploy applications with ease.
The Helm chart is written using [subcharts](https://helm.sh/docs/topics/charts/) for the deployments, whilst the parent Helm chart creates the Ingress and NetworkPolicy resources.

## Aks Run Command

The [Aks Run Command allows](https://docs.microsoft.com/en-us/azure/aks/command-invoke) you to remotely invoke commands in an AKS cluster through the AKS API. This can greatly assist with access to a private cluster when the client is not on the cluster private network while still retaining and enforcing full RBAC controls and a private API server.

## Key Steps in the Action Workflow

### Verifying

After creating the application, it can be useful to check that the application is serving content. Steps in this workflow wait for an IP address to be allocated, which is then tested to ensure content is returned.

### Playwright

[Playwright](https://playwright.dev) is a web testing framework which is used to interact with a web application to mimic user input. It's use in this action workflow is a [single test]((deploymentassets/misc/playwrighttests/azure-vote-catswin.spec.js)) to verify that communication between pods is successful by voting (calling redis) and asserting the vote balance is correct.
