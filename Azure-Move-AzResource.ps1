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

#! Login with Connect-AzAccount if NOT using Cloud Shell
#! Check Azure Connection
Try {
    Write-Verbose "Connecting to Azure Cloud..."
    If ($null -eq (Get-AzContext)){
        Connect-AzAccount -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
    }
}
Catch {
    Write-Warning "Cannot connect to Azure Cloud. Please check your credentials. Exiting!"
    Break
}

#! Set Azure Subscription Context
Try {
    Write-Verbose "Checking current Azure Context"
    $AzCon = Get-AzContext
    If ($AzCon.Name -ne $AzSubscription){
        Write-Verbose "Setting Azure Context - Subscription Name: $AzSubscription"
        $azSub = Get-AzSubscription -SubscriptionName $AzSubscription
        Set-AzContext $azSub.id | Out-Null
    }    
}
Catch {
    Write-Warning "Cannot set Azure context. Please check your Azure subscription name. Exiting!"
    Break
}

$ResourceID = Get-AzResource -ResourceGroupName $AzRGSource -ResourceType $AzResourceType
foreach ($VM in $ResourceID){
    Try {
        Write-Verbose "Moving Resource"
        Move-AzResource -DestinationResourceGroupName $AzRGDestination -ResourceId $VM.ResourceId -Confirm:$false
    }
    Catch {
        Write-Warning "Unable to Move Resource!"
        Break
    }
}