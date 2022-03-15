targetScope = 'managementGroup'

param policyCategory string = 'Custom'
param policySource string = 'Guardrails'

resource bicepDeployResourceLock 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'Deploy read-only resource locks based on tags'
  properties: {
    displayName: 'Deploy read-only resource lock on resource groups based on tag'
    description: 'Deploy read-only resource lock on resource groups based on tag'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: policyCategory
      source: policySource
      version: '0.1.0'
      securityCenter: {
        RemediationDescription: 'The resource group should have a read-only resource locks assigned. Go to the resource group and assign a resource lock or adjust the tag value'
        Severity: 'High'
      }
    }
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag Name'
          description: 'The Tag name to audit against (i.e. Environment CostCenter etc.)'
        }
      }
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Tag Value'
          description: 'Value of the tag to audit against (i.e. Prod/UAT/TEST 12345 etc.)'
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
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Authorization/locks'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
          ]
          existenceCondition: {
            field: 'Microsoft.Authorization/locks/level'
            equals: 'ReadOnly'
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {}
                variables: {}
                resources: [
                  {
                    name: 'ReadOnly'
                    type: 'Microsoft.Authorization/locks'
                    apiVersion: '2020-05-01'
                    properties: {
                      level: 'ReadOnly'
                      notes: 'Prevent changed of the resource group or its resources'
                    }
                  }
                ]
                outputs: {
                  policy: {
                    type: 'string'
                    value: '[concat(\'Added resource lock\')]'
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

output policyDefId string = bicepDeployResourceLock.id
