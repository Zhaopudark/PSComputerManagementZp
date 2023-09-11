. "${PSScriptRoot}\build.ps1"

if (!(Test-Path -LiteralPath $local:ModuleInfo.InstallPath)){
    New-Item -Path $local:ModuleInfo.InstallPath -ItemType Directory | Out-Null
}
if (Test-Path -LiteralPath "$($local:ModuleInfo.InstallPath)\$($local:ModuleSettings.ModuleVersion)"){
    Remove-Item "$($local:ModuleInfo.InstallPath)\$($local:ModuleSettings.ModuleVersion)" -Force -Recurse
}

Copy-Item -Path "$($local:ModuleInfo.BuildPath)\$($local:ModuleSettings.ModuleVersion)" -Destination "$($local:ModuleInfo.InstallPath)\$($local:ModuleSettings.ModuleVersion)" -Recurse -Force