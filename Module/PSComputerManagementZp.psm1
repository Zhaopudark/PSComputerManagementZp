# NOTE: should use `.` not `&` to add items into current scope
# see the [doc](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3#using-dot-source-notation-with-scope)
# also see the [doc](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3)

# ${PSScriptRoot}\Private\Bases\Logger.ps1 is a special script, which needs status given.
Get-ChildItem "${PSScriptRoot}\Private" -Recurse -Include '*.ps1','*.psm1' -Exclude '*Logger.ps1' | ForEach-Object { . $_.FullName }

$scripts_to_export = Get-ChildItem "${PSScriptRoot}\Public" -Recurse -Include '*.ps1','*.psm1'| ForEach-Object { $_.FullName }
$scripts_not_to_export = Get-ChildItem "${PSScriptRoot}\Private" -Recurse -Include '*.ps1','*.psm1'| ForEach-Object { $_.FullName }

# Module Information Collection
$ModuleInfo = @{
    ModuleName = 'PSComputerManagementZp'
    LoggingPath = "${Home}\.log\PSComputerManagementZp"
    ScriptsToExport = $scripts_to_export
    ScriptsNotToExport = $scripts_not_to_export
    SortedFunctionsToExportWithDocs = Get-SortedNameWithDocFromScript -Path $scripts_to_export -DocType 'Function'
    SortedFunctionsNotToExportWithDocs = Get-SortedNameWithDocFromScript -Path $scripts_not_to_export -DocType 'Function'
    SortedClassesNotToExportWithDocs = Get-SortedNameWithDocFromScript -Path $scripts_not_to_export -DocType 'Class'
}

# Module Settings For PSD1
$ModuleSettings = @{
    RootModule = "$($ModuleInfo.ModuleName).psm1"
    ModuleVersion = '0.0.5'
    Author = 'Pu Zhao'
    Description = 'A PowerShell module that derives from personal scenarios, can help users configure the Windows PCs easily to realize many useful operations, involving authorization, env, links, proxy, etc. Some features are also available on WSL2 and Linux.'
    PowerShellVersion = '7.0'
    FunctionsToExport = $ModuleInfo.SortedFunctionsToExportWithDocs.Name
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    LicenseUri = 'https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/LICENSE'
    ProjectUri = 'https://github.com/Zhaopudark/PSComputerManagementZp'
    IconUri = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/av_colors_128.svg'
    ReleaseNotes = 'https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/RELEASE.md'
    HelpInfoURI = 'https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/Tests/APIs/README.md'
}


. "${PSScriptRoot}\Private\Bases\Logger.ps1" -LoggingPath $ModuleInfo.LoggingPath -ModuleVersion $local:ModuleSettings.ModuleVersion

Get-ChildItem "${PSScriptRoot}\Public" -Recurse -Include '*.ps1','*.psm1' | ForEach-Object { . $_.FullName }

# The following lines are only for developing senarios.
# Developers can use `Import-Module <filename>.psm1` to import 
# almost all functions, cmdlets, variables, aliases of this module into current scope for developing purpose.
Export-ModuleMember `
    -Function * `
    -Cmdlet * `
    -Variable @('ModuleInfo','ModuleSettings') `
    -Alias *