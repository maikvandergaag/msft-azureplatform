//default
param location string = resourceGroup().location

//storage
param accountName string

//internal networking
param localVnetName string = 'azvnet-spoke-*'
param subnetName string = 'azvnet-spoke-resources'
param networkResourceGroup string = '*-rg-vnetspoke'

module storage '../../.module/storage-account.bicep'={
  name: 'internalStorage'
  params:{
    accountName: accountName
    location:location
  }
}
