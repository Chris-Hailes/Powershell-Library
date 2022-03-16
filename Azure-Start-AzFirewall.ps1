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
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourcegroup -Name $vnetname
$publicip = Get-AzPublicIpAddress -ResourceGroupName $resourcegroup -Name $pubipname
#Allocate Configuration to Azure Firewall
$azfw.Allocate($vnet, $publicip)
#Start Firewall
Set-AzFirewall -AzureFirewall $azfw