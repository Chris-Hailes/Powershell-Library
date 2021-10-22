<#
    .DESCRIPTION
        Start VM

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

#Starting Virtual Machine
If(!(Get-AzVM | ? {$_.Name -eq $VMList})) 
{
    $EmailSubject = "AzureVM - Does not exist! - Check your inputs"
    $EmailBody = "AzureVM : [$VMList] - Does not exist! - Check your inputs" 
    Write-Output "AzureVM : [$VMList] - Does not exist! - Check your inputs" 
    Send-Notification $EmailSubject $EmailBody
    throw " AzureVM : [$VMList] - Does not exist! - Check your inputs " 
}

    Write-Output "Starting VM $VMList"
    $EmailBody += "<br>VM " + $VMList + " has started"
    Get-AzVM | ? {$_.Name -eq $VMList} | Start-AzVM


 
$EmailBody += "<br><br>"
$EmailSubject = "Virtual Machine successfully started"
Send-Notification $EmailSubject $EmailBody

$Stop = Get-Date
$TimeTaken = ($Stop - $Start).TotalSeconds
Write-Output "The time to run this script was $TimeTaken seconds"