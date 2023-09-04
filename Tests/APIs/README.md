All Public APIs
# Authorization Management
## Reset-Authorization
```powershell
<#
.SYNOPSIS
Reset the ACL and attributes of a path to its default state if we have already known the default state exactly.
For more information on the motivation, rationale, logic, and usage of this function, see https://little-train.com/posts/7fdde8eb.html

.DESCRIPTION
    Reset ACL of `$Path` to its default state by 3 steps:
        1. Get path type by `Get-PathType`
        2. Get default SDDL of `$Path` by `Get-DefaultSddl` according to `$PathType`
        3. Set SDDL of `$Path` to default SDDL by `Set-Acl`
    
    Only for window system
    Only for single user account on window system, i.e. totoally Personal Computer

.COMPONENT
    $NewAcl = Get-Acl -LiteralPath $Path
    $Sddl = ... # Get default SDDL of `$Path`
    $NewAcl.SetSecurityDescriptorSddlForm($Sddl)
    Set-Acl -LiteralPath $Path -AclObject $NewAcl

#>
```
# Environment Variables Management
## Merge-RedundantEnvPathsFromCurrentMachineToCurrentUser

```powershell
<#
.SYNOPSIS
    Merge redundant items form the current machine level env paths to the current user level.
    Before merging, the function will check and de-duplicate the current machine level and the current user level env paths.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.DESCRIPTION
    Sometimes, we may find some redundant items that both in the machine level and the user level env paths.
    This may because we have installed some software in different privileges.
    This function will help us to merge the redundant items from the machine level env paths to the user level.
    The operation can symplify the `$Env:PATH`.
#>
```
## Add-PathToCurrentProcessEnvPaths
```powershell
<#
.DESCRIPTION
    Append a path to the current process level env paths.
    Before appending, the function will check and de-duplicate the current process level env paths.
.EXAMPLE
    Add-PathToCurrentProcessEnvPaths -Path 'C:\Program Files\Git\cmd'
#>
```
## Add-PathToCurrentUserEnvPaths
```powershell
<#
.DESCRIPTION
    Append a path to the current user level env paths.
    Before appending, the function will check and de-duplicate the current user level env paths.
.NOTES
    Support Windows only.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Add-PathToCurrentUserEnvPaths -Path 'C:\Program Files\Git\cmd'
#>
```
## Add-PathToCurrentMachineEnvPaths
```powershell
<#
.DESCRIPTION
    Append a path to the current machine level env paths.
    Before appending, the function will check and de-duplicate the current machine level env paths.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Add-PathToCurrentMachineEnvPaths -Path 'C:\Program Files\Git\cmd'
#>
```
## Remove-PathFromCurrentProcessEnvPaths
```powershell
<#
.DESCRIPTION
    Remove a path from the current process level env paths.
    Before removing, the function will check and de-duplicate the current process level env paths.
.EXAMPLE
    Remove-PathFromCurrentProcessEnvPaths -Path 'C:\Program Files\Git\cmd'
#>
```
## Remove-PathFromCurrentUserEnvPaths
```powershell
<#
.DESCRIPTION
    Remove a path from the current user level env paths.
    Before removing, the function will check and de-duplicate the current user level env paths.
.NOTES
    Support Windows only.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-PathFromCurrentUserEnvPaths -Path 'C:\Program Files\Git\cmd'
#>
```
## Remove-PathFromCurrentMachineEnvPaths
```powershell
<#
.DESCRIPTION
    Remove a path from the current machine level env paths.
    Before removing, the function will check and de-duplicate the current machine level env paths.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-PathFromCurrentMachineEnvPaths -Path 'C:\Program Files\Git\cmd'
#>
```
## Remove-MatchedPathsFromCurrentProcessEnvPaths
```powershell
<#
.DESCRIPTION
    Remove matched paths from the current process level env paths.
    Before removing, the function will check and de-duplicate the current process level env paths.
.EXAMPLE
    Remove-MatchedPathsFromCurrentProcessEnvPaths -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the process level env paths.
#>
```
## Remove-MatchedPathsFromCurrentUserEnvPaths
```powershell
<#
.DESCRIPTION
    Remove matched paths from the current user level env paths.
    Before removing, the function will check and de-duplicate the current user level env paths.
.NOTES
    Support Windows only.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-MatchedPathsFromCurrentUserEnvPaths -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the user level env paths.
#>
```
## Remove-MatchedPathsFromCurrentMachineEnvPaths
```powershell
<#
.DESCRIPTION
    Remove matched paths from the current machine level env paths.
    Before removing, the function will check and de-duplicate the current machine level env paths.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-MatchedPathsFromCurrentMachineEnvPaths -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the machine level env paths.
#>
```


# Link Management
## Set-DirSymbolicLinkWithSync
```powershell
<#
.DESCRIPTION
    Set a directory symbolic link from $Path to $Source
    Then, we will get a result as $Path->$Target, which means $Path is a symbolic link to $Target
#>
```

## Set-FileSymbolicLinkWithSync
```powershell
<#
.DESCRIPTION
    Set a file symbolic link from $Path to $Source.
    Then, we will get a result as $Path->$Target,
    which means $Path is a symbolic link to $Target.
#>
```

## Set-DirJunctionWithSync
```powershell
<#
.DESCRIPTION
    Set a junction point from $Path to $Source.
    Then, we will get a result as $Path->$Target,
    which means $Path is a junction point to $Target.
#>
```
## Set-FileHardLinkWithSync
```powershell
<#
.DESCRIPTION
    Set a file hard link from $Path to $Source.
    Then, we will get a result as $Path->$Target,
    which means $Path is a hard link to $Target.
#>
```

# Proxy Management
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

.PARAMETER PortNumber
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