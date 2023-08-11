$version = Get-ChildItem -Directory $PSScriptRoot | Where-Object { $_.Name -match '^\d' } | Select-Object -ExpandProperty Name

Import-Module "${PSScriptRoot}/$version/helpers/PlatformTools.psm1" -Force -Scope Local


$module_install_path = Get-InstallPath

if (Test-Path $module_install_path){
    $content = Get-ChildItem $module_install_path -Exclude 'Log'
    Remove-Item $content -Force
}else{
    New-Item -ItemType Directory -Path $module_install_path -Force
}


# to omit `.git` and other hidden items, do not use `-force`
$source_paths = Get-ChildItem $PSScriptRoot -Exclude ".*"

Copy-Item -Path $source_paths -Destination $module_install_path -Recurse -Force

