import-module ActiveDirectory

#.$Env:ExchangeInstallPath\bin\RemoteExchange.ps1
#Connect-ExchangeServer -auto
#Set-ADServerSettings -ViewEntireForest:$true

#Set variable
$ForestInfo = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$Domains = $ForestInfo.Domains
#$InactiveDays60 = (New-TimeSpan -days 60)
$LastLogonTimeMark90 = ((get-date) - (New-TimeSpan -days 90))
$LastLogonTimeMark180 = (get-date) - (New-TimeSpan -days 180)
$LastLogonTimeMark360 = (get-date) - (New-TimeSpan -days 360)

#$logFilePath = 'c:\scripts\log.txt'
$usersFilePath = 'c:\scripts\users.txt'
$computersFilePath = 'c:\scripts\computers.txt'


$OldUsers = New-Object System.Collections.ArrayList

foreach ($Domain in $Domains)
{
	Write-Host ('Process domain: ' + $Domain.Name)
	$users = Get-ADUser -Server $Domain -Properties lastLogontimeStamp, msExchWhenMailboxCreated, homeMDB -Filter *

    #$users.Count
	foreach ($user in $users)
	{
		if ( ($user.DistinguishedName -notlike "*OU=Technical Users*") -and ($user.DistinguishedName -notlike "*OU=*Admins*" ) -and ($user.DistinguishedName -notlike "*OU=*Usable*" ) -and ($user.msExchWhenMailboxCreated -notlike '') )
		{	
			if ([DateTime]::FromFileTime($user.LastLogonTimestamp) -lt  $LastLogonTimeMark90 )
			{#Пользователь не логинился последние 90 дней
                if ($user.homeMDB -notlike '' -and $user.homeMDB -notlike 'CN=TempMDB01,CN=Databases,CN=Exchange Administrative Group (FYDIBOHF23SPDLT),CN=Administrative Groups,CN=Volia,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=co,DC=volia,DC=com' )
                {
                        $OldUsers.Add($user)
				        Write-Host ( $user.Name + ' - ' + [DateTime]::FromFileTime($user.LastLogonTimestamp) + ' - ' + $user.homeMDB.Substring($user.homeMDB.IndexOf("=")+1,$user.homeMDB.IndexOf(",")-$user.homeMDB.IndexOf("=")-1 ))
                }
			}
		}
	}
}
$OldUsers.Count

$OldUsers | export-csv C:\scripts\users.csv -NoTypeInformation -Encoding UTF8
