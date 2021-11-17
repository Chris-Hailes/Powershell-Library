<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 11/11/2021                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 1.0                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This PowerShell script is used to inspect DFS Shares and provide list out all the shared folders
 
 It can then export those results into a CSV

#> 

Write-Progress "Getting all DFS folders for $DFSPath (this can take a very long time)" -PercentComplete -1
$DFSTree = Get-DfsnFolder -Path "\\DOMAIN.LOCAL\DFSNShare\*"

$i = 1
$DFSTree | ForEach-Object{
    Write-Progress "Getting DFS Folder Targets for $($_.Path)" -PercentComplete (($i / $DFSTree.Count) *100)
    
    $DFSTargets = @(Get-DfsnFolderTarget $_.Path | Select Path,TargetPath,State)

    foreach ($DFSTarget in $DFSTargets){
        $Result = [ordered]@{
            Path = $DFSTarget.Path
            TargetPath = $DFSTarget.TargetPath
            State = $DFSTarget.State
            "ValidFrom_$Env:ComputerName" = Test-Path $DFSTarget.Path
        }
        New-Object PSObject -Property $Result
    }
    $i++

} | Sort Path | Export-Csv "DFS-$(Get-Date -format yyyy-MM-dd).csv" -NoTypeInformation