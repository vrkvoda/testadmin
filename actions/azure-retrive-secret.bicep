// Define an existing Key Vault resource
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: 'vrk-test'
  scope: resourceGroup('9a27c78d-4bce-4d49-bfcd-27a8996671aa', 'vrk-test')
}

// Use the getSecret function to retrieve the secret value
var secretValue = keyVault.getSecret('vmpasswd').value

// Mask the secret value to avoid exposure in logs
output secretValue string = '***' // Masking the secret value for security purposes

// If you need to use the actual secret value in a workflow or another resource, you can output it conditionally, 
// but ensure it is masked or handled securely
output actualSecretValue string = secretValue
