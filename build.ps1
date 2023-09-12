$ErrorActionPreference = 'Stop'
. "${PSScriptRoot}\Module\Register.PrivateComponents.ps1"


# check release version
Assert-ReleaseVersionConsistency -Version $local:ModuleSettings.ModuleVersion -ReleaseNotesPath "${PSScriptRoot}\RELEASE.md"
# check and get pre-release string
$Prerelease = Get-PreReleaseString -ReleaseNotesPath "${PSScriptRoot}\RELEASE.md"


# generate APIs README.md
$api_content = @("All ``public APIs`` are recored here.")
$api_content += "## Functions"
foreach ($entry in $local:ModuleInfo.SortedFunctionsToExportWithDocs){
    $api_content += "### $($entry.Name)"
    if ($entry.Value){
        $api_content += "$(Format-Doc2Markdown -DocString $entry.Value)"
    }
    else{
        $api_content += ''
    }
}
$api_content | Set-Content -Path "${PSScriptRoot}\Tests\APIs\README.md"

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

$component_content | Set-Content -Path "${PSScriptRoot}\Tests\Components\README.md"



if (Test-Platform 'Windows'){
    $local:ModuleInfo.InstallPath = "$(Split-Path -Path $PROFILE -Parent)\Modules\$($local:ModuleInfo.ModuleName)"
    $local:maybe_c = (Get-ItemProperty ${Home}).PSDrive.Name
    $local:ModuleInfo.BuildPath = "$local:maybe_c`:\temp\$($local:ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Wsl2'){
    $local:ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($local:ModuleInfo.ModuleName)"
    $local:ModuleInfo.BuildPath = "/tmp/$($local:ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Linux'){
    $local:ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($local:ModuleInfo.ModuleName)"
    $local:ModuleInfo.BuildPath = "/tmp/$($local:ModuleInfo.ModuleName)"
}elseif (Test-Platform 'MacOS'){
    $local:ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($local:ModuleInfo.ModuleName)"
    $local:ModuleInfo.BuildPath = "/tmp/$($local:ModuleInfo.ModuleName)"
}else{
    throw "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    exit -1
}


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