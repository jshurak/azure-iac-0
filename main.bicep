targetScope = 'subscription'

@description('The location of the resource group.')
param location string

@description('The prefix of the resource group.')
param namePrefix string

resource coreResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${namePrefix}-core-rg'
  location: location
}

module vnet 'modules/network.bicep' = {
  scope: coreResourceGroup
}

module kevault 'modules/keyvault.bicep' = {
  scope: coreResourceGroup
}
