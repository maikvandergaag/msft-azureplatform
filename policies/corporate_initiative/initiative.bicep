targetScope = 'managementGroup'

param policyCategory string = 'Custom'
param policySource string = 'Guardrails'

//tag parameters
param lockTag string = 'environment'
param lockValue string = 'prd'

module auditPolicy '../audit_hybrid_use_benefit/policy.bicep' = {
  name: 'auditPolicy'
  params: {
    policyCategory: policyCategory
    policySource: policySource
  }
}

module auditResourceLock '../audit_resource_locks_on_resource_groups_based_on_tags/policy.bicep' = {
  name: 'auditResourceLock'
  params: {
    policyCategory: policyCategory
    policySource: policySource
  }
}

module deployResourceLock '../deploy_resource_locks_on_resource_groups_based_on_tags/policy.bicep' = {
  name: 'deployResourceLock'
  params: {
    policyCategory: policyCategory
    policySource: policySource
  }
}

resource corporateInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'corporate_initiative'
  properties: {
    policyType: 'Custom'
    displayName: 'Corporate Initiative'
    description: 'Corporate Initiative containing all corporate guardrails'
    metadata: {
      category: policyCategory
      source: policySource
      version: '0.1.0'
    }
    parameters: {}
    policyDefinitions: [
      {
        policyDefinitionId: auditPolicy.outputs.policyDefId
        parameters: {}
      }
      {
        policyDefinitionId: auditResourceLock.outputs.policyDefId
        parameters: {
          tagName: {
            value: lockTag
          }
          tagValue: {
            value: lockValue
          }
        }
      }
      {
        policyDefinitionId: deployResourceLock.outputs.policyDefId
        parameters: {
          tagName: {
            value: lockTag
          }
          tagValue: {
            value: lockValue
          }
        }
      }
    ]
  }
}
