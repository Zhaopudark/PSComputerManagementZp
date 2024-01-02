# & "${PSScriptRoot}\build_for_APIs_docs.ps1" # isolate the scope with `&`
$ErrorActionPreference = 'Stop'

$ConfigInfo= @{
    PrivateComponentsTestsDir = "${PSScriptRoot}\Tests\Components"
    PublicAPIsTestsDir = "${PSScriptRoot}\Tests\APIs"
    PrivateComponentsDocsDir = "${PSScriptRoot}\Docs\Components"
    PublicAPIsDocsDir = "${PSScriptRoot}\Docs\APIs"
    MDDocs = @{
        Root = "${PSScriptRoot}\README.md"
        Release = "${PSScriptRoot}\RELEASE.md"
        Tests = "${PSScriptRoot}\Tests\README.md"
        Components = "${PSScriptRoot}\Docs\Components\README.md"
        APIs = "${PSScriptRoot}\Docs\APIs\README.md"
        Examples = "${PSScriptRoot}\Examples\README.md"
        Contribution = "${PSScriptRoot}\CONTRIBUTION.md"
    }
}

Import-Module "${PSScriptRoot}\Module\PSComputerManagementZp.psm1" -Force -Scope Local

# check release version
Assert-ReleaseVersionConsistency -Version $ModuleSettings.ModuleVersion -ReleaseNotesPath $ConfigInfo.MDDocs.Release

# check and get pre-release string
$Prerelease = Get-PreReleaseString -ReleaseNotesPath $ConfigInfo.MDDocs.Release

# generate APIs README.md
$api_content = @("All ``public APIs`` are recorded here.")
$api_content += "## Functions"
foreach ($entry in $ModuleInfo.SortedFunctionsToExportWithDocs){
    # $api_content += "- [$($entry.Name)](.\$($entry.Name).md)"
    $api_content += "### $($entry.Name)"
    if ($entry.Value){
        $api_content += "$(Format-Doc2Markdown -DocString $entry.Value)"
    }
    else{
        $api_content += ''
    }
}
$api_content | Set-Content -Path $ConfigInfo.MDDocs.APIs

# generate Components README.md
$component_content = @("All ``private Components`` are recorded here. (Only for Contributors)")

$component_content += "## Classes"
foreach ($entry in $ModuleInfo.SortedClassesNotToExportWithDocs){
    $component_content += "### $($entry.Name)"
    if ($entry.Value){
        $component_content += "$(Format-Doc2Markdown -DocString $entry.Value)"
    }
    else{
        $component_content += ''
    }
}

$component_content += "## Functions"
foreach ($entry in $ModuleInfo.SortedFunctionsNotToExportWithDocs){
    $component_content += "### $($entry.Name)"
    if ($entry.Value){
        $component_content += "$(Format-Doc2Markdown -DocString $entry.Value)"
    }
    else{
        $component_content += ''
    }
}

$component_content | Set-Content -Path $ConfigInfo.MDDocs.Components
$ModuleInfo.InstallPath = "$(Get-SelfInstallDir)\$($ModuleInfo.ModuleName)"
$ModuleInfo.BuildPath = "$(Get-SelfBuildDir)\$($ModuleInfo.ModuleName)"
Write-Host "ModuleInfo.InstallPath:$($ModuleInfo.InstallPath)"
Write-Host "ModuleInfo.BuildPath:$($ModuleInfo.BuildPath)"

if (!(Test-Path -LiteralPath $ModuleInfo.BuildPath)){
    New-Item -Path $ModuleInfo.BuildPath -ItemType Directory | Out-Null
}
if (Test-Path -LiteralPath "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)"){
    Remove-Item "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)" -Force -Recurse
}
New-Item -Path "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)" -ItemType Directory | Out-Null

Copy-Item -Path "${PSScriptRoot}\Module\*" -Destination "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)" -Recurse -Force

$ModuleSettings.Path = "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)\$($ModuleInfo.ModuleName).psd1"
if ($Prerelease -and ($Prerelease -ne 'stable')){
    $ModuleSettings.Prerelease = $Prerelease
}

New-ModuleManifest  @ModuleSettings