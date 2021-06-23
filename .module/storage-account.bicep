// default
param location string = resourceGroup().location

// account
param accountName string

//vnet
param vnetSubNetId string

// Storage Account resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: accountName
    location: location
    kind: 'Storage'
    sku: {
      name: 'Standard_LRS'
    }
    properties:{
      supportsHttpsTrafficOnly:true
      accessTier: 'Hot'
      minimumTlsVersion: 'TLS1_2'
      allowBlobPublicAccess: false
      allowSharedKeyAccess: true
      networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: vnetSubNetId
          action: 'Allow'
        }
      ]
    }
  }
}

// Output Storage Accounts Ids in Array
output storageAccountIds string = storageAccount.id
