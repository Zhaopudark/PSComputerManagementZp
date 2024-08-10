# This script file is for local machine only, without considering any configuration or installation.
$ErrorActionPreference = 'Stop'
$root_path = (Get-Item "${PSScriptRoot}/..").FullName
Import-Module "${root_path}/Module/PSComputerManagementZp.psm1" -Force -Scope Local
$release_note_path = "${root_path}/RELEASE.md"

## check release version
# get version from metadata
if ($ModuleSettings.Prerelease) {
    $version_in_metadata = "$($ModuleSettings.ModuleVersion)-$($ModuleSettings.Prerelease)"
} else {
    $version_in_metadata = $ModuleSettings.ModuleVersion
}
# get version from release note
$fileContent = Get-Content -Path $release_note_path -Raw
# https://learn.microsoft.com/zh-cn/dotnet/standard/base-types/regular-expression-options#single-line-mode
$regex = [regex]::new("##[\t ]*[Rr]elease[\t ]*[Vv]*([\d\w.-]*)[\t ]*")
$temp_match = $regex.Match($fileContent)
$version_in_release_note = $temp_match.Groups[1].Value

Add-Type -Path "${root_path}/Module/Libs/PSModuleHelperZp.dll"
# 查看 NuGet.Versioning 命名空间中的所有类型
[AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
    $_.GetTypes() | Where-Object { $_.Namespace -eq 'PSModuleHelperZp' } | ForEach-Object {
        Write-Host $_.FullName
    }
}

$result = [PSModuleHelperZp.VersionHelper]::CompareVersions($version_in_metadata,$version_in_release_note)

if ($result -notin @(-1,0,1)){
    throw "There is huge difference between the version in $release_note_path($version_in_release_note) and the given one($version_in_metadata) in ${root_path}/Module/PSComputerManagementZp.psm1."
}else{
    if ($result -ne 0){
        throw "The version($version_in_release_note) in $release_note_path is not consistent with the given one($version_in_metadata) in ${root_path}/Module/PSComputerManagementZp.psm1."
    }
    return $version_in_metadata
}

