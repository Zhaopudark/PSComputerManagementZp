$var = @("level_1_var")
$local:local_var = @("level_1_local_var")
$script:script_var = @("level_1_script_var")
$global:global_var = @("level_1_global_var")

./level_2.ps1

Write-Host "In level1"
Get-Variable "var" | Format-List *
Get-Variable "local_var" | Format-List *
Get-Variable "script_var" | Format-List *
Get-Variable "global_var" | Format-List *
# Write-Host "In level1, local_var is $local_var"
# Write-Host "In level1, script_var is $script_var"
# Write-Host "In level1, global_var is $global_var"