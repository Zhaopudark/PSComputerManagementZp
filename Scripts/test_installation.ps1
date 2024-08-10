# This script is used to test the installation of the corresponding module.
$PSVersionTable
"ErrorActionPreference: $ErrorActionPreference"

& $PSScriptRoot/install.ps1

Import-Module PSComputerManagementZp