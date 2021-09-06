//default
param location string = resourceGroup().location

//application insights
param appInsightsName string

//hosting plan
param hostingPlanName string = 'azhp-*-*'
param skuName string = 'P1v2'
param skuTier string = 'PremiumV2'

//webapp
param webAppPrivateName string = 'azappserv-*-*'
param webAppIntName string = 'azappserv-*-*'

//internal networking
param virtualNetworkName string = 'azvnet-spoke-*'
param subnetIntName string = 'azvnet-spoke-resources'
param subnetPrivateName string = 'azvnet-spoke-resources'

//private endpoint
param privateEndpointName string = 'azpriv-endpointwebapp'
param privateLinkConnectionName string = 'azpriv-endpointwebapp-link'
var privateDNSZoneName = 'privatelink.azurewebsites.net'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnetInt 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing =  {
  parent: virtualNetwork
  name: subnetIntName
}

resource subnetPrivate 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  parent: virtualNetwork
  name: subnetPrivateName
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

resource webAppPrivate 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppPrivateName
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


resource webAppInt 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppIntName
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


resource webAppIntNetworkConfig 'Microsoft.Web/sites/networkConfig@2020-06-01' = {
  parent: webAppInt
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetInt.id
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetPrivate.id
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName
        properties: {
          privateLinkServiceId: webAppPrivate.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZones
  name: '${privateDnsZones.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
}
