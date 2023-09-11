. "${PSScriptRoot}\Register.PrivateComponents.ps1"

Get-Item "${PSScriptRoot}\Public\*.ps1" | ForEach-Object { . $_.FullName }

# Avoid to export all components in the module by `Import-Module *.psm1`
# There's no contradiction with *.psd1.
Export-ModuleMember `
    -Function $local:ModuleInfo.FunctionsToExport `
    -Cmdlet $local:ModuleInfo.CmdletsToExport `
    -Variable $local:ModuleInfo.VariablesToExport `
    -Alias $local:ModuleInfo.AliasesToExport