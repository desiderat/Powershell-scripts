$data = import-csv c:\temp\test.csv
Import-Module activedirectory

foreach ($line in $data)
{

    $upn = $line.UPN
#    $name = $line.name
 
 $user = Get-ADUser -filter {UserPrincipalName -eq $upn}

# if ($user -ne $null)
#    {
#      $user | Disable-ADAccount
#      Write-Host "Attempting to disable user $name : Success" -ForegroundColor green
#    }
# else
#    {
#      Write-Host "Can't find user $name in the catalog" -ForegroundColor red
#    }   
#}

#####
