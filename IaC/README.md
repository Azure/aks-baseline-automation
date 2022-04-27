# IaC
This folder contains IaC code for bicep and terraform and instructions on how to deploy the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline) using either of the two languages.

After the deployment of the cluster, you can [validate](https://github.com/mspnp/aks-baseline/blob/main/11-validation.md) it and then when you are done you can [clean it up](https://github.com/mspnp/aks-baseline/blob/main/12-cleanup.md).

The GitHub workflow runners are hosted by default in the GitHub Cloud.

For better security, you may want to setup GitHub self-hosted runners locally within your Azure subscription. For more information about the benefits of self-hosted runners and how to set them up, see [this article](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners).

   The diagram below depicts how a GitHub runner hosted in your Azure subscription would work:
   
   ![GitHub Runners](../docs/.attachments/github-runners.jpg)
