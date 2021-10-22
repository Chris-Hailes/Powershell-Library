<#
    .DESCRIPTION
        Stop Virtual Machine

    .NOTES
        AUTHOR: Chris HAILES
#>

#SMTP Details
$EmailFrom = Get-AutomationVariable -Name 'SMTPFrom'
$EmailTo = Get-AutomationVariable -Name 'SMTPTo'
$SMTPServer = Get-AutomationVariable -Name 'SMTPServer'
$ServerPort = 587
$SMTPCredentials = Get-AutomationPSCredential -Name 'SMTPCredentials'
$EmailBody = "<br>"

#VM list and configuration
$VMList= Get-AutomationVariable -Name 'VMList'

$connectionName = "AzureRunAsConnection"

try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint -Subscription $servicePrincipalConnection.SubscriptionId 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


$ErrorActionPreference="Stop";
Set-StrictMode -Version 'Latest'

$Start = Get-Date

#Function Send Email
Function Send-Notification($EmailSubject,$EmailBody)
{
    Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject -Body $EmailBody -BodyAsHtml -SmtpServer $SMTPServer -Credential $SMTPCredentials -Port $ServerPort -UseSsl
}

#Stop Virtual Machine
Write-Output "Stopping VMs"; 
$EmailBody ="<p>The following VMs have been stopped: </p>"
if(!(Get-AzVM | ? {$_.Name -eq $VMList})) 
    {
        $EmailBody = "AzureVM : [$VMList] - Does not exist! - Check your inputs" 
        $EmailSubject = "VMName Error" 
        Send-Notification $EmailSubject $EmailBody
        throw " AzureVM : [$VMList] - Does not exist! - Check your inputs " 
    }
        Get-AzVM | ? {$_.Name -eq $VMList} | Stop-AzVM -Force -NoWait
        Write-Output $VMList " stopped" 
        $EmailBody += "<li> " + $VMList + "</li>"

$EmailBody += "</ br>"

$EmailSubject = "Virtual Machine successfully stopped" 
Send-Notification $EmailSubject $EmailBody

$Stop = Get-Date
$TimeTaken = ($Stop - $Start).TotalSeconds
Write-Output "The time to run this script was $TimeTaken seconds"