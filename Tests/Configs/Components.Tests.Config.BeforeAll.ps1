$ErrorActionPreference_backup = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
using module ".\Classes\EnvPath.psm1"
using module ".\Classes\FormattedFileSystemPath.psm1"
Import-Module "${PSScriptRoot}\..\..\Module\PSComputerManagementZp.psm1" -Force -Scope Local