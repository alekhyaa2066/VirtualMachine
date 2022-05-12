targetScope = 'subscription'

param resourceGroupName string
param resourceGroupLocation string
param env string
param taskName string

resource task2rsg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: {
    Environment : env
    Task : taskName
  }
}
