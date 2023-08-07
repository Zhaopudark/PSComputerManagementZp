$var += "333"
Write-Output "In level3, var is $var"
$local:local_var += "333"
Write-Output "In level3, local_var is $local_var"
$global:script_var += "333"
Write-Output "In level3, script_var is $script_var"
$global:global_var += "333"
Write-Output "In level3, global_var is $global_var"

Get-Variable "var" | Format-List *
Get-Variable "local_var" | Format-List *
Get-Variable "script_var" | Format-List *
Get-Variable "global_var" | Format-List *