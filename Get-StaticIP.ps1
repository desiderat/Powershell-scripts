Import-Module ActiveDirectory

Function DigitToStrIPAddress($Digit9IPAddress)
{
	$bin=[convert]::ToString([int32]$Digit9IPAddress,2).PadLeft(32,'0').ToCharArray()
	$A=[convert]::ToByte($bin[0..7] -join "",2)
	$B=[convert]::ToByte($bin[8..15] -join "",2)
	$C=[convert]::ToByte($bin[16..23] -join "",2)
	$D=[convert]::ToByte($bin[24..31] -join "",2)
	return $($A,$B,$C,$D -join ".")
} 

$ForestInfo = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$Domains = $ForestInfo.Domains
$all = @()

foreach ($Domain in $Domains)
{
#	Write-Host ('Process domain: ' + $Domain.Name) -foregroundcolor green

	$users = get-aduser -Server $Domain.Name -filter * -Properties 'msRADIUSFramedIPAddress' | ? { $_.msRADIUSFramedIPAddress -ne $null } 

	foreach( $user in $users)
	{
		$ip = DigitToStrIPAddress($user.msRADIUSFramedIPAddress)
#		Write-Host ($user.SamAccountName + "		" + $ip)

		$result = new-object psobject
		$result | add-member noteproperty Name $user.Name
		$result | add-member noteproperty UserPrincipalName $user.userPrincipalName
		$result | add-member noteproperty sAMAccountName $user.SamAccountName
		$result | add-member noteproperty IP $IP

		$all += $result
	}

}

$all