
param vnetName string
param subnet1_CIDR string
resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${vnetName}/subnet1'
  properties: {
    addressPrefix: subnet1_CIDR
    networkSecurityGroup: {
      properties: {
        securityRules: [
          {
            properties: {
              protocol: '*'
              access: 'Allow'
              direction: 'Inbound'
            }
          }
          {
            properties: {
              protocol: '*'
              access: 'Allow'
              direction: 'Outbound'
            }
          }
        ]
      }
    }
  }
}

param subnet2_CIDR string
resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${vnetName}/subnet2'
  properties: {
    addressPrefix: subnet2_CIDR
  
  }
}

output Subnet1Id string = subnet1.id//'${vnetwork.id}/subnets/${subnet1.name}'
output Subnet2Id string = subnet2.id//'${vnetwork.id}/subnets/${subnet2.name}'
