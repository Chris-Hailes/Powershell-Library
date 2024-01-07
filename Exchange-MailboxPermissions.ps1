<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 27/08/2023                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 0.5                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This PowerShell script is used to Bulk add Full Access and Send As Permissions to exchange online mailboxes

.EXAMPLE
 
#> 

#Required Modules
try {
    Import-Module ExchangeOnlineManagement
} 
catch {
    Write-Host "Exchange Online Management module required, installing"
    Install-Module ExchangeOnlineManagement
}

#Connecting to Exchange Online
Connect-ExchangeOnline

<#
CSV file requires the following fields

SharedMailbox,DelegateUser,AccessRightsDirec
Helpdesk,Chris.Hailes,FullAccess
Helpdesk,Chris.Hailes,SendAs

#>
Import-Csv .\sharedmailbox.csv | ForEach-Object {
if ($_.AccessRights -eq "SendAs"){
Add-RecipientPermission -Identity $_.SharedMailbox -Trustee $_.DelegateUser -AccessRights 'SendAs' -Confirm:$false
}
if ($_.AccessRights -eq "FullAccess"){
Add-MailboxPermission -Identity $_.SharedMailbox -User $_.DelegateUser -AccessRights $_.AccessRights -InheritanceType All
}
}