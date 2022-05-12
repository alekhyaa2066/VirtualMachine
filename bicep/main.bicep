targetScope = 'subscription'
param subscriptionId string

param resourceGroupName string
param resourceGroupLocation string 
param env string
param taskName string

module rsg '.bicep/resourceGroup.bicep' = {
  scope: subscription(subscriptionId)
  name: 'vmrsg'
  params: {
    env: env
    resourceGroupLocation: resourceGroupLocation
    resourceGroupName: resourceGroupName
    taskName: taskName
  }
}

param virtualNetwork_CIDR string
param vnetName string
param subnet1_CIDR string
param subnet2_CIDR string
module vnet '.bicep/virtualNetwork.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'virtualNetwork'
  params: {
    Location: resourceGroupLocation
    subnet1_CIDR: subnet1_CIDR
    subnet2_CIDR: subnet2_CIDR
    virtualNetwork_CIDR: virtualNetwork_CIDR
    vnetName: vnetName
  }
  dependsOn: [
    rsg
  ]
}

module nsg '.bicep/nsg.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'vm1-nsg'
  params: {
    Location: resourceGroupLocation
  }
  dependsOn: [
    rsg
  ]
}

module nic '.bicep/nic.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'vm1-nic'
  params: {
    Location: resourceGroupLocation
    subnet1Id: vnet.outputs.Subnet1Id
    nsgId: nsg.outputs.nsgId
  }
  dependsOn: [
    vnet
    nsg
  ]
}

param vmName string
param adminPassword string
param adminUserName string
param vmSize string

module vm '.bicep/virtualMachine.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'windows-vm'
  params: {
    adminPassword: adminPassword
    adminUserName: adminUserName
    Location: resourceGroupLocation
    nicId: nic.outputs.nicId
    virtualMachineName: vmName
    virtualMachineSize: vmSize

  }
  dependsOn: [
    nic
  ]
}





