//default
param location string = resourceGroup().location

//storage
param accountName string

//internal networking
param localVnetName string = 'azvnet-spoke-*'
param subnetName string = 'azvnet-spoke-resources'
param networkResourceGroup string = '*-rg-vnetspoke'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing={
  name: '${localVnetName}/${subnetName}'
  scope: resourceGroup(networkResourceGroup)
}

module storage '../../.module/storage-account.bicep'={
  name: 'internalStorage'
  params:{
    accountName: accountName
    location: location
    subnetId: subnet.id
  }
}
