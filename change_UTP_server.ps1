cd $env:userprofile
$tset = test-path .\Appdata\Roaming\1C\1CEStart\ibases.v8i
if ($tset -eq $true)
{
    $a = Get-Content .\Appdata\Roaming\1C\1CEStart\ibases.v8i
    $b = $a -contains ‘Connect=Srvr="1c02";Ref="UTP";’
    if ($tset -eq $true -and $b -eq $true)
    {
        Write-Host “Installed”
        exit 0
    }
    else
    {
        (Get-Content .\Appdata\Roaming\1C\1CEStart\ibases.v8i) -replace 'Connect=Srvr="1c01";Ref="UTP";', 'Connect=Srvr="1c02";Ref="UTP";' | Set-Content .\Appdata\Roaming\1C\1CEStart\ibases.v8i -Encoding UTF8
    }
}
else
{
    exit 0
}