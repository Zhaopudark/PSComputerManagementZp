$ErrorActionPreference = 'Stop'

. "${PSScriptRoot}\Module\Config.ps1"

# check release version
Assert-ReleaseVersionConsistency -ModuleVersion $ModuleInfo.ModuleVersion -ReleaseNotesPath "${PSScriptRoot}\RELEASE.md"
# check and get pre-release string 
$ModuleInfo.Prerelease = Get-PreReleaseString -ReleaseNotesPath "${PSScriptRoot}\RELEASE.md"

# generate APIs README.md
$api_content = @()
foreach ($entry in $ModuleInfo.SortedFunctionsToExportWithDocs){
    $api_content += "### $($entry.Name)"
    $api_content += "$(Format-Doc2Markdown -DocString $entry.Value)"
}
$api_content | Set-Content -Path "${PSScriptRoot}\Tests\APIs\README.md"

if (!(Test-Path -LiteralPath $ModuleInfo.BuildPath)){
    New-Item -Path $ModuleInfo.BuildPath -ItemType Directory
}
if (Test-Path -LiteralPath "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)"){
    Remove-Item "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)" -Force -Recurse
}
New-Item -Path "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)" -ItemType Directory

Copy-Item -Path "${PSScriptRoot}\Module\*" -Destination "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)" -Recurse -Force

if ($ModuleInfo.Prerelease -and ($ModuleInfo.Prerelease -ne 'stable')){
    New-ModuleManifest -Path "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)\$($ModuleInfo.ModuleName).psd1" `
        -ModuleVersion $ModuleInfo.ModuleVersion `
        -RootModule $ModuleInfo.RootModule `
        -Author $ModuleInfo.Author`
        -Description $ModuleInfo.Description `
        -PowerShellVersion $ModuleInfo.PowerShellVersion `
        -FunctionsToExport $ModuleInfo.FunctionsToExport `
        -CmdletsToExport $ModuleInfo.CmdletsToExport `
        -VariablesToExport $ModuleInfo.VariablesToExport `
        -AliasesToExport $ModuleInfo.AliasesToExport `
        -LicenseUri $ModuleInfo.LicenseUri `
        -ProjectUri $ModuleInfo.ProjectUri `
        -IconUri $ModuleInfo.IconUri `
        -ReleaseNotes $ModuleInfo.ReleaseNotes `
        -Prerelease $ModuleInfo.Prerelease `
        -HelpInfoURI $ModuleInfo.HelpInfoURI
}else{
    New-ModuleManifest -Path "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)\$($ModuleInfo.ModuleName).psd1" `
        -ModuleVersion $ModuleInfo.ModuleVersion `
        -RootModule $ModuleInfo.RootModule `
        -Author $ModuleInfo.Author`
        -Description $ModuleInfo.Description `
        -PowerShellVersion $ModuleInfo.PowerShellVersion `
        -FunctionsToExport $ModuleInfo.FunctionsToExport `
        -CmdletsToExport $ModuleInfo.CmdletsToExport `
        -VariablesToExport $ModuleInfo.VariablesToExport `
        -AliasesToExport $ModuleInfo.AliasesToExport `
        -LicenseUri $ModuleInfo.LicenseUri `
        -ProjectUri $ModuleInfo.ProjectUri `
        -IconUri $ModuleInfo.IconUri `
        -ReleaseNotes $ModuleInfo.ReleaseNotes `
        -HelpInfoURI $ModuleInfo.HelpInfoURI
}