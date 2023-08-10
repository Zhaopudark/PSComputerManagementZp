#Requires -Version 7.0
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
    Write-VerboseLog  "Exception caught: $_"
    Write-VerboseLog  "Remove system proxy failed."
    exit -1
}