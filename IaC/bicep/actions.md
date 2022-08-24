# GitHub Actions Workflows for Bicep

## Workflows

1. [**Bicep Unit Tests**](../../.github/workflows/IAC-bicep-unit-tests.yml)

    This workflow is designed to be run on every commit and is composed of a set of unit tests on the infrastructure code. It runs [bicep build](https://docs.microsoft.com/cli/azure/bicep#az-bicep-build) to compile the bicep to an ARM template. This ensure there are no formatting errors. Next it performs a [validate](https://docs.microsoft.com/cli/azure/deployment/sub#az-deployment-sub-validate) to ensure the template is able to be deployed.

2. [**Bicep What-If / Deploy**](../../.github/workflows/IAC-bicep-whatif-deploy.yaml)

    This workflow runs on every pull request and on each commit to the main branch. The what-if stage of the workflow is used to understand the impact of the IaC changes on the Azure environment by running [whatif](https://docs.microsoft.com/cli/azure/deployment/sub#az-deployment-sub-what-if). This report is then attached to the PR for easy review. The deploy stage runs after the what-if analysis when the workflow is triggered by a push to the main branch. This stage will [deploy](https://docs.microsoft.com/cli/azure/deployment/sub#az-deployment-sub-create) the template to Azure after a manual review has signed off.

## Getting Started

To use these workflows in your environment several prerequiste steps are required:

1. **Create GitHub Environments**

    The workflows utilizes GitHub Environments to store the azure identity information and setup an appoval process for deployments.  Create 2 environments: `production` and `production-approval` by following these [insturctions](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment). On the `production-approval` environment setup a protection rule and add any required approvers you want that need to sign off on production deployments. You can also limit the environment to your main branch. Detailed instructions can be found [here](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment).

2. **Setup Azure Identity**: 

    An Azure Active Directory application is required that has permissions to deploy within your Azure subscription. Create a single application and give it the appropriate permissions in your Azure subscription. Next setup 2 federated credentials to allow the GitHub environements to utilize the identity using OIDC. See the [Azure documentation](https://docs.microsoft.com/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-openid-connect) for detailed instructions. Make sure to set the Enitity Type to `Environment` and use the appropriate environment name for the GitHub name.


3. **Add GitHub Secrets**

    For each GitHub Environment create the following secrets for the respective Azure Identity:

    - _AZURE_CLIENT_ID_ : The application (client) ID of the app registration in Azure
    - _AZURE_TENANT_ID_ : The tenant ID of Azure Active Directory where the app registration is defined.
    - _AZURE_SUBSCRIPTION_ID_ : The subscription ID where the app registration is defined.

    Instuructions to add the secrets to the environment can be found [here](https://docs.github.com/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-an-environment). Since we are usig the same Azure identity for both environments these secrets will have the same value in both GitHub environment.

4. **Activate the Workflows**

    In each workflow file uncomment the top trigger section to enable the workflows to run automatically.

## Additional Resources

Additional information on how to use GitHub Actions to deploy AKS can be found on the [Azure Architecture Center](...). `TODO`: add the link
