/**
   Begin common prolog commands
   write-output "Begin common prolog"
   $name='fn-http-queue-s'
   $rg="rg_$name"
   $loc='westus2'
   write-output "End common prolog"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   echo WaitForBuildComplete
   WaitForBuildComplete
   write-output "Previous build is complete. Begin deployment build."
   az.cmd deployment group create --name $name --resource-group $rg   --template-file  deploy-fn-http-queue-s.bicep --parameters useSourceControl=true
   write-output "end deploy"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   echo CreateBuildEvent.exe
   CreateBuildEvent.exe&
   write-output "begin shutdown"
   az.cmd deployment group create --mode complete --template-file ./clear-resources.json --resource-group $rg
   BuildIsComplete.exe
   Get-AzResource -ResourceGroupName $rg | ft
   write-output "showdown is complete"
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   az.cmd group create -l $loc -n $rg
   $id=(az.cmd group show --name $rg --query 'id' --output tsv)
   write-output "id=$id"
   $sp="spad_$name"
   az.cmd ad sp create-for-rbac --name $sp --sdk-auth --role contributor --scopes $id
   write-output "go to github settings->secrets and create a secret called AZURE_CREDENTIALS with the above output"
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   curl curl -d '{"name":"anne-the-dog", "id":"15"}' -H "Content-Type: application/json" -X POST https://fn-http-queue-s-01.azurewebsites.net/api/http-queue?code=dLnp/8ukorgnNzCIh9QLjpzVYD4mPcLyVU4cr3Xks5WzUVdO6fK37Q==
   End commands to deploy this file using Azure CLI with PowerShell


 */

@description('use source control')
param useSourceControl bool = false
@description('The name of the function app that you wish to create.')
param siteName01 string='fn-http-queue-s-01'

@description('The location to use for creating the function app and hosting plan. It must be one of the Azure locations that support function apps.')
param location string = resourceGroup().location

var storageName_var = 'function${uniqueString(siteName01)}'
var contentShareName = toLower(siteName01)
var repoUrl01 = 'https://github.com/siegfried01/fn-http-queue-s'
var branch = 'master'

resource fnAppWebSite01 'Microsoft.Web/sites@2016-03-01' = {
  name: siteName01
  properties: {
    name: siteName01
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsDashboard'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName_var};AccountKey=${listKeys(storageName.id, '2015-05-01-preview').key1}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName_var};AccountKey=${listKeys(storageName.id, '2015-05-01-preview').key1}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~1'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName_var};AccountKey=${listKeys(storageName.id, '2015-05-01-preview').key1}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: contentShareName
        }
        {
          name: 'ROUTING_EXTENSION_VERSION'
          value: '~0.1'
        }
        {
          name: 'Storage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageName_var};AccountKey=${listKeys(storageName.id, '2015-05-01-preview').key1}'
        }
      ]
    }
    clientAffinityEnabled: false
  }
  location: location
  kind: 'functionapp'
}

resource fnAppSite01 'Microsoft.Web/sites/sourcecontrols@2015-08-01' = if(useSourceControl) {
  parent: fnAppWebSite01
  location: location
  name: 'web'
  properties: {
    repoUrl: repoUrl01
    branch: branch
    isManualIntegration: true
  }
}

resource storageName 'Microsoft.Storage/storageAccounts@2015-05-01-preview' = {
  name: storageName_var
  location: location
  properties: {
    accountType: 'Standard_LRS'
  }
}

output siteUri string = 'https://${fnAppWebSite01.properties.hostNames[0]}'
