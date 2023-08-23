$script:ModuleInfo = @{
    LogDir = 'Logs'
    ModuleName = 'PSComputerManagementZp'
    RootModule = 'PSComputerManagementZp.psm1'
    ModuleVersion = '0.0.1'
    Author = 'Pu Zhao'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Get-EnvPathAsSplit',
        'Set-EnvPathBySplit',
        'Merge-RedundantEnvPathFromLocalMachineToCurrentUser',
        'Add-EnvPathToCurrentProcess',
        'Remove-EnvPathByPattern',
        'Remove-EnvPathByTargetPath',
        'Set-DirSymbolicLinkWithSync',
        'Set-FileSymbolicLinkWithSync',
        'Set-DirJunctionWithSync',
        'Set-FileHardLinkWithSync',
        'Set-SystemProxyIPV4ForCurrentUser',
        'Remove-SystemProxyIPV4ForCurrentUser',
        'Set-EnvProxyIPV4ForShellProcess',
        'Remove-EnvProxyIPV4ForShellProcess',
        'Register-PS1ToScheduledTask'
    )
}

# NOTE: should use `.` not `&` to add items into current scope
# see https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3#using-dot-source-notation-with-scope
# https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3
. "${PSScriptRoot}\Private\EnvTools.ps1"
. "${PSScriptRoot}\Private\LinkTools.ps1"
. "${PSScriptRoot}\Private\PathTools.ps1"
. "${PSScriptRoot}\Private\PlatformTools.ps1"
. "${PSScriptRoot}\Private\ProxyTools.ps1"

. "${PSScriptRoot}\Private\InstallTools.ps1" -ModuleName $script:ModuleInfo.ModuleName


if (Test-Platform 'Windows'){
    $script:ModuleInfo.InstallPath = "$(Split-Path -Path $PROFILE -Parent)\Modules\$($script:ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Wsl2'){
    $script:ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($script:ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Linux'){
    $script:ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($script:ModuleInfo.ModuleName)"
}else{
    Write-Error "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    exit -1
}


. "${PSScriptRoot}\Private\LoggerTools.ps1" -InstallPath $script:ModuleInfo.InstallPath -ModuleVersion $script:ModuleInfo.ModuleVersion -LogDir $ModuleInfo.LogDir


function Get-ModuleInfo {

    return $script:ModuleInfo
}