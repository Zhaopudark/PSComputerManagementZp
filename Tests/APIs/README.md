All `public APIs` are recored here.
## Functions
### Add-PathToCurrentMachineEnvPath
    
- **Description**

    Append a path to the current machine level `$Env:PATH`.
    Before appending, the function will check and de-duplicate the current machine level `$Env:PATH`.
- **Parameter** `$Path`

    The path to be appended.
- **Example**

    Add-PathToCurrentMachineEnvPath -Path 'C:\Program Files\Git\cmd'
- **Inputs**

    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
    Need Administrator privilege.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Add-PathToCurrentProcessEnvPath
    
- **Description**

    Append a path to the current process level `$Env:PATH`.
    Before appending, the function will check and de-duplicate the current process level `$Env:PATH`.
- **Parameter** `$Path`

    The path to be appended.
- **Example**

    Add-PathToCurrentProcessEnvPath -Path 'C:\Program Files\Git\cmd'
- **Inputs**

    String.
- **Outputs**

    None.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Add-PathToCurrentUserEnvPath
    
- **Description**

    Append a path to the current user level `$Env:PATH`.
    Before appending, the function will check and de-duplicate the current user level `$Env:PATH`.
- **Parameter** `$Path`

    The path to be appended.
- **Example**

    Add-PathToCurrentUserEnvPath -Path 'C:\Program Files\Git\cmd'
- **Inputs**

    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Get-GatewayIPV4
    
- **Description**

    Get the gateway IP address(IPV4) of the current system.
- **Inputs**

    None.
- **Outputs**

    String.
