$ErrorActionPreference_backup = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
Import-Module "${PSScriptRoot}\..\..\Module\PSComputerManagementZp.psm1" -Force -Scope Local