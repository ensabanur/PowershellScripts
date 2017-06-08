
#Connect to Office 365
connect-msolservice

#Variables
$Userloc = "AU"
$domain = Read-host "What is the domain?"

#Questions
$fname = Read-Host "what is the user's first name?"
$lname = Read-Host "what is the user's last name?"
$phone = Read-Host "what is the user's phone number?"
$title = Read-Host "what is the user's job title?"
$office = Read-Host "what office will the user be located in?"
$email = "$($fname).$($lname)@$($domain)"

#Create account
New-MsolUser -DisplayName "$($fname) $($lname)" -FirstName "$($fname)"  -LastName "$($lname)"  -UserPrincipalName "$($email)" -UsageLocation $($Userloc) -Office "$($office)" -PhoneNumber "$($phone)" -Title "$($title)"

#select license
$premium =  "reseller-account:O365_BUSINESS_PREMIUM"
$essentials = "reseller-account:O365_BUSINESS_ESSENTIALS"
$ems = "reseller-account:EMS"


While (($licenseanswer -notlike "p") -and ($licenseanswer -notlike "e") -and ($licenseanswer -notlike "n"))
    {

    $licenseanswer = read-host "What type of license - (P)remium or (E)ssentials or (N)o License"
        
        if ($licenseanswer -eq "p")
            {
                Set-MsolUserLicense -UserPrincipalName "$($email)" -AddLicenses "$($premium)"
                Set-MsolUserLicense -UserPrincipalName "$($email)" -AddLicenses "$($ems)"
                Write-host "Setting Premium on $($email)"
            }
        elseif ($licenseanswer -eq "e")
            {
                Set-MsolUserLicense -UserPrincipalName "$($email)" -AddLicenses "$($essentials)"
                Set-MsolUserLicense -UserPrincipalName "$($email)" -AddLicenses "$($ems)"
                Write-host "Setting Essentials on $($email)"
            }
         elseif ($licenseanswer -eq "n")
            {
                write-host "Setting no License for $($email)"
            }
        else 
            {
                cls
                Write-host "Try Again"
            }
    }    