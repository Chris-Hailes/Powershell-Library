<#
.PURPOSE
    Ensure any VMs that are not deallocated are force deallocated.
    EG. Users who run personal VMs may shut them down to save costs. 
    This script will ensure they are deallocated.

.CREATEDBY
    George Zajakovski - https://www.linkedin.com/in/gzajakovski/
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$resourceGroup,
    [Parameter(Mandatory=$true)]
    [string]$hostpoolName
)

# Convert date/time stamp to AEST for Azure Runbooks that run in UTC
# EG. - Write-Output "$(GetAusTime) - Start Script."
function GetAusTime(){
$time = Get-Date
$AUStime = $Time.AddHours(11.0)
return $AusTime
}

Write-Output "$(GetAusTime) - Start Cycle"

# Find all stopped but not deallocated VMs in a RGs
$StoppedVMs = Get-AzVM -Status -ResourceGroupName $resourceGroup | where {$_.PowerState -like 'VM stopped'}

# Only run if there are more than 0 machines that need to be deallocated
If ($StoppedVMs.count -gt '0') {

    Write-Output $(GetAusTime) - "There are $($stoppedVMs.count) VMs not deallocated"

        # Loop untill each VM is force stopped
        ForEach ($VM in $StoppedVMs) {
            $Name = $VM.Name
            Write-Output $(GetAusTime) - "Deallocating $Name"
            Stop-AzVM -ResourceGroupName $resourceGroup -Name $Name -Force
        }
} else {
    # Skip and wait till next cycle to check again.
    Write-Output $(GetAusTime) - "No VMs need to be deallocated, will retry according to the run schedule." 
    exit 
}
Write-Output "$(GetAusTime) - End Cycle"


