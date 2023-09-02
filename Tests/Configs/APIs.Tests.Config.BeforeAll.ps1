$ErrorActionPreference_backup = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
Import-Module PSComputerManagementZp -Force
Import-Module "${PSScriptRoot}\Mimic.psm1" -Prefix 'x'