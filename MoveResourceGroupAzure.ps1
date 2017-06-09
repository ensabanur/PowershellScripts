#login
Login-AzureRmAccount
#Needed Variables    
	
    $workingpath = "$($env:appdata)\rgscript"
	$WorkingPathExists = Test-path "$($workingpath)"
    $TempCSV = "$($workingpath)\temp.csv"
    $logCSVpath = "$($workingpath)\log.csv"
    $subtempcsv ="$($workingpath)\subscriptions.csv"
    
    If ($TempCSVExists -eq $true)
	{
		Write-host -ForegroundColor Green "Removing old working CSV from $($Workingpath)"	
        Remove-Item -Path "$($Workingpath)\temp.csv" -Force -Confirm:$false
	}Else 
	{
		Write-host -ForegroundColor Green "No CSV Exists"        
	}
        	
	If ($WorkingPathExists -eq $true)
	{
		Write-host -ForegroundColor Green "$($workingpath) already exists.  Skipping Creation"	
	}Else 
	{
		Write-host -ForegroundColor Green "Creating $($workingpath)"	
        new-item -ItemType Directory -Path "$workingpath"
	}

#Get Subscriptions and List
$subscriptions = get-azurermsubscription
 Write-host -foregroundcolor Green "Available Subscriptions"
 $SubCount=0
	foreach ($Subscription in $subscriptions)
	{
		$SubCount++
		$SubNumber = $SubCount  
		$SubName = $Subscription.Name
        $SubID = $subscription.ID
        	$SubCSV = @()
        	$SubCSV += New-Object psobject -Property @{Number=$SubNumber;Name=$SubName;ID=$SubID}
        	$SubCSV | export-csv "$($SubTempCSV)" -Append -notype
		Write-host "[$($SubCount)] - $($SubName)"
	}

#Get the subscription
	$CSVSubs = import-csv "$SubTempCSV"
    $SubSelection = 0
	$Attempts = 0
	While (($SubSelection -lt 1) -or ($SubSelection -gt $SubCount))
		{	
			$Attempts++
			if ($Attempts -eq 1)
			{
				[int]$SubSelection = Read-host "Please select a Subscription [1] - [$($Subcount)]"
			}
            Else
			{
                [int]$SubSelection = Read-host "Are you spastic you selected $($SubSelection) which is not between [1] and [$($Subcount)]"
			}
        }
    $TargetSub = $CSVSubs | ?{$_.Number -eq $SubSelection}
    
    Select-azurermsubscription -subscriptionid $targetsub.id

#Get Resource Groups and List
	$ResourceGroups = get-azurermresourcegroup
	cls
    Write-host -foregroundcolor Green "Available Resource Groups"
    $RGCount=0
	foreach ($RG in $ResourceGroups)
	{
		$RGCount++
		$RGNumber = $RGCount  
		$RGName = $RG.ResourceGroupName
        	$CSV = @()
        	$CSV += New-Object psobject -Property @{RGNumber=$RGNumber;RGName=$RGName}
        	$CSV | export-csv "$($TempCSV)" -Append -notype
		Write-host "[$($RGCount)] - $($RGName)"
	}

#Get the Source ResourceGroup
    $CSVGroups = import-csv "$($TempCSV)"
	$SourceRGSelection = 0
	$Attempts = 0
	While (($Resources -eq $null) -or (($sourceRGSelection -lt 1) -or ($sourceRGSelection -gt $RGCount)))
		{	
			$Attempts++
			if ($Attempts -eq 1)
			{
				[int]$SourceRGSelection = Read-host "Please select a SOURCE resource group [1] - [$($RGcount)]"
			}Elseif (($Attempts -gt 1) -and ($sourcerg -eq $null))
			{
				Write-host "Are you spastic you selected $($SourceRGSelection) which is not between [1] and [$($RGcount)]"
				[int]$SourceRGSelection = Read-host "Please select a SOURCE resource group [1] - [$($RGcount)]"
			}
            $SourceRG = $CSVGRoups | ?{$_.RGNumber -eq $SourceRGSelection}
            $Resources = Get-azurermresource | ? {$_.ResourceGroupName -like "$($sourceRG.RGname)"}
            if ((($sourceRGSelection -gt 1) -and ($sourceRGSelection -le $RGCount)) -and $resources -eq $null)
            {
                [int]$SourceRGSelection = Read-host "You picked an empty resource group.  Please select a SOURCE resource group [1] - [$($RGcount)]"
                $SourceRG = $CSVGRoups | ?{$_.RGNumber -eq $SourceRGSelection}
                $Resources = Get-azurermresource | ? {$_.ResourceGroupName -like "$($sourceRG.RGname)"}
            }
		}
       
#Get the TARGET ResourceGroup
	$TargetRGSelection = 0
	$Attempts = 0
	While (($TargetRGSelection -lt 1) -or ($TargetRGSelection -gt $RGCount) -or ($TargetRGSelection -eq $sourceRGSelection))
		{	
			$Attempts++
			if ($Attempts -eq 1)
			{
				[int]$TargetRGSelection = Read-host "Please select a TARGET resource group [1] - [$($RGcount)]"
			}Elseif ($Attempts -gt 1)
			{
				if ($TargetRGSelection -eq $sourceRGSelection)
				{
					[int]$TargetRGSelection = Read-host "You're selection matches the SOURCE.  Please select a TARGET resource group [1] - [$($RGcount)]"
				}Else {
                    Write-host "Are you spastic you selected $($TargetRGSelection) which is not between [1] and [$($RGcount)]"
				    [int]$TargetRGSelection = Read-host "Please select a TARGET resource group [1] - [$($RGcount)]"
                }
			}
        }
    $TargetRG = $CSVGRoups | ?{$_.RGNumber -eq $TargetRGSelection}

#Start the Move
$Resources = Get-azurermresource | ? {$_.ResourceGroupName -like "$($sourceRG.RGname)"}

cls
Write-host -ForegroundColor Green "Moving the following resources from $($SourceRG.RGname) to $($TargetRG.RGName)"
foreach ($resource in $Resources)
	{
        Write-host -ForegroundColor Yellow "$($Resource.Name) of type $($Resource.Resourcetype)" 
	}


$proceed = $null
While (($proceed -notlike "y") -and ($proceed -notlike "n"))
{
 
	$proceed = Read-host  "Do you want to proceed? Y/N"   
}
    
if ($proceed -like "y")
{
    foreach ($resource in $Resources)
        {
		    $Today = get-date
            Write-host -ForegroundColor Green "Moving $($Resource.resourcename) from $($SourceRG.RGName) to $($TargetRG.RGName)"
            Move-AzureRmResource -DestinationResourceGroupName "$($TargetRG.RGName)" -ResourceId $resource.ResourceId -Force -Confirm:$false
            $LogCSV = @()
            $LogCSV += New-Object psobject -Property @{ResourceName="$($Resource.resourcename)";TargetResourceGroup="$($TargetRG.RGName)";SourceResourceGroup="$($SourceRG.RGName)";Time="$($Today.datetime)"}
            $LogCSV | export-csv "$($LogCSVPath)" -Append -notype
		    
	    }
}Else
    {
        cls
        Write-host "Stopping..."
    }

#remove working CSV
Remove-Item -Path $TempCSV -Force -Confirm:$false
Remove-Item -Path $SubTempCSV -Force -Confirm:$false