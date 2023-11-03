$ErrorActionPreference_backup = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
Import-Module "${PSScriptRoot}\..\..\Module\PSComputerManagementZp.psm1" -Force -Scope Local
Get-ChildItem "${PSScriptRoot}\..\..\Module\Private\Classes" -Recurse -Include '*.ps1','*.psm1' | ForEach-Object { . $_.FullName }