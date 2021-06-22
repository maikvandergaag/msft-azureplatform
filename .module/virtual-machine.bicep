//default
param location string = resourceGroup().location

//virtual machine
param virtualMachineSize string = 'Standard_B2s'
param osDiskType string = 'Standard_LRS'
param virtualMachineName string = 'azvm-pint'

//user
param adminUsername string
@secure()
param adminPassword string

//network
param nicName string = 'azvm-pint-nic-001'
param subnetId string
param privateIP string

// This is the virtual machine that you're building.
resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: virtualMachineName
  location: location
  properties: {
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '21h1-pro'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk:{
          storageAccountType: osDiskType
        }
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: nic.id
        }
      ]
    }
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: privateIP
        }
      }
    ]
  }
}


