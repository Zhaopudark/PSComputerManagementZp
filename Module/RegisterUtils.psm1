$module_name = 'PSComputerManagementZp'
$module_version = '0.0.1'
$log_dir = "Logs" 

# Notice: should use `.` not `&` to add items into current scope
# see https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3#using-dot-source-notation-with-scope
# https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.3
. "${PSScriptRoot}\Utils\PlatformTools.ps1"
. "${PSScriptRoot}\Utils\PathTools.ps1"
. "${PSScriptRoot}\Utils\InstallTools.ps1" -ModuleName $module_name


$install_path = Get-InstallPath
if ($null -eq $install_path){ # fuse
    exit -1
}

. "${PSScriptRoot}\Utils\LoggerTools.ps1" -InstallPath $install_path -ModuleVersion $module_version -LogDir $log_dir

$script:ModuleInfo = @{
    InstallPath = $install_path
    LogDir = $log_dir
    ModuleName = $module_name
    RootModule = "$module_name.psm1" 
    ModuleVersion = $module_version
    Author = 'Pu Zhao'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Set-OriginalAcl',
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
        'Register-PS1ToScheduledTask',
        'Test-Platform' 
    )
}
function Get-ModuleInfo {
    return $script:ModuleInfo
}