#Requires -Version 7.0
#Requires -RunAsAdministrator
try{    
}
catch {
    Write-VerboseLog  "Set-OriginalAcl Exception: $PSItem"
    Write-VerboseLog  "Operation has been skipped on $Path."
}