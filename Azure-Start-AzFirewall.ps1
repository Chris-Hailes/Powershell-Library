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
 This script will allocate the required resources and start an Azure Firewall.

.EXAMPLE
Azure-Start-AzFirewall -Subscription "Subscription Name" -FirewallName "AzureFW" -VNetName "firewall-vnet" -PubIPName "firewall-pip" -ResourceGroup "firewall-RG"

#>

#Parameters
Param (
[string] $Subscription = "Subscription Name",
[string] $FirewallName = "AzureFW",
[string] $ResourceGroup = "firewall-rg",
[string] $VnetName = "firewall-vnet",
[string] $PubIPName = "firewall-pip"
)

#Set Az Context to Subscription
Set-AzContext -Subscription $subscription

#Set the Azure Firewall Variable
$azfw = Get-AzFirewall -Name $firewallname -ResourceGroupName $resourcegroup
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourcegroup -Name $vnetname
$publicip = Get-AzPublicIpAddress -ResourceGroupName $resourcegroup -Name $pubipname
#Allocate Configuration to Azure Firewall
$azfw.Allocate($vnet, $publicip)
#Start Firewall
Set-AzFirewall -AzureFirewall $azfw