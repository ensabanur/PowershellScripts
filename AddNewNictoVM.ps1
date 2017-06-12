### 	Add New Nic to Azure RM VM 		###
###						###
###	This will REBOOT your vm		###
###						###
###################################################

#Variables
$VMname = "MyVM"
$VMRG =  "VMResourceGroup"
$NICName = "NewNic"
$NICRG = "NICResourceGroup"
$VNetName = "VnetName"
$subnetname = "SubnetName"
$VnetRG = "VnetResourceGroup"
$Location = "Australia East"

#Get the subnet ID	
	$Subnets = Get-AzureRmVirtualNetwork -Name "$($VnetName)" -ResourceGroupName "$($VNetRG)" | Get-AzureRmVirtualNetworkSubnetConfig
	$subnetID = $subnets.id | ?{$_ -like "*$($subnetname)*"}

#Create the NIC
	$NewNic = New-AzureRmNetworkInterface -name "$($NicName)" -ResourceGroupName "$($NicRG)" -Location "$($Location)" -SubnetId "$($SubnetID)"

#Get the VM
	$VM = Get-AzureRmVM -Name $VMname -ResourceGroupName $VMRG

#Add the second NIC
	$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $NewNIC.Id

# Show the Network interfaces so we can see secondary in the config
	$VM.NetworkProfile.NetworkInterfaces

#Set the original Nic as primary	
	$VM.NetworkProfile.NetworkInterfaces[0].Primary = $true

#Stop the VM
	$VM | Stop-AzureRMVM -force -confirm:$false

#Update the VM configuration (The VM will be restarted)
Update-AzureRmVM -VM $VM -ResourceGroupName $VMRG

#Start the VM
	$VM | Start-AzureRMVM
