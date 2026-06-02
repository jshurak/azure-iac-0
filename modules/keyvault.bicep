param namePrefix string = 'js'
param location string = resourceGroup().location

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  params: {
    name: '${namePrefix}-kevyault'
    enableRbacAuthorization: true
    enableVaultForTemplateDeployment: true
    location: location
  }
}
