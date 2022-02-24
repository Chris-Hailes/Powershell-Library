<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 15/12/2021                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 0.5                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This PowerShell script is used to identify log files that are older than 12 months then upload them to AWS Glacier
 Once uploaded to Glacier the local file is deleted

#> 

#Required Modules
Import-Module AWS.Tools.Common
Import-Module AWS.Tools.EC2
Import-Module AWS.Tools.S3

#AWS Account Credential
Set-AWSCredential -ProfileName aws-profile

#Find Log Folders
$logpath = "C:\Temp"
$logfolders = Get-ChildItem -Path $logpath -Recurse | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match "Logs"}

Foreach ($folder in $logfolders){
	#Go to Directory
	CD $folder.FullName  
	#What Items in this path are older than 12 months
	$items = Get-ChildItem -Path $folder.FullName | Where-Object { $_.CreationTime -lt ((get-date).AddMonths(-12)) } 
	
		#We run a foreach to upload each item individually
		Foreach ($item in $items){
		#This upload the item to a BuckName with a "GLACIER" Storage class (for archiving purposes), its file path will be /Folder/FileName in S3
		Write-S3Object -BucketName ArchiveBucket -StorageClass GLACIER -File $item.Name -Key $item.FullName.TrimStart($logpath)
		}
	#Leave Directory
	CD \
	#Delete the file from system
	Get-ChildItem -Path $folder.FullName | Where-Object { $_.CreationTime -lt ((get-date).AddMonths(-12)) } | Remove-Item
}