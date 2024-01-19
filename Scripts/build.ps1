# & "${PSScriptRoot}\build_for_APIs_docs.ps1" # isolate the scope with `&`
$ErrorActionPreference = 'Stop'

$root_path = (Get-Item "${PSScriptRoot}\..").FullName
$ConfigInfo= @{
    PrivateComponentsTestsDir = "${root_path}\Tests\Components"
    PublicAPIsTestsDir = "${root_path}\Tests\APIs"
    PrivateComponentsDocsDir = "${root_path}\Docs\Components"
    PublicAPIsDocsDir = "${root_path}\Docs\APIs"
    MDDocs = @{
        Root = "${root_path}\README.md"
        Release = "${root_path}\RELEASE.md"
        Tests = "${root_path}\Tests\README.md"
        Components = "${root_path}\Docs\Components\README.md"
        APIs = "${root_path}\Docs\APIs\README.md"
        Examples = "${root_path}\Examples\README.md"
        Contribution = "${root_path}\CONTRIBUTION.md"
    }
}

Import-Module "${root_path}\Module\PSComputerManagementZp.psm1" -Force -Scope Local

# check release version
$release_version = . "${PSScriptRoot}\check_release_version.ps1"

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

if (!(Test-Path -LiteralPath $ModuleInfo.BuildPath)){
    New-Item -Path $ModuleInfo.BuildPath -ItemType Directory | Out-Null
}
if (Test-Path -LiteralPath "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)"){
    Remove-Item "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)" -Force -Recurse
}
New-Item -Path "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)" -ItemType Directory | Out-Null

Copy-Item -Path "${root_path}\Module\*" -Destination "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)" -Recurse -Force

$ModuleSettings.Path = "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)\$($ModuleInfo.ModuleName).psd1"

if (!$ModuleSettings.Prerelease){
    $ModuleSettings.Remove('Prerelease') # since New-ModuleManifest validate arguments and reject empty string.
}
New-ModuleManifest  @ModuleSettings