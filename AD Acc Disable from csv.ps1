$users = Import-Csv "C:\temp\test1.csv" -Delimiter ';'

foreach ($user in $users)
{
  $upn = $user.UserPrincipalName
  
  Get-ADUser -server DC-KIEV0.central.co.volia.com -Filter {UserPrincipalName -eq $upn} # | Disable-ADAccount -whatif
} 
