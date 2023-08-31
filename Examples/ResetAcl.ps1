#Requires -Version 7.0
#Requires -RunAsAdministrator
try {    
    Import-Module PSComputerManagementZp -Scope Local -Force
    Reset-Authorization 'D:\'
    Remove-Module PSComputerManagementZp
}
catch {
    Write-VerboseLog  "Set-OriginalAcl Exception: $PSItem"
    Write-VerboseLog  "Operation has been skipped on $Path."
}