$script:ModuleInfo = @{
    LogDir = 'Logs'
    ModuleName = 'PSComputerManagementZp'
    RootModule = 'PSComputerManagementZp.psm1'
    ModuleVersion = '0.0.1'
    Author = 'Pu Zhao'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Reset-Authorization',
        'Merge-RedundantEnvPathFromLocalMachineToCurrentUser',
        'Add-EnvPathToCurrentProcess',
        'Remove-EnvPathByPattern',
        'Remove-EnvPathByTargetPath',
        'Set-DirSymbolicLinkWithSync',
        'Set-FileSymbolicLinkWithSync',
        'Set-DirJunctionWithSync',
        'Set-FileHardLinkWithSync',
        'Get-GatewayIPV4',
        'Get-LocalHostIPV4',
        'Set-SystemProxyIPV4ForCurrentUser',
        'Remove-SystemProxyIPV4ForCurrentUser',
        'Set-EnvProxyIPV4ForShellProcess',
        'Remove-EnvProxyIPV4ForShellProcess'
    )
    LicenseUri = 'https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/LICENSE'
    ProjectUri = 'https://github.com/Zhaopudark/PSComputerManagementZp'
    HelpInfoURI = 'https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/Tests/APIs/README.md'
}

# NOTE: should use `.` not `&` to add items into current scope
# see https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3#using-dot-source-notation-with-scope
# https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3

. "${PSScriptRoot}\Private\Base\PlatformTools.ps1"

if (Test-Platform 'Windows'){
    $script:ModuleInfo.InstallPath = "$(Split-Path -Path $PROFILE -Parent)\Modules\$($script:ModuleInfo.ModuleName)"
    $maybe_c = (Get-ItemProperty ${Home}).PSDrive.Name
    $script:ModuleInfo.BuildPath = "$maybe_c`:\temp\$($script:ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Wsl2'){
    $script:ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($script:ModuleInfo.ModuleName)"
    $script:ModuleInfo.BuildPath = "/tmp/$($script:ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Linux'){
    $script:ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($script:ModuleInfo.ModuleName)"
    $script:ModuleInfo.BuildPath = "/tmp/$($script:ModuleInfo.ModuleName)"
}else{
    Write-Error "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    exit -1
}

. "${PSScriptRoot}\Private\Base\LoggerTools.ps1" -InstallPath $script:ModuleInfo.InstallPath -ModuleVersion $script:ModuleInfo.ModuleVersion -LogDir $ModuleInfo.LogDir

. "${PSScriptRoot}\Private\EnvTools.ps1"
. "${PSScriptRoot}\Private\LinkTools.ps1"
. "${PSScriptRoot}\Private\PathTools.ps1"
. "${PSScriptRoot}\Private\AuthorizationTools.ps1"
function Get-ModuleInfo {

    return $script:ModuleInfo
}

$ErrorActionPreference = 'Stop'