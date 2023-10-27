

function Merge-RedundantEnvPathFromCurrentMachineToCurrentUser{
<#
.DESCRIPTION
    Merge redundant items form the current machine level `$Env:PATH` to the current user level.
    Before merging, the function will check and de-duplicate the current machine level and the current user level `$Env:PATH`.
.INPUTS
    None.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
    Need Administrator privilege.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPath]::new()
    if($PSCmdlet.ShouldProcess("Merge redundant items from the current machine level `$Env:PATH` to the current user level",'','')){
        $env_paths.MergeDeDuplicatedEnvPathFromMachineLevelToUserLevel()
    }
}

function Add-PathToCurrentProcessEnvPath{
<#
.DESCRIPTION
    Add a path to the current process level `$Env:PATH`.
    Before adding, the function will check and de-duplicate the current process level `$Env:PATH`.
    The default behavior is to prepend. It can be changed by the given the switch `-IsAppend`.
    If the path already exists, it will be moved to the head or the tail according to `-IsAppend`.
.PARAMETER Path
    The path to be appended.
.PARAMETER IsAppend
    If the switch is specified, the path will be appended.
.EXAMPLE
    Add-PathToCurrentProcessEnvPath -Path 'C:\Program Files\Git\cmd'
.INPUTS
    String.
.OUTPUTS
    None.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$IsAppend
    )
    $env_paths = [EnvPath]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to process level `$Env:PATH`.",'','')){
        $env_paths.AddProcessLevelEnvPath($Path,$IsAppend)
    }
}
function Add-PathToCurrentUserEnvPath{
<#
.DESCRIPTION
    Add a path to the current user level `$Env:PATH`.
    Before adding, the function will check and de-duplicate the current user level `$Env:PATH`.
    The default behavior is to prepend. It can be changed by the given the switch `-IsAppend`.
    If the path already exists, it will be moved to the head or the tail according to `-IsAppend`.
.PARAMETER Path
    The path to be appended.
.PARAMETER IsAppend
    If the switch is specified, the path will be appended.
.EXAMPLE
    Add-PathToCurrentUserEnvPath -Path 'C:\Program Files\Git\cmd'
.INPUTS
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$IsAppend
    )
    Assert-IsWindows
    $env_paths = [EnvPath]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to user level `$Env:PATH`.",'','')){
        $env_paths.AddUserLevelEnvPath($Path,$IsAppend)
    }
}

function Add-PathToCurrentMachineEnvPath{
<#
.DESCRIPTION
    Add a path to the current machine level `$Env:PATH`.
    Before adding, the function will check and de-duplicate the current machine level `$Env:PATH`.
    The default behavior is to prepend. It can be changed by the given the switch `-IsAppend`.
    If the path already exists, it will be moved to the head or the tail according to `-IsAppend`.
.PARAMETER Path
    The path to be appended.
.PARAMETER IsAppend
    If the switch is specified, the path will be appended.
.EXAMPLE
    Add-PathToCurrentMachineEnvPath -Path 'C:\Program Files\Git\cmd'
.INPUTS
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
    Need Administrator privilege.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$IsAppend
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPath]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to machine level `$Env:PATH`.",'','')){
        $env_paths.AddMachineLevelEnvPath($Path,$IsAppend)
    }
}

function Remove-PathFromCurrentProcessEnvPath{
<#
.DESCRIPTION
    Remove a path from the current process level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current process level `$Env:PATH`.
.PARAMETER Path
    The path to be removed.
.EXAMPLE
    Remove-PathFromCurrentProcessEnvPath -Path 'C:\Program Files\Git\cmd'
.INPUTS
    String.
.OUTPUTS
    None.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    $env_paths = [EnvPath]::new()
    $IsPattern = $false
    if ($PSCmdlet.ShouldProcess("Remove $Path from process level `$Env:PATH`.",'','')){
        $env_paths.RemoveProcessLevelEnvPath($Path,$IsPattern)
    }
}

function Remove-PathFromCurrentUserEnvPath{
<#
.DESCRIPTION
    Remove a path from the current user level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current user level `$Env:PATH`.
.PARAMETER Path
    The path to be removed.
.EXAMPLE
    Remove-PathFromCurrentUserEnvPath -Path 'C:\Program Files\Git\cmd'
.INPUTS
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindows
    $env_paths = [EnvPath]::new()
    $IsPattern = $false
    if ($PSCmdlet.ShouldProcess("Remove $Path from user level `$Env:PATH`.",'','')){
        $env_paths.RemoveUserLevelEnvPath($Path,$IsPattern)
    }
}

function Remove-PathFromCurrentMachineEnvPath{
<#
.DESCRIPTION
    Remove a path from the current machine level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current machine level `$Env:PATH`.
.PARAMETER Path
    The path to be removed.
.EXAMPLE
    Remove-PathFromCurrentMachineEnvPath -Path 'C:\Program Files\Git\cmd'
.INPUTS
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
    Need Administrator privilege.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPath]::new()
    $IsPattern = $false
    if ($PSCmdlet.ShouldProcess("Remove $Path from machine level `$Env:PATH`.",'','')){
        $env_paths.RemoveMachineLevelEnvPath($Path,$IsPattern)
    }
}
function Remove-MatchedPathsFromCurrentProcessEnvPath{
<#
.DESCRIPTION
    Remove matched paths from the current process level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current process level `$Env:PATH`.
.PARAMETER Pattern
    The pattern to be matched to represent the items to be removed.
.EXAMPLE
    Remove-MatchedPathsFromCurrentProcessEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the process level `$Env:PATH`.
.INPUTS
    String.
.OUTPUTS
    None.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    $env_paths = [EnvPath]::new()
    $IsPattern = $true
    if ($PSCmdlet.ShouldProcess("Remove items that match ``$($Pattern)`` from process level `$Env:PATH`.",'','')){
        $env_paths.RemoveProcessLevelEnvPath($Pattern,$IsPattern)
    }
}

function Remove-MatchedPathsFromCurrentUserEnvPath{
<#
.DESCRIPTION
    Remove matched paths from the current user level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current user level `$Env:PATH`.
.PARAMETER Pattern
    The pattern to be matched to represent the items to be removed.
.EXAMPLE
    Remove-MatchedPathsFromCurrentUserEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the user level `$Env:PATH`.
.INPUTS
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    Assert-IsWindows
    $env_paths = [EnvPath]::new()
    $IsPattern = $true
    if ($PSCmdlet.ShouldProcess("Remove items that match ``$($Pattern)`` from user level `$Env:PATH`.",'','')){
        $env_paths.RemoveUserLevelEnvPath($Pattern,$IsPattern)
    }
}

function Remove-MatchedPathsFromCurrentMachineEnvPath{
<#
.DESCRIPTION
    Remove matched paths from the current machine level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current machine level `$Env:PATH`.
.PARAMETER Pattern
    The pattern to be matched to represent the items to be removed.
.EXAMPLE
    Remove-MatchedPathsFromCurrentMachineEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the machine level `$Env:PATH`.
.INPUTS
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
    Need Administrator privilege.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPath]::new()
    $IsPattern = $true
    if ($PSCmdlet.ShouldProcess("Remove items that match ``$($Pattern)`` from machine level `$Env:PATH`.",'','')){
        $env_paths.RemoveMachineLevelEnvPath($Pattern,$IsPattern)
    }
}
