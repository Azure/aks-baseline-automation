ASP.Net App - GitOps Scenario

To deploy your application through GitOps, you need to have a GitOps solution such as [Flux](https://fluxcd.io/) or [ArgoCD](https://argoproj.github.io/cd/) deployed in your cluster.

## Overview

If you followed the instructions in the [IaC](./../IaC/README.md) page of this repo, the cluster that you deployed will have the Flux add-on already bootstrapped. 

To setup the image and the manifest file for the _ASP.Net Hello World_ application to be deployed through GitOps (flux), run manually the workflow [app-AspNet-GitOps.yml](./../.github/workflows/app-AspNet-GitOps.yml).