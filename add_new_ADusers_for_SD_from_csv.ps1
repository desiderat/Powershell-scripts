Import-Module ActiveDirectory
$newusers = Import-Csv -Path C:\Users\o.makiienko\Desktop\20160330_ad_upload.csv -Delimiter "," -Encoding UTF8

foreach ($user in $newusers)
    {
        New-ADUser -AccountPassword (ConvertTo-SecureString $user.pass -AsPlainText -Force) -ChangePasswordAtLogon $true -Company $user.Company -DisplayName $user.DisplayName -Enabled $true -Name $user.displayname -SamAccountName $user.SamAccountName -Path "OU=Users,OU=SD Partners,OU=Branches,OU=Volia,DC=central,DC=co,DC=volia,DC=com" -GivenName $user.GivenName -Surname $user.surname -UserPrincipalName $user.UserPrincipalName -Description "Для доступа к SD пользователей-партнеров" -LogonWorkstations "10.10.20.203"
    }