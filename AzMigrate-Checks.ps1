<#
AzMigrate-Checks.ps1
 
 
.NOTES
+---------------------------------------------------------------------------------------------+
| ORIGIN STORY                                                                                |
+---------------------------------------------------------------------------------------------+
|   DATE        : 22/11/2023                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      |
|   CONTRIBUTOR : Josh Bennett (cubesys), Dan Burton (cubesys)                                |
|   VERSION     : 1.2                                                                         |
+---------------------------------------------------------------------------------------------+
 
.SYNOPSIS
 This script complete pre or post checks for windows services, events logs used when completing Migrations to Azure.
 
.EXAMPLE
AzMigrate-Checks -Scenario pre -Servers Server01,Server02,Server03
AzMigrate-Checks -Scenario post -Servers Server01,Server02,Server03
 
#>
 
param (
    [Parameter(Mandatory=$true,
                HelpMessage="Computer Name being checked")]
    [string[]]$Servers,
    [Parameter(Mandatory=$true,
                HelpMessage="Are you running Pre or Post Migration Checks")]
    [ValidateSet('pre','post')]
    [string]$Scenario
)
 
## Pre-Migration Scripts
if ($scenario -eq 'pre'){
    $files = $Servers.Count * 5 +1
    Write-Progress -Activity "Pre-Migration Scripts" -Status "Starting" -PercentComplete 0
    $completedFiles = 0
    foreach ($ComputerName in $Servers){
        Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Testing Ping" -PercentComplete ($completedFiles/$files*100)
        $test = Test-NetConnection -ComputerName $ComputerName
        if($test.PingSucceeded -eq $false){
            Write-Warning "$ComputerName Ping Failed"
            $completedFiles+=5
            Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Ping Failed" -PercentComplete( $completedFiles/$files*100)
            continue
        }
        Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Checking Output Folders" -PercentComplete ($completedFiles/$files*100)
        ## Check for outputs folder and create if not exist
        if (!(Test-Path C:\Migration\$ComputerName)){
            Write-Host $ComputerName "- Creating Outputs Folder"
            New-Item -ItemType Directory -Force -Path C:\Migration\$($ComputerName) | Out-Null
        }
        $completedFiles++
        Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Gathering Service Status" -PercentComplete ($completedFiles/$files*100)
        try{
            ## Get the Current Service Status of Computer
            Get-WmiObject -ComputerName $ComputerName Win32_Service | Select-Object Name, StartMode, State, Status, StartName | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PreMigration-Services.csv"
        }catch{
            Write-Warning "PreMigration-Services.csv failed to be created"
            $completedFiles+=4
            Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Gathering Service Status Failed" -PercentComplete ($completedFiles/$files*100)
            continue
        }
        $completedFiles++
        Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Gathering Curernt Disk Layout" -PercentComplete( $completedFiles/$files*100)
       
        ## Get the Current Disk  layout of Computer
        Get-WmiObject -ComputerName $ComputerName Win32_logicaldisk | Select-Object DeviceID,VolumeName,@{Name="Size (GB)";Expression={$_.size/1GB}} | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PreMigration-Disks.csv"
        $completedFiles++
        Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Gathering Event Log (System) Data" -PercentComplete ($completedFiles/$files*100)
       
        ## Get the Current System Event Log (Up to 1000 events) of Computer
        Get-WinEvent -ComputerName $ComputerName -LogName System -MaxEvents 1000 | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PreMigration-SystemLog.csv"      
        $completedFiles++
        Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Gathering Event Log (App) Data" -PercentComplete ($completedFiles/$files*100)
       
        ## Get the Current Application Event Log (Up to 1000 events) of Computer
        Get-WinEvent -ComputerName $ComputerName -LogName Application -MaxEvents 1000 | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PreMigration-AppLog.csv"  
        $completedFiles++
        Write-Progress -Activity "Pre-Migration Scripts" -Status "Processing: $ComputerName --Finishing" -PercentComplete ($completedFiles/$files*100)
           
    }
    $completedFiles++
    Write-Progress -Activity "Pre-Migration Scripts" -Status "Finished" -PercentComplete ($completedFiles/$files*100)
}
 
