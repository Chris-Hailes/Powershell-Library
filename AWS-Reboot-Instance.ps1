<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 23/02/2022                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 0.5                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This PowerShell script is used reboot a AWS instance and is used in task scheduler

#> 

# Required Modules
Import-Module AWS.Tools.Common
Import-Module AWS.Tools.EC2

# AWS Account Credential
Set-AWSCredential -ProfileName npsmlp

# Get all EC2 Instances
$ec2List = Get-EC2Instance
# Get EC2 Instance Tags
$ec2listtags = $ec2List.Instances | Where-Object {($_ | Select-Object -ExpandProperty tags )}

# Create Array of EC2 Instances with Names and InstanceIDs
$ec2DetailsList = $ec2listtags | ForEach-Object {
    $properties = [ordered]@{
    Name         = ($_ | Select-Object -ExpandProperty tags | Where-Object -Property Key -eq Name).value
    InstanceID    = $_.InstanceId
    }
    New-Object -TypeName PSObject -Property $properties
}

# Restart the required EC2 Instance based on Instance Name
Restart-EC2Instance -InstanceId ($ec2DetailsList | Where-Object {$_.Name -eq "S-P-MLP-WEB01"}).InstanceID