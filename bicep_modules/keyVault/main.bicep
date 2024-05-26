targetScope = 'resourceGroup'

@allowed([
  'eastus'
  'eastus2'
  'westus'
  'westus2'
])
param Region string = 'eastus'
param KeyVaultName string = 'testkv'
param NetworkAclsAllowedIpsList array = []
param SubnetResourceIdsForServiceEndpoints array = []

@description('(Optional) SoftDelete data retention days. It accepts >=7 and <=90. Default to 90.')
param kvSoftDeleteRetention int = 90


param tags object = {}

var publicNetworkAccess = length(SubnetResourceIdsForServiceEndpoints) > 0 ? 'Enabled' : 'Disabled'

resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01'  = {
  name: KeyVaultName
  location: Region
  tags: tags
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: kvSoftDeleteRetention
    sku: {
      name: 'standard'
      family: 'A'
    }
    publicNetworkAccess: publicNetworkAccess
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
    ]
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: [for ip in NetworkAclsAllowedIpsList: {
        value: ip
      }]
      virtualNetworkRules: [for subnetResourceId in SubnetResourceIdsForServiceEndpoints: {
        ignoreMissingVnetServiceEndpoint: false
        id: subnetResourceId
      }]
    }
  }

output name string = keyvault.name
output id string = keyvault.id
