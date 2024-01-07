## Connect to AzureAD
Connect-AzureAD

## Parameters 
param (
    [string] $applicationDisplayName = "EntraID-Test-App", #This is the name of the application
    [string] $applicationCustomKeyIdentifier = "Access Key", #This is the customkeyidentifier for the application password
    [string] $vaultName = "Az-KV01", #This is the name of the vault
    [string] $keyVaultSecretName = "application-key" #This is the name of the secret in the vault
)


## Create the Key (Secret)
try{
    $AADApp = Get-AzureADApplication -Filter "DisplayName eq $applicationDisplayName"
    $AADAppKey = New-AzureADApplicationPasswordCredential -ObjectId $AADApp.ObjectId -CustomKeyIdentifier "Access Key" -EndDate (get-date).AddYears(1)
}catch{
    Write-Output "There was an error generating a new key for the application"
    Write-Output "Things to check: application display name is '$applicationDisplayName'"
    Write-Output $_
}

$keyValue = $AADAppKey.Value
$expiry = $AADAppKey.EndDate

## Convert Secret to Secure String

try{
    $secretvalue = ConvertTo-SecureString $keyValue -AsPlainText -Force
}
catch{
    Write-Output "There was an error generating a secret value for the new app key value"
    Write-Output "Things to check: the new key is of a type that can be converted to a secure string"
    Write-Debug "The value to be converted to a secure string is: $keyValue"
    Write-Output $_
}

## Update a KeyVault Secret

try{
    $secret = Set-AzKeyVaultSecret -VaultName $vaultname -Name $keyVaultSecretName -SecretValue $secretvalue -Expires $expiry
}
catch{
    Write-Output "There was an error saving the secret value to the key vault"
    Write-Output "Things to check: vault name is $vaultname, the secret key name in the keyvault is $keyVaultSecretName, the expiry is $expiry"
    Write-Output $_
}

## View the Plain Text Key Value

$updatedsecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $keyVaultSecretName -AsPlainText

$finalText = "failed to"
if($secretvalue -eq $updatedsecret){
    $finalText = "successfully"
}

Write-Output "The code has $finalText updated the key vault value. For more info check debugs"
Write-Debug "The new Application Password: $keyValue"
Write-Debug "The updated secret in the keyvault: $updatedsecret" 
