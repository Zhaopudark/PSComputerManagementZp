# This script is used to test the APIs of the corresponding module.
# Warning: This script will force install the corresponding module and will not uninstall it.
#   It is not recommended to run this script manually by normal users.
# Reason for not uninstalling: Even if we determine that the current version is overwritten or installed for the first time,
#   and make the corresponding subsequent uninstallation or non-uninstallation, it may still cause errors or troubles due to forced uninstallation.
#   Therefore, it will not be uninstalled here.

param (
    [switch]$CodeCoverage
)

$PSVersionTable
"ErrorActionPreference: $ErrorActionPreference"

& $PSScriptRoot/install.ps1

Import-Module PSComputerManagementZp
$config = New-PesterConfiguration
$config.Run.PassThru = $true
$config.Run.Path = "$PSScriptRoot/../Tests/APIs/"
if ($CodeCoverage){
    $config.CodeCoverage.Path = "$PSScriptRoot/../Module/Public"
    $config.CodeCoverage.OutputPath = "$PSScriptRoot/../coverage-public.xml"
    $config.CodeCoverage.Enabled = $true
}
$config.Output.Verbosity = "Detailed"
Invoke-Pester -Configuration $config

