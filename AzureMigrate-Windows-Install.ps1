<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 20/09/2023                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 0.5                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This PowerShell script is used to complete Unified Mobility Agent installation for Azure Migrate. This script should be executed under an Administrator PowerShell context

#>

#Install
Write-Host "Extracting Installer Files"
\\10.49.1.9\AzMigrate\MobilityServiceInstaller.exe /q /x:C:\AzMigrate\Extracted
Sleep 10
IF (Test-Path C:\AzMigrate\Extracted){
    try {
    Write-Host "Moving to Installer Files"
    cd C:\AzMigrate\Extracted -ErrorAction Stop
    }
    catch {
    Write-Host -ForegroundColor Red "ERROR - Manual Intervention Required"
    Write-Host $_
    }
    Write-Host "Installing Replication Agent"
    .\UnifiedAgent.exe /Role "MS" /Silent  /CSType CSLegacy
    Write-Host "Copying required replication passphrase"
    Copy-Item \\10.49.1.9\AzMigrate\connection.passphrase "C:\Program Files (x86)\Microsoft Azure Site Recovery\agent"
    Remove-Item C:\Users\Public\Desktop\hostconfigwxcommon.lnk
} else {
    Sleep 30
    try {
    Write-Host "Moving to Installer Files"
    cd C:\AzMigrate\Extracted -ErrorAction Stop
    }
    catch {
    Write-Host -ForegroundColor Red "ERROR - Manual Intervention Required"
    Write-Host $_
    }
    Write-Host "Installing Replication Agent"
    .\UnifiedAgent.exe /Role "MS" /Silent  /CSType CSLegacy
    Write-Host "Copying required replication passphrase"
    Copy-Item \\10.49.1.9\AzMigrate\connection.passphrase "C:\Program Files (x86)\Microsoft Azure Site Recovery\agent"
    Remove-Item C:\Users\Public\Desktop\hostconfigwxcommon.lnk
}

#Configuration
Write-Host "Moving to Agent Installation Location"
cd "C:\Program Files (x86)\Microsoft Azure Site Recovery\agent"
Write-Host "Configuring Windows Agent"
.\UnifiedAgentConfigurator.exe  /CSEndPoint 10.49.1.9 /PassphraseFilePath connection.passphrase

#Clean Up
Write-Host "Removing Installer Files"
Remove-Item -Recurse C:\AzMigrate\