## Post-Migration Scripts
    if ($scenario -eq 'post'){
        $files = $Servers.Count * 4 + 1
        Write-Progress -Activity "Post-Migration Scripts" -Status "Starting" -PercentComplete 0
        $completedFiles = 0
        $flag = $true
        foreach ($ComputerName in $Servers){
            Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName --Testing Ping" -PercentComplete ($completedFiles/$files*100)
            $test = Test-NetConnection -ComputerName $ComputerName
            if($test.PingSucceeded -eq $false){
                Write-Warning "$ComputerName Ping Failed"
                $completedFiles+=4
                Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName --Ping Failed" -PercentComplete ($completedFiles/$files*100)
                continue
            }      
 
            Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName --Checking Outputs Folder" -PercentComplete ($completedFiles/$files*100)
            if (!(Test-Path C:\Migration\$ComputerName)){
                Write-Host $ComputerName "- Creating Outputs Folder"
                New-Item -ItemType Directory -Force -Path C:\Migration\$($ComputerName) | Out-Null
                Write-Warning "The Compare Step Will Not Run since Pre-Migration-Services.csv doesn't exist yet"
                $flag = $false    
            }
            $completedFiles++
            Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName --Gathering Service Status" -PercentComplete ($completedFiles/$files*100)
            try{
                ## Get the Current Service Status of Computer
                Get-WmiObject -ComputerName $ComputerName Win32_Service | Select-Object Name, StartMode, State, Status, StartName | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PostMigration-Services.csv"
            }catch{
                Write-Warning "PostMigration-Services.csv failed to be created"
                $completedFiles+=3
                Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName --Gathering Service Status Failed" -PercentComplete ($completedFiles/$files*100)
                continue
            }
            Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName --Gathering Event Log (System) Data" -PercentComplete ($completedFiles/$files*100)
            ## Get the Current System Event Log (Up to 1000 events) of Computer
            Get-WinEvent -ComputerName $ComputerName -LogName System -MaxEvents 1000 | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PostMigration-SystemLog.csv"
            $completedFiles++
            Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName --Gathering Event Log (App) Data" -PercentComplete ($completedFiles/$files*100)
            ## Get the Current Application Event Log (Up to 1000 events) of Computer
            Get-WinEvent -ComputerName $ComputerName -LogName Application -MaxEvents 1000 | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PostMigration-AppLog.csv"
            $completedFiles++
            Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName --Finishing" -PercentComplete ($completedFiles/$files*100)
            #$flag will be false if the folder name didn't exist from the pre migration run
            if($flag){
            #Complete a compare from pre to post services status
            try{
                $PreCSV = Import-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PreMigration-Services.csv"
            }catch{
                Write-Warning "FAILED CSV-File Import: C:\Migration\$($ComputerName)\$($ComputerName)-PreMigration-Services.csv"
                $flag = $false
            }
            try{
                $PostCSV = Import-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PostMigration-Services.csv"
            }catch{
                Write-Warning "FAILED CSV-File Import: C:\Migration\$($ComputerName)\$($ComputerName)-PostMigration-Services.csv"
                $flag = $false
            }  
                if($flag){
                    $csvoutput = Compare-Object $PreCSV $PostCSV -property Name,State
                    if ($csvoutput -eq $null){
                        Write-Host "$ComputerName - All Services validated against the PRE check successfully"
                    }else{
                        if($csvoutput.SideIndicator -eq "=>"){
                            Write-Warning "$ComputerName - Services validated against the PRE check has errors in Pre Check"
                            $csvoutput | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PostMigration-ServicesOutcome.csv"
                        }else{
                            Write-Warning "$ComputerName - Services validated against the POST check has errors in Post Check"
                            $csvoutput | Export-CSV "C:\Migration\$($ComputerName)\$($ComputerName)-PostMigration-ServicesOutcome.csv"
                        }
                    }
                }  
            }
            $completedFiles++
            Write-Progress -Activity "Post-Migration Scripts" -Status "Processing: $ComputerName" -PercentComplete ($completedFiles/$files*100)
        }
        $completedFiles++
        Write-Progress -Activity "Post-Migration Scripts" -Status "Finished" -PercentComplete ($completedFiles/$files*100)
}