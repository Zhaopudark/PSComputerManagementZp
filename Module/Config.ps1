. "${PSScriptRoot}\Private\BasicTools.Scripts.ps1"

$scripts_not_to_export = Get-Item "${PSScriptRoot}\Private\*.ps1"
$scripts_to_export = Get-Item "${PSScriptRoot}\Public\*.ps1"

$functions_not_to_export_with_docs = @{}
foreach ($script in $scripts_not_to_export){
    $functions_not_to_export_with_docs += Get-FunctionDoc -Path $script.FullName
}
$SortedFunctionsNotToExportWithDocs = $functions_not_to_export_with_docs.GetEnumerator() | Sort-Object -Property Name

$classes_not_to_export_with_docs = @{}
foreach ($script in $scripts_not_to_export){
    $classes_not_to_export_with_docs += Get-ClassDoc -Path $script.FullName
}
$SortedClassesNotToExportWithDocs = $classes_not_to_export_with_docs.GetEnumerator() | Sort-Object -Property Name

$functions_to_export_with_docs = @{}
foreach ($script in $scripts_to_export){
    $functions_to_export_with_docs += Get-FunctionDoc -Path $script.FullName
}
$SortedFunctionsToExportWithDocs = $functions_to_export_with_docs.GetEnumerator() | Sort-Object -Property Name

$ModuleInfo = @{
    ModuleName = 'PSComputerManagementZp'
    RootModule = 'PSComputerManagementZp.psm1'
    ModuleVersion = '0.0.3'
    Author = 'Pu Zhao'
    Description = 'A PowerShell module that derives from personal scenarios, can help users configure the Windows PCs easily to realize many useful operations, involving authorization, env, links, proxy, etc. Some features are also available on WSL2 and Linux.'
    PowerShellVersion = '7.0'
    ScriptsToExport = $scripts_to_export
    SortedFunctionsNotToExportWithDocs = $SortedFunctionsNotToExportWithDocs
    SortedClassesNotToExportWithDocs = $SortedClassesNotToExportWithDocs
    SortedFunctionsToExportWithDocs = $SortedFunctionsToExportWithDocs
    FunctionsToExport = $SortedFunctionsToExportWithDocs.Name
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

. "${PSScriptRoot}\Private\BasicTools.Platform.ps1"
. "${PSScriptRoot}\Private\BasicTools.Logger.ps1" -LoggingPath "${Home}\.log\$($ModuleInfo.ModuleName)" -ModuleVersion $ModuleInfo.ModuleVersion
$tools_scripts = Get-Item "${PSScriptRoot}\Private\Tools*.ps1" | ForEach-Object { . $_.FullName }
foreach ($script in $tools_scripts){
    . $script
}

if (Test-Platform 'Windows'){
    $ModuleInfo.InstallPath = "$(Split-Path -Path $PROFILE -Parent)\Modules\$($ModuleInfo.ModuleName)"
    $maybe_c = (Get-ItemProperty ${Home}).PSDrive.Name
    $ModuleInfo.BuildPath = "$maybe_c`:\temp\$($ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Wsl2'){
    $ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($ModuleInfo.ModuleName)"
    $ModuleInfo.BuildPath = "/tmp/$($ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Linux'){
    $ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($ModuleInfo.ModuleName)"
    $ModuleInfo.BuildPath = "/tmp/$($ModuleInfo.ModuleName)"
}elseif (Test-Platform 'MacOS'){
    $ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($ModuleInfo.ModuleName)"
    $ModuleInfo.BuildPath = "/tmp/$($ModuleInfo.ModuleName)"
}else{
    Write-Error "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    exit -1
}