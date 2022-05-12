param vnetName string
param virtualNetwork_CIDR string


param Location string = resourceGroup().location
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetwork_CIDR
      ]
    }
  }
}

param subnet1_CIDR string
resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${vnetName}/subnet1'
  properties: {
    addressPrefix: subnet1_CIDR
    privateEndpointNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    virtualNetwork
  ]
}

param subnet2_CIDR string
resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${vnetName}/subnet2'
  properties: {
    addressPrefix: subnet2_CIDR
  
  }
  dependsOn: [
    virtualNetwork
  ]
}

output VnetId string = virtualNetwork.id
output Subnet1Id string = subnet1.id//'${vnetwork.id}/subnets/${subnet1.name}'
output Subnet2Id string = subnet2.id//'${vnetwork.id}/subnets/${subnet2.name}'


