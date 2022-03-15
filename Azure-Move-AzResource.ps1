<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 09/03/2022                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 1.0                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This script will move virtual machine resources (for example) from one resource group to another

.EXAMPLE
./Azure-Move-AzResource.ps1 -AzSubscription "Subscription Name" -AzResourceType "Microsoft.Compute/virtualMachines" -AzRGSource "Current-RG" -AzRGDestinaiton "New-RG"

#>

Param (
    [string] $AzSubscription = "Pay-As-You-Go",
    [string] $AzResourceType = "Microsoft.Compute/virtualMachines",
    [string] $AzRGSource = "resource-grp",
    [string] $AzRGDestination = "new-resource-grp"
)

$ResourceID = Get-AzResource -ResourceGroupName $AzRGSource -ResourceType $AzResourceType | Format-list -Property ResourceId
foreach ($VM in $ResourceID){
    Move-AzResource -DestinationResourceGroupName $AzRGDestination -ResourceId $VM.ResourceId
}