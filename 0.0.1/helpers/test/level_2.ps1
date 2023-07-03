$var += "222"
Write-Host "In level2, var is $var"
$local:local_var += "222"
Write-Host "In level2, local_var is $local_var"
$global:script_var += "222"
Write-Host "In level2, script_var is $script_var"
$global:global_var += "222"
Write-Host "In level2, global_var is $global_var"

Get-Variable "var" | Format-List *
Get-Variable "local_var" | Format-List *
Get-Variable "script_var" | Format-List *
Get-Variable "global_var" | Format-List *

./level_3.ps1
