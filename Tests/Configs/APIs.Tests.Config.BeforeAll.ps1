$ErrorActionPreference_backup = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
Import-Module PSComputerManagementZp -Force
Import-Module "${PSScriptRoot}\..\..\Module\PSComputerManagementZp.psm1" -Prefix 'x'