##START#
#CONNECT ###############################
Connect-MicrosoftTeams
Connect-MsolService

#GET DATA ##############################
$UsersLineURI = Get-CsOnlineUser -Filter {LineURI -ne $Null} #TODO: select statement to reduce data size
$OnlineApplicationInstanceLineURI = Get-CsOnlineApplicationInstance | where {$_.PhoneNumber -ne $Null} #TODO: select statement to reduce data size
$usersWithRoomLicences = (Get-MsolUser | where {$_.Licenses.AccountSkuId -match "Microsoft_Teams_Rooms*"}) #TODO: select statement to reduce data size
$numbers = Get-CsPhoneNumberAssignment

#RUN SCRIPT############################

$UsersLineURI = Get-CsOnlineUser -Filter {LineURI -ne $Null} #TODO: select statement to reduce data size
$phonenumbers = Get-CsPhoneNumberAssignment

foreach ($number in $numbers) {
    if ($number.PstnAssignmentStatus -eq "UserAssigned" -and $number.TelephoneNumber -match '^\+\d+;ext=\d+$') {
        $userMatch = $UsersLineURI | where {$_.Identity -eq $number.AssignedPstnTargetId}
        Write-Host "***********************************************************************"
        Write-Host "Processing User Number: " $number.TelephoneNumber -ForegroundColor Yellow
        Write-Host "For user: "$userMatch.DisplayName " ("$userMatch.UserPrincipalName")"  -ForegroundColor Yellow
        $strippedNumber = $number.TelephoneNumber -replace ';ext=\d+$'
        Write-Host "Number without Extension is " $strippedNumber -ForegroundColor Green
        Set-CsPhoneNumberAssignment -Identity $userMatch.UserPrincipalName -PhoneNumber $strippedNumber -PhoneNumberType DirectRouting
    }
}
