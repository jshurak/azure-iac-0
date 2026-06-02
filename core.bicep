param location string = resourceGroup().location
param namePrefix string = 'js'
param ipAddressSpace string = '10.0.0.0'
param CIDR string = '/16'

@description('Subnet name (key) and prefix length for cidrSubnet newCIDR (value), e.g. Firewall: 26')
param subnets object = {
  Firewall: '26'
  Gateway: '26'
  Bastion: '26'
}


var vnetAddressPrefix = '${ipAddressSpace}${CIDR}'


module hubNetwork 'br/public:avm/res/network/virtual-network:0.9.0' = {
  params: {
    name: '${namePrefix}-hub-vnet'
    location: location
    addressPrefixes:[
      vnetAddressPrefix
    ]
    subnets: [for (subnet, i) in items(subnets): {
      name: '${subnet.key}-subnet'
      addressPrefix: cidrSubnet(vnetAddressPrefix, int(subnet.value), i)
      
    }]
  }
}

