//default
param location string = resourceGroup().location

//Define AVD deployment parameters
param hostpoolName string = 'azavd-hostpool'
param hostpoolFriendlyName string = 'MSFTPlayground Hostpool'
param appgroupName string = 'azavdag-applications'
param appgroupNameFriendlyName string = 'MSFTPlayground appication group'
param workspaceName string = 'azavdw-workspace'
param workspaceNameFriendlyName string = 'MSFTPlayground workspace'
param preferredAppGroupType string = 'Desktop'
param hostPoolType string = 'pooled'
param loadBalancerType string = 'BreadthFirst'


module avdbackplane '../../.module/avd-backplane.bicep' = {
  name: 'avdbackplane'
  params: {
    hostpoolName: hostpoolName
    hostpoolFriendlyName: hostpoolFriendlyName
    appgroupName: appgroupName
    appgroupNameFriendlyName: appgroupNameFriendlyName
    workspaceName: workspaceName
    workspaceNameFriendlyName: workspaceNameFriendlyName
    preferredAppGroupType: preferredAppGroupType
    applicationgrouptype: preferredAppGroupType
    location: location
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
  }
}