- **Notes**

    Only support IPV4.
    Originally, refer to the post [Get Gateway IP Address](https://blog.csdn.net/YOLO3/article/details/81117952).
    But there will be a warning like:
    ```markdown
    File 'xxx' uses WMI cmdlet. For PowerShell 3.0 and above, use CIM cmdlet, which perform the same tasks as the WMI cmdlets.
    The CIM cmdlets comply with WS-Management (WSMan) standards and with the Common Information Model (CIM) standard, which enables the cmdlets to use the same techniques
    to manage Windows computers and those running other operating systems.
    ```
    So in this function, `Get-CimInstance` is used to replace `Get-WmiObject`
- **Link**

    [Get Gateway IP Address](https://blog.csdn.net/YOLO3/article/details/81117952).
    
### Get-LocalHostIPV4
    
- **Description**

    Get the localhost IP address(IPV4) of the current system.
- **Inputs**

    None.
- **Outputs**

    String.
- **Notes**

    Only support IPV4.
- **Link**

    [GetHostAddresses](https://learn.microsoft.com/en-us/dotnet/api/system.net.dns.gethostaddresses?view=net-7.0).
    
### Merge-RedundantEnvPathFromCurrentMachineToCurrentUser
    
- **Description**

    Merge redundant items form the current machine level `$Env:PATH` to the current user level.
    Before merging, the function will check and de-duplicate the current machine level and the current user level `$Env:PATH`.
- **Inputs**

    None.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
    Need Administrator privilege.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Register-FSLEnvForPwsh
    
- **Synopsis**

    Setup FSL environment variables for pwsh as well as FSL's bash settings in .profile
- **Description**

    FSL is a comprehensive library of analysis tools for FMRI, MRI and diffusion brain imaging data.
    See the [FSL doc](ttps://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)
    
    This function is used to setup FSL environment variables for pwsh as well as FSL's bash settings in .profile.
    It mimics the following bash settings in .profile:
    
    ```bash
    # FSL Setup
    FSLDIR=/home/some_user_name/fsl
    PATH=${FSLDIR}/share/fsl/bin:${PATH}
    export FSLDIR PATH
    . ${FSLDIR}/etc/fslconf/fsl.sh
    ```
- **Parameter** `$FslDir`

    The FSL installation directory.
- **Inputs**

    String.
- **Outputs**

    None.
- **Notes**

    When it comes to setup FSL, the official scripts [fslinstaller.py](https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py)
    do not support pwsh, but support bash. It will automatically register procedures in .profile. to setup FSL environment variables.
    
    If we use pwsh in WSL2 directly, i.e., set pwsh as the default shell in WSL2, we have to mimic all bash settings to maintain corresponding
    components, especially environment variables, including the FSL's bash settings.
    
    But actually, we usually do not launch pwsh directly, but launch bash first, then call pwsh in bash.
    This priority (launching sequence) is also suitable for using pwsh in VS Code remote.
    
    The normal launch sequence of bash and its configuration files is:
    bash->.profile(where .bashrc is contained and called once, and append some extra settings.)
    Then, the normal interactive terminal is presented.
    For following  calls of bash, .profile will not be executed, but .bashrc will be executed each time.
    In normal usage, we usually call pwsh after bash is launched. So the FSL environment variables that
    have been set in .profile will be inherited by pwsh.
    
    So, there is no need to setup FSL environment variables for pwsh again.
    This function is just for a record.
    
    Only support Linux and WSL2.
- **Link**

    [FSL](https://fsl.fmrib.ox.ac.uk)
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Remove-EnvProxyIPV4ForShellProcess
    
- **Description**

    Revokes all opeartions in function `Set-EnvProxyIPV4ForShellProcess`.
- **Inputs**

    None.
- **Outputs**

    None.
    
### Remove-MatchedPathsFromCurrentMachineEnvPath
    
- **Description**

    Remove matched paths from the current machine level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current machine level `$Env:PATH`.
- **Parameter** `$Pattern`

    The pattern to be matched to represent the items to be removed.
- **Example**

    Remove-MatchedPathsFromCurrentMachineEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the machine level `$Env:PATH`.
- **Inputs**

    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
    Need Administrator privilege.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Remove-MatchedPathsFromCurrentProcessEnvPath
    
- **Description**

    Remove matched paths from the current process level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current process level `$Env:PATH`.
- **Parameter** `$Pattern`

    The pattern to be matched to represent the items to be removed.
- **Example**

    Remove-MatchedPathsFromCurrentProcessEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the process level `$Env:PATH`.
- **Inputs**

    String.
- **Outputs**

    None.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Remove-MatchedPathsFromCurrentUserEnvPath
    
- **Description**

    Remove matched paths from the current user level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current user level `$Env:PATH`.
- **Parameter** `$Pattern`

    The pattern to be matched to represent the items to be removed.
- **Example**

    Remove-MatchedPathsFromCurrentUserEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the user level `$Env:PATH`.
- **Inputs**

    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Remove-PathFromCurrentMachineEnvPath
    
- **Description**

    Remove a path from the current machine level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current machine level `$Env:PATH`.
- **Parameter** `$Path`

    The path to be removed.
- **Example**

    Remove-PathFromCurrentMachineEnvPath -Path 'C:\Program Files\Git\cmd'
- **Inputs**

    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
    Need Administrator privilege.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Remove-PathFromCurrentProcessEnvPath
    
- **Description**

    Remove a path from the current process level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current process level `$Env:PATH`.
- **Parameter** `$Path`

    The path to be removed.
- **Example**

    Remove-PathFromCurrentProcessEnvPath -Path 'C:\Program Files\Git\cmd'
- **Inputs**

    String.
- **Outputs**

    None.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Remove-PathFromCurrentUserEnvPath
    
- **Description**

    Remove a path from the current user level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current user level `$Env:PATH`.
- **Parameter** `$Path`

    The path to be removed.
- **Example**

    Remove-PathFromCurrentUserEnvPath -Path 'C:\Program Files\Git\cmd'
- **Inputs**

    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Remove-SystemProxyIPV4ForCurrentUser
    
- **Description**

    Revokes all opeartions in function `Set-SystemProxyIPV4ForCurrentUser`
- **Inputs**

    None.
- **Outputs**

    None.
    
### Reset-Authorization
    
- **Synopsis**

    Reset the ACL and attributes of a path to its default state if we have already known the default state exactly.
    For more information on the motivations, rationale, logic, limitations and usage of this function, see the [post](https://little-train.com/posts/7fdde8eb.html).
    
- **Description**

    Reset ACL of `$Path` to its default state by 3 steps:
    1. Get path type by `Get-PathType`
    2. Get default SDDL of `$Path` by `Get-DefaultSddl` according to `$path_type`
    3. Set SDDL of `$Path` to default SDDL by `Set-Acl`
    
- **Parameter** `$Path`

    The path to be reset.
- **Parameter** `$Recurse`

    A switch parameter to indicate whether to reset the ACL of all files and directories in the path recursively.
- **Inputs**

    String or FormattedFileSystemPath.
- **Outputs**

    None.
- **Component**

    ```powershell
    $new_acl = Get-Acl -LiteralPath $Path
    $sddl = ... # Get default SDDL of `$Path`
    $new_acl.SetSecurityDescriptorSddlForm($sddl)
    Set-Acl -LiteralPath $Path -AclObject $new_acl
    ```
- **Notes**

    Only support Windows.
- **Link**

    [Authorization](https://little-train.com/posts/7fdde8eb.html).
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Set-DirJunctionWithSync
    
- **Description**

    Set a junction point from the path to the target.
    Then, get a result as $path\rightarrow target$, which means the path is a junction point to the target.
    Merge, cover and backup may be performed when needed.
- **Parameter** `$Path`

    The path to be set.
- **Parameter** `$Target`

    The target path.
- **Parameter** `$BackupDir`

    The backup directory path.
- **Inputs**

    String.
    String.
    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
    Need Administrator privilege.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Set-DirSymbolicLinkWithSync
    
- **Description**

    Set a directory symbolic link from the path to the target.
    Then, get a result as $path\rightarrow target$, which means the path is a symbolic link to the target.
    Merge, cover and backup may be performed when needed.
- **Parameter** `$Path`

    The path to be set.
- **Parameter** `$Target`

    The target path.
- **Parameter** `$BackupDir`

    The backup directory path.
- **Inputs**

    String.
    String.
    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
    Need Administrator privilege.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Set-EnvProxyIPV4ForShellProcess
    
- **Description**

    Set environment variables as `ServerIP:PortNumber` for the current shell process.
- **Parameter** `$ServerIP`

    The server IP address for proxy.
- **Parameter** `$PortNumber`

    The port number for proxy.
- **Example**

    Set-EnvProxyIPV4ForShellProcess -ServerIP 127.0.0.1 -PortNumber 7890
- **Inputs**

    String.
    String or Int.
- **Outputs**

    None.
- **Notes**

    Not influence system proxy.
    Only support IPV4.
    
### Set-FileSymbolicLinkWithSync
    
- **Description**

    Set a file symbolic link from the path to the target.
    Then, get a result as $path\rightarrow target$, which means the path is a symbolic link to the target.
    Merge, cover and backup may be performed when needed.
- **Parameter** `$Path`

    The path to be set.
- **Parameter** `$Target`

    The target path.
- **Parameter** `$BackupDir`

    The backup directory path.
- **Inputs**

    String.
    String.
    String.
- **Outputs**

    None.
- **Notes**

    Only support Windows.
    Need Administrator privilege.
- **Link**

    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
    
### Set-SystemProxyIPV4ForCurrentUser
    
- **Description**

    Set system proxy as `ServerIP:PortNumber` for the current user.
- **Parameter** `$ServerIP`

    The server IP address for proxy.
- **Parameter** `$PortNumber`

    The port number for proxy.
- **Example**

    Set-SystemProxyIPV4ForCurrentUser -ServerIP 127.0.0.1 -PortNumber 7890
- **Inputs**

    String.
    String or Int.
- **Outputs**

    None.
- **Notes**

    Not influence environment variables, such as `$Env:http_proxy`, `$Env:https_proxy`, `$Env:ftp_proxy`, `$Env:socks_proxy` etc.
    Not for all users (not on `local machine` level).
    Automatically add bypass list.
    Only support IPV4.
    Limitation: This function has only been tested on a Windows 11 `Virtual Machine` that is hosted by a Windows 11 `Virtual Machine` `Host Machine`.
- **Link**

    [Windows core proxy](https://www.mikesay.com/2020/02/03/windows-core-proxy/#%E7%B3%BB%E7%BB%9F%E7%BA%A7%E5%88%AB%E7%9A%84%E8%AE%BE%E7%BD%AE).
    
