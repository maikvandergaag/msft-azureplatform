//SQL
param location string = resourceGroup().location
param dbName string = 'azsqldb-*'
param dbEdition string = 'Basic'
param dbCollation string = 'SQL_Latin1_General_CP1_CI_AS'
param dbObjectiveName string = 'Basic'
param sqlServerName string = 'azsqlserver-*'
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
@allowed([
  'Enabled'
  'Disabled'
])
param transparentDataEncryption string = 'Enabled'


resource sqlServer 'Microsoft.Sql/servers@2020-02-02-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}

resource database 'Microsoft.Sql/servers/databases@2020-02-02-preview' = {
  parent: sqlServer
  name: dbName
  location: location
  sku: {
    name: dbObjectiveName
    tier: dbEdition
  }
  properties: {
    collation: dbCollation
  }
}

// very long type...
resource tde 'Microsoft.Sql/servers/databases/transparentDataEncryption@2020-08-01-preview' = {
  parent: database
  name: 'current'
  properties: {
    state: transparentDataEncryption
  }
}

output dbid string = database.id
output serverid string = sqlServer.id
