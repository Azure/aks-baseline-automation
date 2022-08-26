# Shared Services
This folder contains helm charts and other artifacts used to deploy common services used across multiple clusters and multiple applications.

Example of shared services could be third-party services such as [Traefik](https://doc.traefik.io/traefik/v1.7/user-guide/kubernetes/?msclkid=2309fcb3b1bc11ec92c03b099f5d4e1c), [Prisma defender](https://docs.paloaltonetworks.com/prisma/prisma-cloud) and [Splunk](https://github.com/splunk/splunk-connect-for-kubernetes) or open source services such as [NGINX](https://www.nginx.com/resources/glossary/kubernetes-ingress-controller), [KEDA](https://keda.sh), [External-dns](https://github.com/kubernetes-sigs/external-dns#:~:text=ExternalDNS%20supports%20multiple%20DNS%20providers%20which%20have%20been,and%20we%20have%20limited%20resources%20to%20test%20changes.), [Cert-manager](https://cert-manager.io/docs/) or [Istio](https://istio.io/).


This **shared-services** directory is the root of the GitOps configuration directory. The Kubernetes manifest files included in the subdirectories are expected to be deployed via our in-cluster Flux operator. They are our AKS cluster's baseline configurations. 
The following namespaces contain the resources and services that are automatically setup as soon as the cluster is deployed:

* Namespace **cluster-baseline-settings**: 
  * [Kured](#kured)
  * Azure AD Pod Identity
  * Kubernetes RBAC Role Assignments (cluster and namespace) through Azure AD Groups (_optional_)
* Namespace: **kube-system**
  * Azure Monitor Prometheus Scraping
* Namespace: **traefik**
  * Ingress Controller Traefik
* Namespace: **a0008**
  * Ingress Network Policy
  * RBAC settings specific to this namespace

The first three namespaces are workload agnostic and tend to all cluster-wide configuration concerns, while the forth one is workload specific. Typically workload specific configuration setting are controlled by the application teams through their own GitHub repos and GitOps solution, which may be different form the one used here to configure the cluster.

### Kured

Kured is included as a solution to handle occasional required reboots from daily OS patching. This open-source software component is only needed if you require a managed rebooting solution between weekly [node image upgrades](https://docs.microsoft.com/azure/aks/node-image-upgrade). Building a process around deploying node image upgrades [every week](https://github.com/Azure/AKS/releases) satisfies most organizational weekly patching cadence requirements. Combined with most security patches on Linux not requiring reboots often, this leaves your cluster in a well supported state. If weekly node image upgrades satisfies your business requirements, then remove Kured from this solution by deleting [`kured.yaml`](./cluster-baseline-settings/kured.yaml). If however weekly patching using node image upgrades is not sufficient and you need to respond to daily security updates that mandate a reboot ASAP, then using a solution like Kured will help you achieve that objective. **Kured is not supported by Microsoft Support.**

## Private bootstrapping repository

Typically, your bootstrapping repository wouldn't be a public facing repository like this one, but instead a private GitHub or Azure DevOps repo. The Flux operator deployed with the cluster supports private git repositories as your bootstrapping source. In addition to requiring network line of sight to the repository from your cluster's nodes, you'll also need to ensure that you've provided the necessary credentials. This can come, typically, in the form of certificate based SSH or personal access tokens (PAT), both ideally scoped as read-only to the repo with no additional permissions.

If you are using terraform modify the [`flux.yaml`](../../IaC/terraform/configuration/workloads/flux.tfvars) file.

If you are using bicep modify the [`cluster.parameters.json`](../../IaC/bicep/rg-spoke/cluster.parameters.json) file as follow:
