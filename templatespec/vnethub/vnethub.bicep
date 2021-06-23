//vnet
param hubVnetworkName string = 'azvnet-hub' 
param hubVnetAddressPrefix string = '11.0.0.0/16'

//bastion
param bastionHostName string = 'azbastion-general'
param bastionPublicIPName string = 'azpip-bastion'
param bastionSubnet string = 'AzureBastionSubnet'
param bastionSubnetNSG string = 'aznsg-subnet-bastion'
param bastionSubnetPrefix string = '11.0.1.0/29'

//VPN Gateway
param vpnGatewayName string = 'azgw-general'
param vpnGatewaySubnetName string = 'GatewaySubnet'
param vpnGatewaySubnetPrefix string = '11.0.2.0/27'
param vpnGatewayPublicIPName string = 'azpip-gateway'

//Log Analytics
param logAnalyticsWorkspaceName string = 'azla-workspace-general'

param location string = resourceGroup().location

resource vnetHub 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: hubVnetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: bastionSubnet
        properties: {
          addressPrefix: bastionSubnetPrefix
          networkSecurityGroup: {
            id: nsgBastion.id
          }
        }
      }
      {
        name: vpnGatewaySubnetName
        properties: {
          addressPrefix: vpnGatewaySubnetPrefix
        }
      }
    ]
  }
}

module logAnalyticsWorkspace '../../.module/log-analytics.bicep' = {
  name: logAnalyticsWorkspaceName
  params:{
    location:location
    logAnalyticsWorkspaceName:logAnalyticsWorkspaceName
  }
}

resource diagVnetHub 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'azvnet-diag'
  scope: vnetHub
  properties: {
    workspaceId: logAnalyticsWorkspace.outputs.workspaceId
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
  }
}


resource nsgBastion 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: bastionSubnetNSG
  location: location
  properties: {
    securityRules: [
      {
        name: 'bastion-in-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-control-in-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-in-host'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-vnet-out-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-azure-out-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-out-host'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-out-deny'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource bastionPip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: bastionPublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}



resource bastionHostResource 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf'
        properties: {
          subnet: {
            id: '${vnetHub.id}/subnets/${bastionSubnet}'
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
  }
}

resource gatewayResourcePIP 'Microsoft.Network/publicIPAddresses@2021-02-01' ={
  name: vpnGatewayPublicIPName
  location: location
  properties:{
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource gatewayResource 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: vpnGatewayName
  location: location    
  properties: {
      gatewayType: 'Vpn'
      ipConfigurations: [
          {
              name: 'default'
              properties: {
                  privateIPAllocationMethod: 'Dynamic'
                  subnet: {
                      id: '${vnetHub.id}/subnets/${vpnGatewaySubnetName}'
                  }
                  publicIPAddress: {
                      id: gatewayResourcePIP.id
                  }
              }
          }
      ]
      sku: {
        name: 'Basic'
        tier: 'Basic'
      }
      enableBgp: true
      vpnType: 'RouteBased'
  }
}
