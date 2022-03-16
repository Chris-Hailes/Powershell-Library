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
 This script loads a CSV file into variable and then create routes in route tables.

 The CSV includes the following Stucture
 Subscription,RouteTable,RouteName,RTAddressPrefix,RTDestination,NextHopIP

.EXAMPLE
Deploy-UDR-Routes.ps1 -udrfile C:\Path\File.csv

#> 

Param (
[String] $udrfile
)

foreach ($udr in $udrfile){

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

$RouteTable = Get-AzRouteTable -Name $udr.RouteTable

Write-Host NextHopIP = $udr.NextHopIP -ForegroundColor Green
Add-AzRouteConfig -Name $udr.RouteName -AddressPrefix $udr.RTAddressPrefix -NextHopType $udr.RTDestination -NextHopIpAddress $udr.NextHopIP -RouteTable $RouteTable -ErrorAction SilentlyContinue

Set-AzRouteTable -RouteTable $RouteTable
}