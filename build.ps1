# & "${PSScriptRoot}\build_for_APIs_docs.ps1" # isolate the scope with `&`

$ErrorActionPreference = 'Stop'
. "${PSScriptRoot}\config.ps1"

. "${PSScriptRoot}\Module\Register.PrivateComponents.ps1"


# check release version
Assert-ReleaseVersionConsistency -Version $local:ModuleSettings.ModuleVersion -ReleaseNotesPath $local:ConfigInfo.MDDocs.Release

# check and get pre-release string
$Prerelease = Get-PreReleaseString -ReleaseNotesPath $local:ConfigInfo.MDDocs.Release


# generate APIs README.md
$api_content = @("All ``public APIs`` are recored here.")
$api_content += "## Functions"
foreach ($entry in $local:ModuleInfo.SortedFunctionsToExportWithDocs){
    # $api_content += "- [$($entry.Name)](.\$($entry.Name).md)"
    $api_content += "### $($entry.Name)"
    if ($entry.Value){
        $api_content += "$(Format-Doc2Markdown -DocString $entry.Value)"
    }
    else{
        $api_content += ''
    }
}
$api_content | Set-Content -Path $local:ConfigInfo.MDDocs.APIs

# generate Components README.md
$component_content = @("All ``private Components`` are recored here. (Only for Contributors)")

$component_content += "## Classes"
foreach ($entry in $local:ModuleInfo.SortedClassesNotToExportWithDocs){
    $component_content += "### $($entry.Name)"
    if ($entry.Value){
        $component_content += "$(Format-Doc2Markdown -DocString $entry.Value)"
    }
    else{
        $component_content += ''
    }
}

$component_content += "## Functions"
foreach ($entry in $local:ModuleInfo.SortedFunctionsNotToExportWithDocs){
    $component_content += "### $($entry.Name)"
    if ($entry.Value){
        $component_content += "$(Format-Doc2Markdown -DocString $entry.Value)"
    }
    else{
        $component_content += ''
    }
}

$component_content | Set-Content -Path $local:ConfigInfo.MDDocs.Components
$local:ModuleInfo.InstallPath = "$(Get-ModuleInstallDir)\$($local:ModuleInfo.ModuleName)"
$local:ModuleInfo.BuildPath = "$(Get-ModuleBuildDir)\$($local:ModuleInfo.ModuleName)"

if (!(Test-Path -LiteralPath $local:ModuleInfo.BuildPath)){
    New-Item -Path $local:ModuleInfo.BuildPath -ItemType Directory | Out-Null
}
if (Test-Path -LiteralPath "$($local:ModuleInfo.BuildPath)\$($local:ModuleSettings.ModuleVersion)"){
    Remove-Item "$($local:ModuleInfo.BuildPath)\$($local:ModuleSettings.ModuleVersion)" -Force -Recurse
}
New-Item -Path "$($local:ModuleInfo.BuildPath)\$($local:ModuleSettings.ModuleVersion)" -ItemType Directory | Out-Null

Copy-Item -Path "${PSScriptRoot}\Module\*" -Destination "$($local:ModuleInfo.BuildPath)\$($local:ModuleSettings.ModuleVersion)" -Recurse -Force

$local:ModuleSettings.Path = "$($local:ModuleInfo.BuildPath)\$($local:ModuleSettings.ModuleVersion)\$($local:ModuleInfo.ModuleName).psd1"
if ($Prerelease -and ($Prerelease -ne 'stable')){
    $local:ModuleSettings.Prerelease = $Prerelease
}

New-ModuleManifest  @local:ModuleSettings