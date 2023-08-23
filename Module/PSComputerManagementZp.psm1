. "${PSScriptRoot}\Config.ps1"

foreach ($module in Get-ChildItem "${PSScriptRoot}\Public" -Filter *.ps1) {
    Import-Module $module.FullName -Force -Scope Local
}

