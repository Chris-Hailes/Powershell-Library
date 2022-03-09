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
Set-AzContext -Subscription $udr.Subscription

$RouteTable = Get-AzRouteTable -Name $udr.RouteTable

Write-Host NextHopIP = $udr.NextHopIP -ForegroundColor Green
Add-AzRouteConfig -Name $udr.RouteName -AddressPrefix $udr.RTAddressPrefix -NextHopType $udr.RTDestination -NextHopIpAddress $udr.NextHopIP -RouteTable $RouteTable -ErrorAction SilentlyContinue

Set-AzRouteTable -RouteTable $RouteTable
}