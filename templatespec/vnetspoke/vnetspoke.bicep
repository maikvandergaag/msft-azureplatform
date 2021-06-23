//vnet spoke
param vnetSpokeName string = 'azvnet-spoke-general'
param vnetSpokeAddressPrefix string = '11.1.1.0/16'
param vnetSpokeSubnetName string = 'azvnet-spoke-resources'
param vnetSpokeSubnetAddressPrefix string = '11.1.1.0/24'
param vnetSpokeNSGName string = 'aznsg-subnet-spoke'

//vnet hub
param hubVnetworkName string = 'azvnet-hub' 

//log analytics
param logAnalyticsWorkspaceName string = 'azla-workspace-general'

//general resources
param hubSubscriptionId string
param hubResourceGroupName string = 'gaag-rg-vnethub'

param location string = resourceGroup().location

resource vnetHub 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: hubVnetworkName
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
}

resource loganalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
}

resource nsgSpoke 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: vnetSpokeNSGName
  location: location
  properties: {
  }
}

resource diagNsgSpoke 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'azvnet-diag'
  scope: nsgSpoke
  properties: {
    workspaceId: loganalytics.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetSpokeName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetSpokeAddressPrefix
      ]
    }

    subnets: [
      {
        name: vnetSpokeSubnetName
        properties: {
          addressPrefix: vnetSpokeSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsgSpoke.id
          }
        }
      }
    ]
  }
}

resource diagVnetSpoke 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'diagVnetSpoke'
  scope: vnetSpoke
  properties: {
    workspaceId: loganalytics.id
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
  }
}

module peerHubSpoke '../../.module/vnet-peering.bicep'={
  name: 'peering'
  params:{
    localVnetName:vnetHub.name
    remoteVnetId: vnetSpoke.id
    allowGatewayTransit:true
  }
  scope: resourceGroup(hubSubscriptionId, hubResourceGroupName)
}

resource peerSpokeHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${vnetSpoke.name}/spoke-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
  }
}
