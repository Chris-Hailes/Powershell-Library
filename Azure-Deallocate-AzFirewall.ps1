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
#Set Az Context to Subscription
Set-AzContext -Subscription $subscription

#Set the Azure Firewall Variable
$azfw = Get-AzFirewall -Name $firewallname -ResourceGroupName $resourcegroup
#Add the Deallocate
$azfw.Deallocate()
#Apply the Deallocation
Set-AzFirewall -AzureFirewall $azfw