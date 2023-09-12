. "${PSScriptRoot}\Register.PrivateComponents.ps1"

Get-ChildItem "${PSScriptRoot}\Public" -Recurse -Include '*.ps1','*.psm1' | ForEach-Object { . $_.FullName }

# Avoid to export all components in the module by `Import-Module *.psm1`
# There's no contradiction with *.psd1.
Export-ModuleMember `
    -Function $local:ModuleSettings.FunctionsToExport `
    -Cmdlet $local:ModuleSettings.CmdletsToExport `
    -Variable $local:ModuleSettings.VariablesToExport `
    -Alias $local:ModuleSettings.AliasesToExport