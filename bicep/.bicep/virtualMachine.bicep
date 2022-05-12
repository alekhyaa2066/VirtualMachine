param nicId string
param Location string
param virtualMachineName string
param adminUserName string
param adminPassword string
param virtualMachineSize string
resource windowsVm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'vm1'
  location: Location
  properties: {
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUserName
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
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: nicId
        }
      ]
    }
  }

}
