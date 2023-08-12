# Proxy Tools

## Get-GatewayIPV4

```powershell
<#
.DESCRIPTION
    Get the gateway IP address(IPV4) of the current system.
.INPUTS
    None
.OUTPUTS
    System.String
.NOTES
    It only support IPV4.
#> 
```

## Get-LocalHostIPV4

```powershell
<#
.DESCRIPTION
    Get the localhost IP address(IPV4) of the current system.
.INPUTS
    None
.OUTPUTS
    System.String
.NOTES
    It only support IPV4.
#> 
```

## Set-SystemProxyIPV4ForCurrentUser

```powershell
<#
.DESCRIPTION
    Set system proxy as `ServerIP:PortNumber` for the current user.
    It does not influence environment variables, such as
        $Env:http_proxy, $Env:https_proxy, $Env:ftp_proxy, $Env:socks_proxy etc.
    It is not for all users (not on `local machine` level).
    Automatically add bypass list.
    It only support IPV4.
    Refer to https://www.mikesay.com/2020/02/03/windows-core-proxy/#%E7%B3%BB%E7%BB%9F%E7%BA%A7%E5%88%AB%E7%9A%84%E8%AE%BE%E7%BD%AE
    Refer to [Chat-GPT](https://chat.openai.com/)

.PARAMETER ServerIP
    The server IP address for proxy.

.PARAMETER Port
    The port number for proxy.

.EXAMPLE
    Set-SystemProxyIPV4ForCurrentUser -ServerIP 127.0.0.1 -PortNumber 7890.

.NOTES
    Limitation: This function has only been tested on a Windows 11 `Virtual Machine` that hosted
    by a Windows 11 `Virtual Machine` `Host Machine`.
#>   
```

## Remove-SystemProxyIPV4ForCurrentUser

```powershell
<#
.DESCRIPTION
    Revokes all opeartions in function `Set-SystemProxyIPV4ForCurrentUser`
.INPUTS
    None
.OUTPUTS
    None 
#> 
```

## Set-EnvProxyIPV4ForShellProcess

```powershell
<#
.DESCRIPTION
    Set environment variables as `ServerIP:PortNumber` for the current shell process.
    It does not influence system proxy.
    It only support IPV4.

.PARAMETER ServerIP
    The server IP address for proxy.

.PARAMETER PortNumber
    The port number for proxy.

.EXAMPLE
    Set-EnvProxyIPV4ForShellProcess -ServerIP 127.0.0.1 -PortNumber 7890.

#> 
```

## Remove-EnvProxyIPV4ForShellProcess

```powershell
<#
.DESCRIPTION
    Revokes all opeartions in function `Set-EnvProxyIPV4ForShellProcess`
.INPUTS
    None
.OUTPUTS
    None
#>  
```

# Scheduled Tasks Tools

## Register-PS1ToScheduledTask

```powershell
<#
.SYNOPSIS
    Register a PS1 file to a scheduled task.

.DESCRIPTION
    It is a wrapper of Register-ScheduledTask, registering an action of 
    running a PS1 file to a scheduled task at the trigger of Logon or Startup.
    It is forced to run with highest privilege and hidden window style.

.PARAMETER TaskName
    The name of the task.

.PARAMETER ScriptPath
    The path of the (ps1) script.

.PARAMETER ScriptArgs
    The arguments of the (ps1) script.

.PARAMETER AtLogon
    Switch Parameters.
    If the task should be triggered at logon.

.PARAMETER AtStartup
    Switch Parameters.
    If the task should be triggered at startup.
.NOTES
    This function does not do fully argument validation.
    One should make sure the arguments are valid, such as:
        1. The script path is valid.
        2. The script arguments are valid.
        3. The task name is valid.
        4. The task name is unique, unless the task should be overwritten.
        5. At least one flag (switch) of AtLogon and AtStartup is given.
#>
```

# Env Tools

## Merge-RedundantEnvPathFromLocalMachineToCurrentUser

```powershell
<#
.SYNOPSIS
    Merge redundant items form Machine Level $Env:PATH to User Level $Env:PATH.

.DESCRIPTION
    Sometimes, we may find some redundant items that both 
    in Machine Level $Env:PATH and User Level $Env:PATH.
    This may because we have installed some software in different privileges.

    This function will help us to merge the redundant items from Machine Level $Env:PATH to User Level $Env:PATH.
    The operation will symplify the `$Env:PATH`.
.NOTES
    Do not check or remove the invalid (non-existent or empty or duplicated) items in each single level as the `Format-EnvPath` function does.
#>
```

## Add-EnvPathToCurrentProcess

```powershell
<#
.DESCRIPTION
    Add the `Path` to the `$Env:PATH` in `Process` level.
    Format the `Process` level `$Env:PATH` by the function `Format-EnvPath` at the same time.
.EXAMPLE
    Add-EnvPathToCurrentProcess -Path 'C:\Program Files\Git\cmd'
#>
```

## Remove-EnvPathByPattern

```powershell
<#
.DESCRIPTION
    Remove the paths that match the pattern in `$Env:PATH` in the specified level.
.EXAMPLE
    # It will remove all the paths that match the pattern 'Git' in the Process level `$Env:PATH`.
    Remove-EnvPathByPattern -Pattern 'Git' -Level 'Process'.
#>
```

## Remove-EnvPathByTargetPath

```powershell
<#
.DESCRIPTION
    Remove the target path in `$Env:PATH` in the specified level.
.EXAMPLE
    Remove-EnvPathByTargetPath -TargetPath 'C:\Program Files\Git\cmd' -Level 'Process'
    # It will remove the path 'C:\Program Files\Git\cmd' in the Process level `$Env:PATH`.
#>
```

# Platform Tools

## Test-Plarform

```powershell
<#
.DESCRIPTION
    Test if the current platform is compatible with the arg `Name`.
    Currently, it only support Windows, Linux and Wsl2.
    If $Verbose is given, it will show the result.
.EXAMPLE
    Test-IfIsOnCertainPlatform -Name 'Windows' -Verbose
    Test-IfIsOnCertainPlatform -Name 'Wsl2' -Verbose
    Test-IfIsOnCertainPlatform -Name 'Linux' -Verbose
.OUTPUTS
    $true if compatible, otherwise $false.
#>
```

