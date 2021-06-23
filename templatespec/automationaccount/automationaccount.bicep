//default
param location string = resourceGroup().location

//diagnostics
param logAnalyticsWorkspaceName string
param logAnalyticsResourceGroup string

//automationAccount
param automationaccountName string

resource log_analytics 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsResourceGroup)
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
    workspaceId: log_analytics.id
    logs: [
      {
        category: 'JobLogs'
        enabled: true
      }
    ]
  }
}
