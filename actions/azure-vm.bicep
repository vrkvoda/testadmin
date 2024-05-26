// Putting the resource of the storage account because it is referenced 
// when creating the VM

param resourceLocation string ='eastus'
@secure()
param adminPassword string
param adminUsername string

resource vmstore998995 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'vmstore998995'
  location: resourceLocation
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appvm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'appvm'
  location: resourceLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'appvm'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }      
        name: 'ubuntuOSDisk'
        caching: 'ReadWrite'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'app-interface')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(resourceId('Microsoft.Storage/storageAccounts/', toLower('vmstore998995'))).primaryEndpoints.blob
      }
    }
  }
}
