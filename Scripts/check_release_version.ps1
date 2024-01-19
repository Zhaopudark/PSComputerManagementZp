# This script file is for local machine only, without considering any configuration or installation.
$ErrorActionPreference = 'Stop'
$root_path = (Get-Item "${PSScriptRoot}/..").FullName
Import-Module "${root_path}/Module/PSComputerManagementZp.psm1" -Force -Scope Local
$release_note_path = "${root_path}/RELEASE.md"

# check release version
$release_version = $ModuleSettings.ModuleVersion+$ModuleSettings.Prerelease
python "${PSScriptRoot}/check_release_version.py" $release_version $release_note_path
if ($LastExitCode -ne 0){
    throw "The release version in $release_note_path is not consistent with the given version in ${root_path}/Module/PSComputerManagementZp.psm1."
}
return $release_version