//SQL
param location string = resourceGroup().location
param dbName string = 'azsqldb-*'
param sqlServerName string = 'azsqlserver-*'
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
@allowed([
  'Enabled'
  'Disabled'
])
param transparentDataEncryption string = 'Enabled'

//Network
param virtualNetworkName string = 'azvnet-spoke-*'
param subnetPrivate_CIDR string = '11.1.3.0/28'
param subnetPrivateName string = 'azvnet-spoke-resources'
param networkResourceGroup string = '*-rg-vnetspoke'

//Private Endpoint
param privateEndpointName string = 'azpriv-endpointsqlapp'
param privateLinkConnectionName string = 'azpriv-endpointsqlapp-link'
var privateDNSZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

module sql '../../.module/sql.bicep' ={
  name: sqlServerName
  params:{
    dbName:dbName
    sqlAdministratorLogin:sqlAdministratorLogin
    sqlAdministratorLoginPassword:sqlAdministratorLoginPassword
    sqlServerName:sqlServerName
    transparentDataEncryption:transparentDataEncryption
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(networkResourceGroup)
}

module subnetPrivate '../../.module/vnet-subnet-private.bicep' = {
  name: subnetPrivateName
  params:{
    subnet_CIDR:subnetPrivate_CIDR
    subnetName:subnetPrivateName
    virtualNetworkName:virtualNetwork.name
  }
  scope: resourceGroup(networkResourceGroup)
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetPrivate.outputs.id
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkConnectionName
        properties: {
          privateLinkServiceId: sql.outputs.serverid
          groupIds: [
            'sqlServer'
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
