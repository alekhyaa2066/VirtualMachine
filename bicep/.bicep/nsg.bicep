param Location string

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg1'
  location: Location
  properties: {
    securityRules: [
      {
        name: 'rdp'
        properties: {
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

output nsgId string = nsg.id
