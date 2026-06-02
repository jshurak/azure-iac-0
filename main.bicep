targetScope = 'subscription'

@description('The location of the resource group.')
param location string

@description('The prefix of the resource group.')
param namePrefix string

@allowed([
  'StandardV2_LRS'
  'StandardV2_ZRS'
])
param storageSku string

param ipAddressSpace string

param CIDR string


resource coreResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${namePrefix}-core-rg'
  location: location
}

module coreVnet 'modules/network.bicep' = {
  scope: coreResourceGroup
  params:{
    location: location
    CIDR: CIDR
    ipAddressSpace: ipAddressSpace
    namePrefix: namePrefix
  }
}

module coreKeyvault 'modules/keyvault.bicep' = {
  scope: coreResourceGroup
}

module coreStorage 'modules/storage.bicep' = {
  scope: coreResourceGroup
  params: {
    namePrefix: namePrefix
    storageSku: storageSku
  }
}
