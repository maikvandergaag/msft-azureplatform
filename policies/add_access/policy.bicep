targetScope = 'managementGroup'

param policyCategory string = 'Custom'
param policySource string = 'Guardrails'

resource bicepRBACPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'Policy adding rights'
  properties: {
    displayName: 'Add access rights based on tags'
    policyType: 'Custom'
    mode: 'All'
    description: 'Policy to add access rights based on tags added to a resource group'
    metadata: {
      version: '1.0.0'
      category: policyCategory
      source: policySource
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
      roleId: {
        type: 'String'
        metadata: {
          displayName: 'roleId'
          description: 'roleId'
          strongType: 'Microsoft.Authorization/roleDefinitions'
        }
      }
      principalId: {
        type: 'String'
        metadata: {
          displayName: 'principalId'
          description: 'principalId'
        } }
      principalType: {
        type: 'String'
        metadata: {
          displayName: 'principalType'
          description: 'principalType'
        }
        allowedValues: [ 'Device', 'ForeignGroup', 'ServicePrincipal', 'User', 'Group' ]
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
          EvaluationDelay: 'AfterProvisioningSuccess'
          type: 'Microsoft.Authorization/locks'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
          ]
          existenceCondition: [
            {
              field: 'Microsoft.Authorization/roleAssignments/roleDefinitionId'
              equals: '[concat(\'/subscriptions/\',subscription().subscriptionId ,parameters(\'roleId\'))]'
            }
            {
              field: 'Microsoft.Authorization/roleAssignments/principalId'
              equals: '[parameters(\'principalId\')]'
            }
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              parameters: {
                principalType: {
                  value: '[parameters(\'principalType\')]'
                }
                principalId: {
                  value: '[parameters(\'principalId\')]'
                }
                roleId: {
                  value: '[parameters(\'roleId\')]'
                }
              }
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  principalType: {
                    type: 'string'
                  }
                  principalId: {
                    type: 'string'
                  }
                  roleId: {
                    type: 'string'
                  }
                }
                variables: {}
                resources: [
                  {
                    name: 'Policy_Access_Rights'
                    type: 'Microsoft.Authorization/roleAssignments'
                    apiVersion: '2020-10-01-preview'
                    properties: {
                      principalId: '[parameters(\'principalId\')]'
                      roleDefinitionId: '[parameters(\'roleId\')]'
                      principalType: '[parameters(\'principalType\')]'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}
output policyDefId string = bicepRBACPolicy.id
