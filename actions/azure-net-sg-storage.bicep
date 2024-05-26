// We want to make use of an Azure Key Vault
// Here we are getting a key from an existing key vault
// We need to have a seperate parameters file

param resourceLocation string ='eastus'

resource appnetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'appnetwork'
  location: resourceLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'SubnetA'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'SubnetB'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]    }
}

resource app_ip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'app-ip'
  location: resourceLocation
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource app_interface 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'app-interface'
  location: resourceLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {            
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'appnetwork', 'SubnetA')
          }
          publicIPAddress: {
            id: app_ip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: app_nsg.id
    }
  }
}


resource app_nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'app-nsg'
  location: resourceLocation
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP'
        properties: {
          description: 'Allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vrk-test 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: 'vrk-test'
  scope: resourceGroup('6912d7a0-bc28-459a-9407-33bbba641c07', 'vrk-test' )
}

module vm './vm.bicep' = {
  name: 'deployVM'
  params: {
    resourceLocation: resourceLocation
    adminPassword: vrk-test.getSecret('vmpasswd')
  }
}
