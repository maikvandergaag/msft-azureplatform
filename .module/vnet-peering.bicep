param localVnetName string
param remoteVnetId string
param allowRemoteGateways bool = false
param allowGatewayTransit bool =false

resource peer 'microsoft.network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  name: '${localVnetName}/peering-to-remote-vnet'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: allowRemoteGateways
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
  }
}
