$version = Get-ChildItem -Directory $PSScriptRoot | Where-Object { $_.Name -match '^/d' } | Select-Object -ExpandProperty Name

Import-Module "./$version/helpers/PlatformTools.psm1" -Force -Scope Local

if (Test-IfIsOnCertainPlatform -SystemName 'Windows'){
    $module_install_path = "$(Split-Path -Path $PROFILE -Parent)/Modules/PSComputerManagementZp"

}elseif (Test-IfIsOnCertainPlatform -SystemName 'Wsl2'){
    $module_install_path = "${Home}/.local/share/powershell/Modules/PSComputerManagementZp"

}elseif (Test-IfIsOnCertainPlatform -SystemName 'Linux'){
    $module_install_path = "${Home}/.local/share/powershell/Modules/PSComputerManagementZp"

}else{
    Write-Host "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    exit -1
}
if (!(Test-Path $module_install_path)){
    New-Item -ItemType Directory -Path $module_install_path -Force
}

# to omit `.git` and other hidden items, do not use `-force`
$source_paths = Get-ChildItem $PSScriptRoot -Exclude ".*" 

Copy-Item -Path $source_paths -Destination $module_install_path -Recurse -Force 

Remove-Module "PlatformTools"
