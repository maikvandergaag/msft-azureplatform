param virtualNetworkName string = 'azvnet-spoke-*'
param subnetName string = 'azvnet-spoke-resources'
param subnet_CIDR string = '11.1.4.0/28'


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${virtualNetworkName}/${subnetName}'
  properties: {
    addressPrefix: subnet_CIDR
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

output id string = subnet.id
