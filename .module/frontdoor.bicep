//frontdoor default properties
param frontDoorName string
param backendAddress1 string
param backendAddress2 string

//WAF
param frontDoorWafName string
@allowed([
  'Prevention'
  'Detection'
])
param frontDoorWafMode string = 'Prevention'

resource frontDoor 'Microsoft.Network/frontDoors@2020-01-01' = {
  name: frontDoorName
  location: 'global'
  properties: {
    enabledState: 'Enabled'

    frontendEndpoints: [
      {
        name: 'frontEndEndpoint' 
        properties: {
          hostName: '${frontDoorName}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
          webApplicationFirewallPolicyLink: {
            id: '${frontdoorWAF.id}'
          }
        }
      }
    ]

    loadBalancingSettings: [
      {
        name: 'loadBalancingSettings'
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
    ]

    healthProbeSettings: [
      {
        name: 'healthProbeSettings'
        properties: {
          path: '/'
          protocol: 'Https'
          intervalInSeconds: 120
        }
      }
    ]

    backendPools: [
      {
        name: 'backendPool'
        properties: {
          backends: [
            {
              address: backendAddress1
              backendHostHeader: backendAddress1
              httpPort: 80
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
            {
              address: backendAddress2
              backendHostHeader: backendAddress2
              httpPort: 80
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, 'loadBalancingSettings')
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, 'healthProbeSettings')
          }
        }
      }
    ]

    routingRules: [
      {
        name: 'routingRule'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, 'frontEndEndpoint')
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool:{
               id: resourceId('Microsoft.Network/frontDoors/backendPools', frontDoorName, 'backendPool')
            } 
          }
          enabledState: 'Enabled'
        }
      }
    ]
  }
}

resource frontdoorWAF 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2019-10-01' = {
  name: frontDoorWafName
  location: 'Global'
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: frontDoorWafMode
      customBlockResponseStatusCode: 403
    }
    customRules: {
      rules: [
        {
          priority: 10
          enabledState: 'Enabled'
          name: 'RateLimitRule'
          rateLimitDurationInMinutes: 1
          rateLimitThreshold: 10
          matchConditions: [
            {
              matchValue:[
                'NL'
              ]
              operator:'GeoMatch'
              matchVariable:'RemoteAddr'
              negateCondition: true
              transforms:[]
            }
          ]
          action: 'Block'
          ruleType: 'RateLimitRule'
        }
      ]
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'DefaultRuleSet'
          ruleSetVersion: '1.0'
          ruleGroupOverrides: []
          exclusions: []
        }
      ]
    }
  }
}
