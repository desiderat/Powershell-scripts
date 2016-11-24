$users = Import-Csv "C:\scripts\MobPhone\MobileFromAd.csv" -Delimiter ';'

foreach ($user in $users)
{
  $csvmail = $user.mail
  $csvmobile = $user.telephoneNumber
  Get-ADUser -server DC-KIEV0.central.co.volia.com -Filter {mail -eq $csvmail}  | Set-ADUser -server DC-KIEV0.central.co.volia.com -telephoneNumber $csvmobile
} 
