

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
    Support Windows only.
    Need Administrator privilege.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.DESCRIPTION
    Sometimes, we may find some redundant items that both in the machine level and the user level `$Env:PATH`.
    This may because we have installed some software in different privileges.
    This function will help us to merge the redundant items from the machine level `$Env:PATH` to the user level.
    The operation can symplify the `$Env:PATH`.
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
    Append a path to the current process level `$Env:PATH`.
    Before appending, the function will check and de-duplicate the current process level `$Env:PATH`.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.EXAMPLE
    Add-PathToCurrentProcessEnvPath -Path 'C:\Program Files\Git\cmd'
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    $env_paths = [EnvPath]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to process level `$Env:PATH`.",'','')){
        $env_paths.AppendProcessLevelEnvPath($Path)
    }
}
function Add-PathToCurrentUserEnvPath{
<#
.DESCRIPTION
    Append a path to the current user level `$Env:PATH`.
    Before appending, the function will check and de-duplicate the current user level `$Env:PATH`.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Add-PathToCurrentUserEnvPath -Path 'C:\Program Files\Git\cmd'
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindows
    $env_paths = [EnvPath]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to user level `$Env:PATH`.",'','')){
        $env_paths.AppendUserLevelEnvPath($Path)
    }
}

function Add-PathToCurrentMachineEnvPath{
<#
.DESCRIPTION
    Append a path to the current machine level `$Env:PATH`.
    Before appending, the function will check and de-duplicate the current machine level `$Env:PATH`.
.INPUTS
    A string of the path.
.PARAMETER Path
    The path to be appended.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Add-PathToCurrentMachineEnvPath -Path 'C:\Program Files\Git\cmd'
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPath]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to machine level `$Env:PATH`.",'','')){
        $env_paths.AppendMachineLevelEnvPath($Path)
    }
}

function Remove-PathFromCurrentProcessEnvPath{
<#
.DESCRIPTION
    Remove a path from the current process level `$Env:PATH`.
    Before removing, the function will check and de-duplicate the current process level `$Env:PATH`.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.EXAMPLE
    Remove-PathFromCurrentProcessEnvPath -Path 'C:\Program Files\Git\cmd'
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
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-PathFromCurrentUserEnvPath -Path 'C:\Program Files\Git\cmd'
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
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-PathFromCurrentMachineEnvPath -Path 'C:\Program Files\Git\cmd'
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
.INPUTS
    A string of pattern.
.OUTPUTS
    None.
.EXAMPLE
    Remove-MatchedPathsFromCurrentProcessEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the process level `$Env:PATH`.
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
.INPUTS
    A string of pattern.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-MatchedPathsFromCurrentUserEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the user level `$Env:PATH`.
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
.INPUTS
    A string of pattern.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-MatchedPathsFromCurrentMachineEnvPath -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the machine level `$Env:PATH`.
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
