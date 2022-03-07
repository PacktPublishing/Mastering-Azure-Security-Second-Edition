New-AzResourceGroup -Name 'Packt-Encrypt' `
-Location 'EastUS'

New-AzStorageAccount -ResourceGroupName 'Packt-Encrypt' `
    -Name 'packtstorageencryption' `
    -Location 'EastUS' `
    -SkuName Standard_GRS

$storageAccount = Set-AzStorageAccount `
    -ResourceGroupName 'Packt-Encrypt' `
    -Name 'packtstorageencryption' `
    -AssignIdentity

New-AzKeyvault -name 'Pact-KV-01' `
    -ResourceGroupName 'Packt-Encrypt' `
    -Location 'EastUS' `
    -EnabledForDiskEncryption `
    -SoftDeleteRetentionInDays 7 `
    -EnablePurgeProtection

$KeyVault = Get-AzKeyVault -VaultName 'Pact-KV-01' `
-ResourceGroupName 'Packt-Encrypt'

Set-AzKeyVaultAccessPolicy `
    -VaultName $keyVault.VaultName `
    -ObjectId $storageAccount.Identity.PrincipalId `
    -PermissionsToKeys wrapkey,unwrapkey,get,recover

$key = Add-AzKeyVaultKey `
    -VaultName $keyVault.VaultName `
    -Name 'MyKey' `
    -Destination 'Software'

Set-AzStorageAccount `
    -ResourceGroupName $storageAccount.ResourceGroupName `
    -AccountName $storageAccount.StorageAccountName `
    -KeyvaultEncryption `
    -KeyName $key.Name `
    -KeyVersion $key.Version `
    -KeyVaultUri $keyVault.VaultUri