## Option \#2 Pull-based CI/CD(GitOps)

This article outlines deploying with the pull option as described in the [automated deployment for container applications](https://learn.microsoft.com/azure/architecture/example-scenario/apps/devops-with-aks) article. To deploy the **Option \#2 Pull-based CI/CD Architecture** scenario, follow the steps outlined [here](README.md) (if you haven't already), then perform the following steps:

1. Fork this repo to your GitHub: https://github.com/Azure/aks-baseline-automation. Note: Be sure to uncheck "Copy the main branch only".
2. Go to Actions on the forked repo and enable Workflows as shown: <https://github.com/YOURUSERNAME/aks-baseline-automation/actions>
   ![](media/c2a38551af1c5f6f86944cedc5fd660a.png)
3. Go to Settings on the forked repo and create a new environment
    1. Adding a new environment here: https://github.com/YOUR-REPO/settings/environments/new
    2. Click New Environment button: Environments / Add
    3. Name it prod
4. Set Azure subscription
    1. In Azure cloud shell run
       ```bash
       az account show *\#Shows current subscription*
       ```
       ```bash
       az account set --subscription "YOURAZURESUBSCRIPTION" *\#Set a subscription to be the current active subscription*
       ```
    2. Create a file called `ghToAzAuth.sh` in your bash working directory and copy the code block in this .md file into it: https://github.com/Azure/aks-baseline-automation/blob/main/docs/oidc-federated-credentials.md. You will need to update the following variable values:
       ```bash
       APPNAME=myApp
       RG=<AKS resource group name>
       GHORG=<your github org or user name>
       GHREPO=aks-baseline-automation
       GHBRANCH=main
       GHENV=prod
       ```
    3. Save the shell script after you have made the updates to those variables and run the script in your cloud shell
       ```bash
       bash ghToAzAuth.sh
       ```
       It will create the federated credentials *in* Azure *for* you. Navigate to Azure Portal \> Microsoft \| Overview \> Azure Active Directory \> App registrations \> YOURREGISTEREDAPPNAME \| Certificates & secrets
       You should have the following 3 Federated credentials similar to what is shown *in* the following screenshot:
       ![](media/0664a3dd619ba6e98b475b29856e6c57.png)
       Next you need to create the Environment and GitHub Actions Repository secrets *in* your repo.
5. Create Actions secrets for your Azure subscription in your GitHub Repository *\#Reference: https://learn.microsoft.com/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux\#use-the-azure-login-action-with-a-service-principal-secret*
    1. Navigate to Github Actions Secrets in your browser: From your repo select *Settings* > on the left plane select *Secrets* > select *Actions* in the dropdown
    2. Select *New repository secret* 
    3. Name the secret AZURE_CREDENTIALS in the *Name* field
    4. Paste *in* your JSON object *for* your service principal in the *Secret* field
    5. Click *Add secret*
6. Review Environment secrets
    1. Navigate to environments in your browser: From your repo select *Settings* > on the left plane select *Environments* > select *New environment* at the top right corner of the resulting screen
    2. Enter a name for your environment then click *Configure environment*
    3. At the bottom of the resulting screen under Environment secrets click on *Add secret*
       ```bash
       # The values should be in the following format shown in these examples:
        AZURE_CLIENT_ID = 1gce4f22-5ca0-873c-54ac-b451d7f73e622
        AZURE_TENANT_ID: 43f977bf-83f1-41zs-91cg-2d3cd022ty43
        AZURE_SUBSCRIPTION_ID: C25c2f54-gg5a-567e-be90-11f5ca072277

       ```
       ![](media/a1026d5ff5825e899f2633c2b10177df.png)
    4. When *done* you should see the following secrets *in* your GitHub Settings:
       ![](media/049073d69afee0baddf4396830c99f17.png)
7. Run the GitHub Actions workflow:
    1. Go to [https://github.com/YOUR REPO/aks-baseline-automation/actions](https://github.com/YOUR%20REPO/aks-baseline-automation/actions)
    1. **Note:** If you are using the IaC option, you will need to update the workloads/flask/ingress.yaml to use the traefik ingress option by commenting out the *Http agic* ingress and uncommenting the *Https traefik* ingress. You will also need to update the fqdn in Https traefik to match the configuration you have in your Application gateway. For the quick option with AKS Construction helper, no change here is required.
    1. Run the following workflow: .github/workflows/App-flask-GitOps.yml
    1. Enter the needed inputs:
       ![](media/b4bf25dc9497c669d54a205648cb864c.png)
1. Create a new app for the App in Argo CD. See this link on how to create a new app in Argo CD: https://argo-cd.readthedocs.io/en/stable/getting_started/\\\#creating-apps-via-ui. This is an example of the successful App in Argo CD:
![](media/58af037d65b2303dbb1c2d4196ac300f.png)
![](media/66908c97c321303ba2bcd58ba6431bdd.png)
