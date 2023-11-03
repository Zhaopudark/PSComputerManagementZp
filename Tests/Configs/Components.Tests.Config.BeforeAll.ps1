$ErrorActionPreference_backup = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
Get-ChildItem "${PSScriptRoot}\..\..\Module\Private\Classes" -Recurse -Include '*.ps1','*.psm1' | ForEach-Object { . $_.FullName }
Import-Module "${PSScriptRoot}\..\..\Module\PSComputerManagementZp.psm1" -Force -Scope Local
