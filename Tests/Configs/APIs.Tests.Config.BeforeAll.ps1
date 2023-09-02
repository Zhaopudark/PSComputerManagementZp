$ErrorActionPreference_backup = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
Import-Module "${PSScriptRoot}\Mimic.psm1" -Prefix 'x'
Import-Module PSComputerManagementZp -Force