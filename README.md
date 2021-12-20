# AKS Baseline Automation

This repo demonstrates recommended ways to automate the deployment of the components composing a typical AKS solution.

## Reusable Workflows

All of the samples provided in this repo are written for GitHub. Many can easily be adapted for other systems by extracting the script logic used.

GitHub has a concept of [Reusable Workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows), which as the name suggests promotes effective reuse of the workflow logic. Most of the samples in this repo are authored as Reusable Workflows to accelerate using them in your Action Workflow.

## Scenarios

Sample App | Scenario | Description | Tags
---------- | -------- | ----------- | ----
Aks Voting App | [Simple deployment](scenarios/azurevote-actions.md) | This sample uses  the Azure K8S actions to authenticate and deploy the Azure Voting App. | `GitHub Actions`
Aks Voting App | [Run Command deployment with verification](scenarios/azurevote-helmruncmd.md) | This sample uses a Helm Chart to deploy the AKS Voting Application. The deployment is executed by the AKS Run Command, which is a secure way to interact with private clusters. | `Aks Run Command` `Playwright web tests` `Helm`
Fabrikam Drone | Microservices | This sample uses several Helm Charts to deploy the Fabrikam Drone Delivery App. Because the Helm Charts are linked there is sequencing to the installation. | `Microservices`

## TODO

> This repo has been populated by an initial template to help get you started. Please
> make sure to update the content to build a great experience for community-building.

As the maintainer of this project, please make a few updates:

- Improving this README.MD file to provide a great experience
- Updating SUPPORT.MD with content about this project's support experience
- Understanding the security reporting process in SECURITY.MD
- Remove this section from the README

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
