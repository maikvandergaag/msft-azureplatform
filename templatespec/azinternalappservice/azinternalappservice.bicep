//default
param location string = resourceGroup().location

//application insights
param appInsightsName string

//hosting plan
param hostingPlanName string = 'azhp-*-*'
param skuName string = 'S1'
param skuTier string = 'Standard'

//webapp
param webAppName string = 'azappserv-*-*'

//internal networking
param localVnetName string = 'azvnet-spoke-*'
param subnetName string = 'azvnet-spoke-resources'
param networkResourceGroup string = '*-rg-vnetspoke'


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${localVnetName}/${subnetName}'
  scope: resourceGroup(networkResourceGroup)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource serverFarm 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: skuName
    tier: skuTier
    capacity: 1
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverFarm.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
      ]
    }
  }
}

resource networkConfig 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${webApp.name}/virtualNetwork'
  properties: {
    subnetResourceId: subnet.id
    swiftSupported: true
  }
}
