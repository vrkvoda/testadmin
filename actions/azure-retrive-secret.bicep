resource vrk-test 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: 'vrk-test'
  scope: resourceGroup('9a27c78d-4bce-4d49-bfcd-27a8996671aa', 'vrk-test' )
}
var secretValue = vrk-test.getSecret('vmpasswd').value

output secretValue string = secretValue
