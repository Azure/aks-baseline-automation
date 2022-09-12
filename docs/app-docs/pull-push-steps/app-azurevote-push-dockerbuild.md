## Option \#1 Push-based CI/CD

This article outlines deploying with the push option as describled in the [automated build and deploy for container applications article](../app-automated-build-devops-gitops.md). To deploy the **Option \#1 Push-based CI/CD Architecture** scenario, follow the steps outlined there (if you haven't already), then perform the following steps:

1. Fork this repo to your GitHub: https://github.com/Azure/aks-baseline-automation. Note: Be sure to uncheck "Copy the main branch only".
1. Go to Actions on the forked repo and enable Workflows as shown: <https://github.com/YOURUSERNAME/aks-baseline-automation/actions>
   ![](media/c2a38551af1c5f6f86944cedc5fd660a.png)
1. Go to Settings on the forked repo and create a new environment 
    1. adding a new environment here: https://github.com/YOUR-REPO/settings/environments/new
    1. Click New Environment button: Environments / Add
    1. Name it prod
1. Set Azure subscription
    1. In Azure cloud shell run
       ```bash
       az account show *\#Shows current subscription*
       ```
       ```bash
       az account set --subscription "YOURAZURESUBSCRIPTION" *\#Set a subscription to be the current active subscription*
       ```
    1. Create a file called `ghtoAzAuth.sh` in your bash working directory and copy the code block in this .md file into it: https://github.com/Azure/aks-baseline-automation/blob/main/docs/oidc-federated-credentials.md. You will need to update the following variable values:
       ```bash
       APPNAME=myApp
       RG=<AKS resource group name>
       GHORG=<your github org or user name>
       GHREPO=aks-baseline-automation
       GHBRANCH=main
       GHENV=prod
       ```
    1. Save the shell script after you have made the updates to those variables and run the script in your cloud shell
       ```bash
       bash ghtoAzAuth.sh
       ```
       It will create the federated credentials *in* Azure *for* you. Navigate to Azure Portal \> Microsoft \| Overview \> Azure Active Directory \> App registrations \> YOURREGISTEREDAPPNAME \| Certificates & secrets
       You should have the following 3 Federated credentials similar to what is shown *in* the following screenshot:
       ![](media/0664a3dd619ba6e98b475b29856e6c57.png)
       Next you need to create the Environment and GitHub Actions Repository secrets *in* your repo.
1. Create Actions secrets for your Azure subscription in your GitHub Repository *\#Reference: https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux\#use-the-azure-login-action-with-a-service-principal-secret*
    1. Navigate to Github Actions Secrets in your browser: From your repo select *Settings* > on the left plane select *Secrets* > select *Actions* in the dropdown
    1. Select *New repository secret* 
    1. Name the secret AZURE_CREDENTIALS in the *Name* field
    1. Paste *in* your JSON object *for* your service principal in the *Secret* field
    1. Click *Add secret*
1. Review Environment secrets
    1. Navigate to environments in your browser: From your repo select *Settings* > on the left plane select *Environments* > select *New environment* at the top right corner of the resulting screen
    1. Enter a name for your environment then click *Configure environment*
    1. At the bottom of the resulting screen under Environment secrets click on *Add secret*
    1. 

Click Add secret

Environment Secrets:

<https://github.com/YOURREPONAME/YOURAPPNAME/settings/environments>

*\#The values should be in the following format shown in these examples:*

AZURE_CLIENT_ID

hgce4f22-5ca0-873c-54ac-b451d7f73e622

AZURE_TENANT_ID

43f977bf-83f1-41zs-91cg-2d3cd022ty43

AZURE_SUBSCRIPTION_ID

C25c2f54-gg5a-567e-be90-11f5ca072277

![](media/8d8f1c7aa2aadd4720e777e15ecff20c.png)

When *done* you should see the following secrets *in* your GitHub Settings:

![](media/16c05d730bb2da88d408dbcbd083ff4c.png)

\#Step 4 - Run the GitHub Actions workflow

Go to [https://github.com/YOUR REPO/aks-baseline-automation/actions](https://github.com/YOUR%20REPO/aks-baseline-automation/actions)

Run the .github/workflows/App-AzureVote-DockerBuild-Actions.yml workflow

Enter the needed inputs:

![](media/dfd1175c0b334580801b256767d6219f.png)

You will see the workflows start.

![](media/4e7482d9ef0a688cd8102829b99d6e98.png)

When it completes both jobs will green showing the workflow was successful.

![](media/d8ac3926152f7621c2bf05374ff861af.png)

You will be able to see the Azure Voting app was successfully deployed to the default namespace in your AKS cluster as shown in the following screenshots:

![](media/cc3c3a48c75e3c6824849ae511fcbe86.png)

![](media/0ba23d333d40a6487ab7fdb656cbffb1.png)