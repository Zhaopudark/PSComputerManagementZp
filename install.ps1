. "${PSScriptRoot}\build.ps1"

if (!(Test-Path -LiteralPath $ModuleInfo.InstallPath)){
    New-Item -Path $ModuleInfo.InstallPath -ItemType Directory | Out-Null
}
if (Test-Path -LiteralPath "$($ModuleInfo.InstallPath)\$($ModuleSettings.ModuleVersion)"){
    Remove-Item "$($ModuleInfo.InstallPath)\$($ModuleSettings.ModuleVersion)" -Force -Recurse
}

Write-Host "ModuleInfo.BuildPath:$($ModuleInfo.InstallPath)"
Write-Host "ModuleInfo.BuildPath:$($ModuleInfo.BuildPath)"
Copy-Item -Path "$($ModuleInfo.BuildPath)\$($ModuleSettings.ModuleVersion)" -Destination "$($ModuleInfo.InstallPath)\$($ModuleSettings.ModuleVersion)" -Recurse -Force