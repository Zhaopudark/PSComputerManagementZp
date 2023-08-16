Import-Module "${PSScriptRoot}\RegisterUtils.psm1" -Force -Scope Local

foreach ($module in Get-ChildItem "${PSScriptRoot}\Core" -Filter *.psm1) {
    Import-Module $module.FullName -Force -Scope Local
}

