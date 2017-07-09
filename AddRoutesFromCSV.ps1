$subs = import-csv \temp\subs.csv

foreach ($network in $subs)
{
    $tablename = $($network.internalname) + "Routes"
    Select-Azurermsubscription -subscriptionid "$($network.subid)"
    $VNET = get-azurermvirtualnetwork -name "$($network.vnet)" -resourcegroupname "$($network.rg)"
    $RouteTable = New-AzureRmRouteTable  -Name $tablename -ResourceGroupName "$($network.rg)" -Location $Location
    $RouteTable | Add-AzureRmRouteConfig -Name “To-internet” -AddressPrefix "0.0.0.0/0" -NextHopType VirtualAppliance -NextHopIpAddress $nexthop |  Set-AzureRmRouteTable
    Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $Vnet -Name $network.internalname -AddressPrefix $network.internal -RouteTableId $RouteTable.Id | Set-AzureRmVirtualNetwork
    foreach ($network in $subs)
    {
        If ($network.vnet -eq $Vnet.name)
        {
            write-host "Skipping routes for $($network.vnet)"                    
            }Else{
            write-host "Adding routes for $($network.internalname)" 
            $RouteTable | Add-AzureRmRouteConfig -Name “$($network.internalname)” -AddressPrefix "$($network.INTERNAL)" -NextHopType VirtualAppliance -NextHopIpAddress "10.100.0.250" |  Set-AzureRmRouteTable
            }
    }
}