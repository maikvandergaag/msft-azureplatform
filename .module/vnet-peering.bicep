param localVnetName string
param remoteVnetId string

resource peer 'microsoft.network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: '${localVnetName}/peering-to-remote-vnet'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
  }
}
