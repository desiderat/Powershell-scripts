Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
#.$env:ExchangeInstallPath\bin\RemoteExchange.ps1
#Connect-ExchangeServer -auto
Set-ADServerSettings -ViewEntireForest:$true
Import-Module ActiveDirectory

$users = Get-Mailbox -OrganizationalUnit "central.co.volia.com/Volia/Branches" -ResultSize Unlimited | where {$_.OrganizationalUnit -like "central.co.volia.com/Volia/Branches/*/Inactive Users"} #| select -First 5
$date = get-date

foreach($mailbox in $users)
{
    $AutoReplyState = (get-MailboxAutoReplyConfiguration $mailbox).AutoReplyState

    if ($AutoReplyState -eq "disabled")
        {
            $userdescription = (Get-ADUser -Identity $mailbox.SamAccountName -Properties * -Server dc-kiev0.central.co.volia.com).Description
            
            if($userdescription -ne $null)
                {
                    $Notification = "Доброго дня! Інформуємо Вас про те, що електронний лист не може бути доставлений користувачу " + $mailbox + " з наступної причини: `""  + $userdescription + "`""

                        Set-MailboxAutoReplyConfiguration $mailbox –AutoReplyState Enabled –InternalMessage $Notification -ExternalMessage $null -StartTime $date
                        #Write-Host "$mailbox - $Notification" -ForegroundColor DarkMagenta
                        #get-MailboxAutoReplyConfiguration $mailbox | select Identity,AutoReplyState

                }
            else
                {
                    $Notification = "Доброго дня! Інформуємо Вас про те, що електронний лист не може бути доставлений користувачу " + $mailbox
                    
                    Set-MailboxAutoReplyConfiguration $mailbox –AutoReplyState Enabled –InternalMessage $Notification -ExternalMessage $null -StartTime $date
                    #Write-Host "Description for $mailbox doesn't exists: $Notification" -ForegroundColor green
                }
        }
    #else
    #    {
    #        Write-Host "Auto reply for $mailbox is already enabled or scheduled" -ForegroundColor red
    #    }

    #get-MailboxAutoReplyConfiguration $mailbox | select AutoReplyState
    #Set-MailboxAutoReplyConfiguration $mailbox –AutoReplyState Enabled –InternalMessage $Notification -ExternalMessage $null -StartTime 06/26/2015

    #Write-Host $mailbox": "$Notification
}
exit 4