param location string = resourceGroup().location
param storageAccountName string = 'mystorageaccount${uniqueString(resourceGroup().id)}'
param functionAppName string = 'myfunctionapp${uniqueString(resourceGroup().id)}'
param functionAppPackageUrl string = 'https://writedelete562stor.blob.core.windows.net/queuetrigger/queuetrigger.zip'
param appInsightsName string = 'appInsights${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appInsights 'Microsoft.Insights/components@2022-09-01' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'myAppServicePlan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'DOTNET_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'DOTNET_ISOLATED_VERSION'
          value: '8.0'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: functionAppPackageUrl
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    storageAccount
    appServicePlan
    appInsights
  ]
}

output functionAppEndpoint string = functionApp.properties.defaultHostName
