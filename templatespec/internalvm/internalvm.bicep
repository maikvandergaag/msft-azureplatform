//virtual machine
param virtualMachineSize string = 'Standard_B2s'
param virtualMachineName string = 'azvm-pint'

//user
param adminUsername string
@secure()
param adminPassword string

//network
param nicName string = 'azvm-pint-nic-001'
param privateIP string = '11.1.*.*'

//internal networking
param localVnetName string = 'azvnet-spoke-*'
param subnetName string = 'azvnet-spoke-resources'
param networkResourceGroup string = '*-rg-vnetspoke'

module internalvm '../../.module/virtual-machine.bicep' ={
  name: 'internalvm'
  params:{
    adminPassword:adminPassword
    adminUsername:adminUsername
    virtualMachineSize: virtualMachineSize
    virtualMachineName: virtualMachineName
    nicName: nicName
    subnetId: subnet.id
    privateIP:privateIP
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${localVnetName}/${subnetName}'
  scope: resourceGroup(networkResourceGroup)
}
