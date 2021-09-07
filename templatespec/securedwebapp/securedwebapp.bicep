//frontdoor
param frontdoorName string = 'azfrontdoor-*'

//application insights
param appInsightsName string

//hosting plan
param hostingPlanName1 string = 'azhp-*-001'
param hostingPlanName2 string = 'azhp-*-002'
param skuName string = 'S1'
param skuTier string = 'Standard'

//webapp
param webAppName1 string = 'azappserv-*-001'
param webAppName2 string = 'azappserv-*-002'

//default
param location string = resourceGroup().location
param location1 string = resourceGroup().location
param location2 string = resourceGroup().location

module frontdoor '../../.module/frontdoor.bicep' ={
  name: frontdoorName
  params:{
    frontDoorName: frontdoorName
    backendAddress1: webApp1.properties.defaultHostName
    backendAddress2: webApp2.properties.defaultHostName
  }
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

resource serverFarm1 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName1
  location: location1
  sku: {
    name: skuName
    tier: skuTier
    capacity: 1
  }
  kind: 'linux'
}

resource serverFarm2 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: hostingPlanName2
  location: location2
  sku: {
    name: skuName
    tier: skuTier
    capacity: 1
  }
  kind: 'linux'
}

resource webApp1 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName1
  location: location1
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverFarm1.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
      ]
    }
  }
}

resource webApp2 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName2
  location: location2
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverFarm2.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
      ]
    }
  }
}
