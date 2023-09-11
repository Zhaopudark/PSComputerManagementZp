
. "${PSScriptRoot}\Private\BasicTools.Doc.ps1"


$local:ModuleInfo = @{
    ModuleName = 'PSComputerManagementZp'
    ScriptsToExport = Get-Item "${PSScriptRoot}\Public\*.ps1" | ForEach-Object { $_.FullName }
    ScriptsNotToExport = Get-Item "${PSScriptRoot}\Private\*.ps1" | ForEach-Object { $_.FullName } 
    SortedFunctionsToExportWithDocs = Get-SortedNameWithDocFromScript -Path "${PSScriptRoot}\Public\*.ps1" -DocType 'Function'
    SortedFunctionsNotToExportWithDocs = Get-SortedNameWithDocFromScript -Path "${PSScriptRoot}\Private\*.ps1" -DocType 'Function'
    SortedClassesNotToExportWithDocs = Get-SortedNameWithDocFromScript -Path "${PSScriptRoot}\Private\*.ps1" -DocType 'Class'
}

# Module Settings For PSD1
$local:ModuleSettings = @{
    RootModule = "$($ModuleInfo.ModuleName).psm1"
    ModuleVersion = '0.0.3'
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



# NOTE: should use `.` not `&` to add items into current scope
# see the [doc](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3#using-dot-source-notation-with-scope)
# also see the [doc](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3)

. "${PSScriptRoot}\Private\BasicTools.Version.ps1"
. "${PSScriptRoot}\Private\BasicTools.Platform.ps1"
. "${PSScriptRoot}\Private\BasicTools.Logger.ps1" -LoggingPath "${Home}\.log\$($ModuleInfo.ModuleName)" -ModuleVersion $local:ModuleSettings.ModuleVersion
Get-Item "${PSScriptRoot}\Private\Tools*.ps1" | ForEach-Object { . $_.FullName }