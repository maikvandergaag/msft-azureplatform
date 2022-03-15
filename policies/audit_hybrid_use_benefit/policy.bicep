targetScope = 'managementGroup'

param policyCategory string = 'Custom'
param policySource string = 'Guardrails'

resource bicepAuditPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'audit hybrid use benefit'
  properties: {
    displayName: 'Audit hybrid use benefit'
    description: 'Auditing of VMs without the Hybrid use benefit'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: policyCategory
      source: policySource
      version: '0.1.0'
      securityCenter: {
        RemediationDescription: 'Check the possibility of using Hyrbid Benefit'
        Severity: 'Low'
      }
    }
    parameters: {}
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            in: [
              'Microsoft.Compute/virtualMachines'
              'Microsoft.Compute/VirtualMachineScaleSets'
            ]
          }
          {
            field: 'Microsoft.Compute/licenseType'
            notEquals: 'Windows_Server'
          }
        ]
      }
      then: {
        effect: 'audit'
      }
    }
  }
}

output policyDefId string = bicepAuditPolicy.id
