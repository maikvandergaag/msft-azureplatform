targetScope = 'managementGroup'

param policyCategory string = 'Custom'
param policySource string = 'Guardrails'

resource bicepAuditResourceLock 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'Audit resource locks based on tags'
  properties: {
    displayName: 'Audit Resource Locks on Resource Groups based on Tags'
    description: 'Audit the use of resource locks on resource groups based on tags used'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: policyCategory
      source: policySource
      version: '0.1.0'
      securityCenter: {
        RemediationDescription: 'The resource group should have a resource locks assigned. Go to the resource group and assign a resource lock or adjust the tag value'
        Severity: 'High'
      }
    }
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag Name'
          description: 'The Tag name to audit against (i.e. Environment, CostCenter, etc.)'
         }
      }
      tagValue: {
        type: 'String'
        metadata: {
         displayName: 'Tag Value'
         description: 'Value of the tag to audit against (i.e. Prod/UAT/TEST, 12345, etc.)'
        }
       }
    }
    policyRule: {
      if: {
        allOf: [
         {
          field: 'type'
          equals: 'Microsoft.Resources/subscriptions/resourceGroups'
         }
         {
          field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
          equals: '[parameters(\'tagValue\')]'
         }
        ]
       }
       then: {
        effect: 'auditIfNotExists'
        details: {
         type: 'Microsoft.Authorization/locks'
         existenceCondition: {
          field: 'Microsoft.Authorization/locks/level'
          equals: 'CanNotDelete'
         }
        }
       }
    }
  }
}

output policyDefId string = bicepAuditResourceLock.id
