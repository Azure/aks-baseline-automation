## Prerequisites

### Supported run environment

In order to deploy Azure resources manually through bicep or terraform, you can use the following options:

- [Windows Subsystem for Linux](https://learn.microsoft.com/windows/wsl/about#what-is-wsl-2)
- [Azure Cloud Shell](https://shell.azure.com)
- Linux Bash Shell
- MacOS Shell
- [GitHub CodeSpace](https://github.com/features/codespaces)

### Configuration steps

If you opt-in to setup a shell on your machine, there are required access and tooling you'll need in order to accomplish this. Follow the instructions below and on the subsequent pages so that you can get your environment ready to proceed with the AKS cluster creation.

1. An Azure subscription. If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/free).

   > :warning: The user or service principal initiating the deployment process _must_ have the following minimal set of Azure Role-Based Access Control (RBAC) roles:
   >
   > - [Contributor role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) is _required_ at the subscription level to have the ability to create resource groups and perform deployments.
   > - [Network Contributor role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#network-contributor) is _required_ at the subscription level to have the ability to create and modify Virtual Network resources.
   > - [User Access Administrator role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator) is _required_ at the subscription level since you'll be granting least-privilege RBAC access to managed identities.
   >   - One such example is detailed in the [Container Insights documentation](https://learn.microsoft.com/azure/azure-monitor/containers/container-insights-troubleshoot#authorization-error-during-onboarding-or-update-operation).

   Example for role assignment of current logged in User. If Service Principal or Managed Identity is used, please replace OID with the object id of those credentials
   
   ```bash 
   OID=$(az ad signed-in-user show --query id -o tsv)

   az role assignment create --role "Contributor" --assignee-object-id $OID --assignee-principal-type ServicePrincipal

   az role assignment create --role "User Access Administrator" --assignee-object-id $OID --assignee-principal-type ServicePrincipal

   az role assignment create --role "Network Contributor" --assignee-object-id $OID --assignee-principal-type ServicePrincipal
   ```

      > :twisted_rightwards_arrows: Typically you would only grant these permissions at the resource group level and not subscription level. However, in our sample IaC code the Resource Groups are created at the same time as the rest of the azure resources and therefore to keep it simple we are granting these permission to the same Service Principal at the subscription level.  

2. An Azure AD tenant to associate your Kubernetes RBAC configuration to.

   > :warning: The user or service principal initiating the deployment process _must_ have the following minimal set of Azure AD permissions assigned:
   >
   > - Azure AD [User Administrator](https://learn.microsoft.com/azure/active-directory/users-groups-roles/directory-assign-admin-roles#user-administrator-permissions) is _required_ to create a "break glass" AKS admin Active Directory Security Group and User. Alternatively, you could get your Azure AD admin to create this for you when instructed to do so.
   >   - If you are not part of the User Administrator group in the tenant associated to your Azure subscription, please consider [creating a new tenant](https://learn.microsoft.com/azure/active-directory/fundamentals/active-directory-access-create-new-tenant#create-a-new-tenant-for-your-organization) to use while evaluating this implementation.

3. Required software components.

   >If you opt for Azure Cloud Shell, you don't need to complete these steps and can jump on the next section (step 4).  

   >On Windows, you can use the Ubuntu on [Windows Subsystem for Linux](https://learn.microsoft.com/windows/wsl/about#what-is-wsl-2) to run Bash. Once your bash shell is up you will need to install these prerequisites.

   > Install latest [Azure CLI installed](https://learn.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest)

   ```bash
   sudo apt install azure-cli
   ```

   > Install jq : For more information visit [here](https://stedolan.github.io/jq/download/)

   ```bash
   sudo apt install jq
   ```

   > Install kubectl: For more information visit [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

   ```bash
   az aks install-cli
   ```

   > If you will be using terraform, make sure to install its latest version: For more information visit [here](https://learn.hashicorp.com/tutorials/terraform/install-cli)

   ```bash
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   ```

4. Register the Azure features used by this Reference implementation. For the list of these features look at the pre-checks performed in the IaC workflows [IaC-bicep-AKS.yml](../.github/workflows/IaC-bicep-AKS.yml).
   
5. Clone/download this repo locally, or even better fork this repository.

   > :twisted_rightwards_arrows: If you have forked this reference implementation repo, you'll be able to customize some of the files and commands for a more personalized experience; also ensure references to repos mentioned are updated to use your own (e.g. set the variable `GITHUB_REPO` accordingly).

   ```bash
   export GITHUB_REPO=https://github.com/Azure/aks-baseline-automation.git
   git clone $GITHUB_REPO
   ```
