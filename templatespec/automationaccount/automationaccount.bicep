//default
param location string = resourceGroup().location

//diagnostics
param logAnalyticsWorkspaceName string

//automationAccount
param automationaccountName string

module logAnalyticsWorkspace '../../.module/log-analytics.bicep' = {
  name: logAnalyticsWorkspaceName
  params:{
    location:location
    logAnalyticsWorkspaceName:logAnalyticsWorkspaceName
  }
}

resource automation_account 'Microsoft.Automation/automationAccounts@2015-10-31' = {
  location: location
  name: automationaccountName
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource automation_account_diagnostic 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: '${automationaccountName}-diag' 
  scope: automation_account
  properties: {
    workspaceId: logAnalyticsWorkspace.outputs.workspaceId
    logs: [
      {
        category: 'JobLogs'
        enabled: true
      }
    ]
  }
}
