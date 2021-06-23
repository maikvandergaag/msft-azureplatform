// default
param location string = resourceGroup().location

// account
param accountName string

//networking
param subnetId string

// Storage Account resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: accountName
    location: location
    kind: 'StorageV2'
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
        virtualNetworkRules: [
          {
            id: subnetId
            action: 'Allow'
          }
        ]
        defaultAction: 'Deny'
      }
      encryption: {
        services: {
          file: {
            keyType: 'Account'
            enabled: true
          }
          blob: {
            keyType: 'Account'
            enabled: true
          }
        }
        keySource: 'Microsoft.Storage'
      }
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = {
  name: '${storageAccount.name}/default/filecontent'
  properties: {
    shareQuota: 5
  }
}
