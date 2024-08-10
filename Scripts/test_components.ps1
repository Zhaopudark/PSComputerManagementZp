# This script is used to test the components of the corresponding module.

$PSVersionTable
"ErrorActionPreference: $ErrorActionPreference"

& $PSScriptRoot/install.ps1
. $PSScriptRoot/../Tests/Helpers/Register.Components.ps1

$config = New-PesterConfiguration
$config.Run.PassThru = $true
$config.Run.Path = "$PSScriptRoot/../Tests/Components/"
$config.CodeCoverage.Path = "$PSScriptRoot/../Module/Private"
$config.CodeCoverage.OutputPath = "$PSScriptRoot/../coverage-private.xml"
$config.CodeCoverage.Enabled = $true
$config.Output.Verbosity = "Detailed"
Invoke-Pester -Configuration $config