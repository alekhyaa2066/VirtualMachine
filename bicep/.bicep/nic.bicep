param subnet1Id string
param Location string
param nsgId string

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: 'vm1-nic'
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet1Id
          }
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'vm1-publicIpAddress'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

output nicId string = nic.id
