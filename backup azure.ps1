$VaultResourceGroup = "MHAZMELGENRG"
$VaultName = "MHAZMELBKP01"
$VMResourceGroup = "MHAZMELPROXYRG"

New-AzureRmRecoveryServicesVault -Name "$VaultName" -ResourceGroupName "$VaultResourceGroup" -Location "Australia Southeast"
$vault1 = Get-AzureRmRecoveryServicesVault –Name "$VaultName"
Set-AzureRmRecoveryServicesBackupProperties  -Vault $vault1 -BackupStorageRedundancy GeoRedundant

Get-AzureRmRecoveryServicesVault -Name "$VaultName" | Set-AzureRmRecoveryServicesVaultContext

$schPol = Get-AzureRmRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
$retPol = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"

New-AzureRmRecoveryServicesBackupProtectionPolicy -Name "VMSnapshot45Day" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol

$retPol.DailySchedule.DurationCountInDays = 45
$Pol = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name "VMSnapshot45Day"
$retpol.IsDailyScheduleEnabled = $True
$retpol.IsWeeklyScheduleEnabled = $false
$retpol.IsMonthlyScheduleEnabled = $false
$retpol.IsYearlyScheduleEnabled = $false

Set-AzureRmRecoveryServicesBackupProtectionPolicy -Policy $Pol -SchedulePolicy $SchPol -RetentionPolicy $RetPol

$VMs = Get-AzureRMVM -resourcegroup "$VMResourceGroup"

foreach ($VM in $VMs)
{
	Enable-AzureRmRecoveryServicesBackupProtection -Policy $pol -Name "$($VM.name)" -ResourceGroupName "$($ProxyResourceGroup)"
	$namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -FriendlyName "$($VM.name)"
	$item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
	$job = Backup-AzureRmRecoveryServicesBackupItem -Item $item
}
