targetScope = 'subscription'

@description('The location of the resource group.')
param location string = 'eastus2'

@description('The prefix of the resource group.')
param prefix string = 'js'

resource coreResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${prefix}-core-rg'
  location: location
}

