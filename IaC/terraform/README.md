# terraform

This folder contains the code to build the [AKS Baseline reference implementation](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks) using [CAF Terraform Landing zone framework composition](https://github.com/aztfmod/terraform-azurerm-caf).

The following components will be deployed as part of this automation:

![aks_enterprise_scale_lz](../../docs/.attachments/aks_enterprise_scale_lz2.png)

| Components                                                                                              | Config files                                                 | Description|
|-----------------------------------------------------------|------------------------------------------------------------|------------------------------------------------------------|
| Global Settings |[global_settings.tfvars](./configuration/global_settings.tfvars) | Primary Region setting. Changing this will redeploy the whole stack to another Region|
| Resource Groups | [resource_groups.tfvars](./configuration/resource_groups.tfvars)| Resource groups configs |
| Azure Kubernetes Service | [aks.tfvars](./configuration/aks.tfvars) | AKS addons, version, nodepool configs |
||<p align="center">**Identity & Access Management**</p>||
| Identity & Access Management | [iam_managed_identities.tfvars](./configuration/iam/iam_managed_identities.tfvars) <br /> [iam_role_mappings.tfvars](./configuration/iam/iam_role_mappings.tfvars)| AAD admin group, User Managed Identities & Role Assignments |
||<p align="center">**Gateway**</p>||
| Application Gateway | [agw.tfvars](./configuration/agw/agw.tfvars) <br /> [agw_application.tfvars](./configuration/agw/agw_application.tfvars) <br />| Application Gateway WAF v2 Configs with aspnetapp workload settings |
| App Service Domains | [domain.tfvars](./configuration/agw/domain.tfvars) | Public domain to be used in Application Gateway |
||<p align="center">**Networking**</p>||
| Virtual networks | [networking.tfvars](./configuration/networking/networking.tfvars) <br /> [peerings.tfvars](./configuration/networking/peerings.tfvars) <br /> [nsg.tfvars](./configuration/networking/nsg.tfvars) <br /> [ip_groups.tfvars](./configuration/networking/ip_groups.tfvars)| CIDRs, Subnets, NSGs & peerings config for Azure Firewall Hub & AKS Spoke |
| Private DNS Zone | [private_dns.tfvars](./configuration/networking/private_dns.tfvars) | Private DNS zone for AKS ingress; A record to Load Balancer IP |
| Azure Firewall  | [firewalls.tfvars](./configuration/networking/firewalls.tfvars) <br /> [firewall_application_rule_collection_definition.tfvars](./configuration/networking/firewall_application_rule_collection_definition.tfvars) <br /> [firewall_network_rule_collection_definition.tfvars](./configuration/networking/firewall_network_rule_collection_definition.tfvars) <br /> [route_tables.tfvars](./configuration/networking/route_tables.tfvars)  | Azure Firewall for restricting AKS egress traffic|
| Public IPs | [public_ips.tfvars](./configuration/networking/public_ips.tfvars) | Public IPs for Application Gateway, Azure Firewall & Azure Bastion Host |
||<p align="center">**Security & Monitoring**</p>||
| Azure Key Vault| [keyvaults.tfvars](./configuration/keyvault/keyvaults.tfvars) <br /> [certificate_requests.tfvars](./configuration/keyvault/certificate_requests.tfvars) | Key Vault to store Self signed certificate for AKS ingress & Bastion SSH key |
| Azure Monitor | [diagnostics.tfvars](./configuration/monitor/diagnostics.tfvars)  <br /> [log_analytics.tfvars](./configuration/monitor/log_analytics.tfvars) | Diagnostics settings, Log Analytics Workspace for AKS logs & Prometheus metrics |
||<p align="center">**Bastion**</p>||
| Azure Bastion (OPTIONAL) | [bastion.tfvars](./configuration/bastion/bastion.ignore) | Azure Bastion Host & Windows VM to view aspnetsample website internally. |

<br />

## Prerequisites

Make sure these [prerequisites](../../docs/IaC-prerequisites.md) are in place before proceeding.

## Customize the Terraform templates

To customize the sample terraform templates provided based on your specific needs, follow the steps below:

1. Fork this repo so that you can customize it and run GitHub Action workflows.
2. Review the terraform templates provided under the IaC/terraform folder and customize these files based on your specific deployment requirements for each resource.
3. Test the deployment of each Azure resource individually using these [manual](../../docs/terraform-manual-steps.md) commands.
4. Customize the GitHub repo settings for flux so that it picks up your customized yaml files when deploying the shared services for your cluster. You need to change these settings in the file [`flux.yaml`](../../IaC/terraform/configuration/workloads/flux.tfvars) to point to your forked GitHub repo.


## Customize the GitHub Action Workflows
To customize the sample GitHub pipeline provided based on your specific needs, follow the instructions below:

1. Create your workflow [GitHub Environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment?msclkid=62181fb1ab7511ec9be085113913a757) to store the following secrets:

    | Secret | Description |Sample|
    |--------|-------------|------|
    |ENVIRONMENT| Name of the environment where you are deploying the Azure resources|non-prod|
    |ARM_CLIENT_ID| Service Principal which will be used to provision resources||
    |ARM_CLIENT_SECRET| Service Principal secret||
    |ARM_SUBSCRIPTION_ID| Azure subscription id||
    |ARM_TENANT_ID| Azure tenant id||
    |FLUX_TOKEN| [GitHub Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) for Flux V2||

    Note: do not modify the names of these secrets in the workflow yaml file as they are expected in terraform to be named as shown above.
    Also instead of using a Service Principal and storing the secret in the GitHub Cloud, we will setup [Federated Identity](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#use-the-azure-login-action-with-openid-connect) once it is supported by terraform.

2. Update the workflow [IaC-terraform-AKS.yml](../../.github/workflows/IaC-terraform-AKS.yml) with the name of the Environment you created in the previous step. The default Environment name is "Terraform". Commit the changes to your remote GitHub branch so that you can run the workflow.
    Note that this sample workflow file deploys Azure resources respectively in the hub and spoke resource groups as specified in the [AKS Baseline Reference Implementation](https://github.com/mspnp/aks-baseline).


## Kick-iff the GitHub Action Workflow
As the workflow trigger is set to "workflow_dispatch", you can manually start it by clicking on [Actions](https://github.com/Azure/aks-baseline-automation/actions) in this repo, find the workflow [IaC-terraform-AKS.yml](../../.github/workflows/IaC-terraform-AKS.yml), and run it by clicking on the "Run Workflow" drop down.

As the workflow runs, monitor its logs for any error.
