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
 This script will deallocate an Azure Firewall, this is useful when first deploying azure firewalls
 Deallocating the firewall allows it to be deployed and configured without incurring costs.

.EXAMPLE
Azure-Deallocate-AzFirewall -Subscription "Subscription Name" -FirewallName "AzureFW" -ResourceGroup "firewall-RG"

#>

#Parameters
Param (
    [string] $Subscription = "Hub Subscription",
    [string] $FirewallName = "AzureFW",
    [string] $ResourceGroup = "firewall-rg"
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
    If ($AzCon.Name -ne $Subscription){
        Write-Verbose "Setting Azure Context - Subscription Name: $Subscription"
        $azSub = Get-AzSubscription -SubscriptionName $Subscription
        Set-AzContext $azSub.id | Out-Null
    }    
}
Catch {
    Write-Warning "Cannot set Azure context. Please check your Azure subscription name. Exiting!"
    Break
}

#Set the Azure Firewall Variable
$azfw = Get-AzFirewall -Name $firewallname -ResourceGroupName $resourcegroup
#Add the Deallocate
$azfw.Deallocate()
#Apply the Deallocation
Set-AzFirewall -AzureFirewall $azfw