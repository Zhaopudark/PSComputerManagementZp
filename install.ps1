. "${PSScriptRoot}\build.ps1"

if (!(Test-Path -LiteralPath $ModuleInfo.InstallPath)){
    New-Item -Path $ModuleInfo.InstallPath -ItemType Directory | Out-Null
}
if (Test-Path -LiteralPath "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)"){
    Remove-Item "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)" -Force -Recurse
}

Copy-Item -Path "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)" -Destination "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)" -Recurse -Force
