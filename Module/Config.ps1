$script:ModuleInfo = @{
    ModuleName = 'PSComputerManagementZp'
    RootModule = 'PSComputerManagementZp.psm1'
    ModuleVersion = '0.0.2'
    Author = 'Pu Zhao'
    Description = '
    A PowerShell module that derives from personal scenarios, 
    can help users configure the Windows PCs easily to realize many useful operations, 
    involving authorization, env, links, proxy, etc. Some features are also available on WSL2 and Linux.'
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
    IconUri = 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/av_colors_128.svg'
    ReleaseNotes = 'https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/RELEASE.md'
    HelpInfoURI = 'https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/Tests/APIs/README.md'
}

# NOTE: should use `.` not `&` to add items into current scope
# see https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3#using-dot-source-notation-with-scope
# https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3

. "${PSScriptRoot}\Private\Base\PlatformTools.ps1"
. "${PSScriptRoot}\Private\Base\LoggerTools.ps1" -LoggingPath "${Home}\.log\$($script:ModuleInfo.ModuleName)" -ModuleVersion $script:ModuleInfo.ModuleVersion
. "${PSScriptRoot}\Private\AuthorizationTools.ps1"
. "${PSScriptRoot}\Private\EnvTools.ps1"
. "${PSScriptRoot}\Private\LinkTools.ps1"
. "${PSScriptRoot}\Private\PathTools.ps1"

function Get-ModuleInfo {
    return $script:ModuleInfo
}