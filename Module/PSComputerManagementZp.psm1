. "${PSScriptRoot}\Config.ps1"

foreach ($script in $ModuleInfo.ScriptsToExport) {
    . $script.FullName
}

# Avoid to export all components in the module by `Import-Module *.psm1`
# There's no contradiction with *.psd1.
Export-ModuleMember `
    -Function $ModuleInfo.FunctionsToExport `
    -Cmdlet $ModuleInfo.CmdletsToExport `
    -Variable $ModuleInfo.VariablesToExport `
    -Alias $ModuleInfo.AliasesToExport