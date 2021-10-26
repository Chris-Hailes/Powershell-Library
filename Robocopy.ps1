<#
.DESCRIPTION
 Robocopy script
 
 /MIR specifies that Robocopy should mirror the source directory and the destination directory. 
 /Z ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting.
 /XA:H makes Robocopy ignore hidden files, usually these will be system files that we're not interested in.
 /R:5 rety failed read/writes 5 times before moving on
 /W:5 reduces the wait time between failures to 5 seconds instead of the 30 second default.
 /tee Write output to console and logfile
 /log Log output to logfile and overwrite on executions

Once the robocopy completes the script will send an email with summary of log and include errors into the body

.NOTES
 AUTHOR: Chris Hailes (cubesys)
#>


$EmailFrom = ''
$EmailTo = 'chris.hailes'
$SMTPServer = 'smtp.office365.com'
$ServerPort = 587
$encrypted = Get-Content c:\scripts\encrypted_password.txt | ConvertTo-SecureString
$SMTPCredentials = New-Object System.Management.Automation.PsCredential("", $encrypted) 
$EmailBody = "<br />"

$sourcedir = 'D:\SourceDir'
$destinationdir = 'D:\DestDir'
$logfile = 'C:\scripts\robolog.txt'

$Start = Get-Date

robocopy $sourcedir $destinationdir /MIR /Z /XA:H /R:5 /W:5 /tee /log:$logfile

$Stop = Get-Date
$TimeTaken = ($Stop - $Start).TotalMinutes

#Function Send Email
Function Send-Notification($EmailSubject,$EmailBody)
{
    Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject -Body $EmailBody -BodyAsHtml -SmtpServer $SMTPServer -Credential $SMTPCredentials -Port $ServerPort -UseSsl
}

$logsummary = (Get-Content $logfile | Select -Last 14) -join "<br />"
$logerrors = (Get-Content $logfile | Select-String -Pattern "ERROR" -SimpleMatch) -join "<br />"
$EmailBody += "Summary <br /> $($logsummary) <br />"
$EmailBody += "Time Taken: $($TimeTaken) Minutes <br />"
$EmailBody += "Error Paths <br /> $($logerrors) <br /> <br />"

$EmailSubject = "Robocopy Report"

Send-Notification $EmailSubject $EmailBody