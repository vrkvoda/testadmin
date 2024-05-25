targetScope = 'subscription'

param applicationOwner string
param resourceGroupLocation string = 'eastus'
param applicationName string
param resourceGroupName string
@description('''
Tags''')
param tags object = {}



resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags:  union({
    ApplicationName: applicationName
    ApplicationOwner: applicationOwner}, tags)
}
output name string = resourceGroup.name
output id string = resourceGroup.id    
