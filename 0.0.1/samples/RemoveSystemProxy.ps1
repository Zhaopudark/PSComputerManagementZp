#Requires -Version 5.0
#Requires -RunAsAdministrator
param ()
<#  
.DESCRIPTION
    Revokes all opeartions in script `SetSystemProxy`
#>
try { 
    Import-Module PSComputerManagementZp -Scope Local -Force
    Remove-SystemProxyIPV4ForCurrentUser
    Remove-Module PSComputerManagementZp
}
catch {
    Write-Host "Exception caught: $_"
    Write-Host "Remove system proxy failed."
    exit -1
} 




