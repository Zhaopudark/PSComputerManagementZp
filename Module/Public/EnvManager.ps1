

function Merge-RedundantEnvPathsFromCurrentMachineToCurrentUser{
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
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPaths]::new()
    if($PSCmdlet.ShouldProcess("Merge redundant items from the current machine level env paths to the current user level",'','')){
        $env_paths.MergeDeDuplicatedEnvPathsFromMachineLevelToUserLevel()
    }
}

function Add-PathToCurrentProcessEnvPaths{
<#
.DESCRIPTION
    Append a path to the current process level env paths.
    Before appending, the function will check and de-duplicate the current process level env paths.
.EXAMPLE
    Add-PathToCurrentProcessEnvPaths -Path 'C:\Program Files\Git\cmd'
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    $env_paths = [EnvPaths]::new()
    $env_paths.AppendProcessLevelEnvPaths($Path)
}
function Add-PathToCurrentUserEnvPaths{
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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindows
    $env_paths = [EnvPaths]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to user level env path",'','')){
        $env_paths.AppendUserLevelEnvPaths($Path)
    }
}

function Add-PathToCurrentMachineEnvPaths{
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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPaths]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to machine level env path",'','')){
        $env_paths.AppendMachineLevelEnvPaths($Path)
    }
}  

function Remove-PathFromCurrentProcessEnvPaths{
<#
.DESCRIPTION
    Remove a path from the current process level env paths.
    Before removing, the function will check and de-duplicate the current process level env paths.
.EXAMPLE
    Remove-PathFromCurrentProcessEnvPaths -Path 'C:\Program Files\Git\cmd'
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    $env_paths = [EnvPaths]::new()
    $IsPattern = $false
    $env_paths.RemoveProcessLevelEnvPaths($Path,$IsPattern)
}

function Remove-PathFromCurrentUserEnvPaths{
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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindows
    $env_paths = [EnvPaths]::new()
    $IsPattern = $false
    if ($PSCmdlet.ShouldProcess("Remove $Path from user level env path",'','')){
        $env_paths.RemoveUserLevelEnvPaths($Path,$IsPattern)
    }
}

function Remove-PathFromCurrentMachineEnvPaths{
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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPaths]::new()
    $IsPattern = $false
    if ($PSCmdlet.ShouldProcess("Remove $Path from machine level env path",'','')){
        $env_paths.RemoveMachineLevelEnvPaths($Path,$IsPattern)
    }
}
function Remove-MatchedPathsFromCurrentProcessEnvPaths{
<#
.DESCRIPTION
    Remove matched paths from the current process level env paths.
    Before removing, the function will check and de-duplicate the current process level env paths.
.EXAMPLE
    Remove-MatchedPathsFromCurrentProcessEnvPaths -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the process level env paths.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    $env_paths = [EnvPaths]::new()
    $IsPattern = $true
    $env_paths.RemoveProcessLevelEnvPaths($Pattern,$IsPattern)
}

function Remove-MatchedPathsFromCurrentUserEnvPaths{
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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    Assert-IsWindows
    $env_paths = [EnvPaths]::new()
    $IsPattern = $true
    if ($PSCmdlet.ShouldProcess("Remove items that match ``$($Pattern)`` from user level env path",'','')){
        $env_paths.RemoveUserLevelEnvPaths($Pattern,$IsPattern)
    }
}

function Remove-MatchedPathsFromCurrentMachineEnvPaths{
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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPaths]::new()
    $IsPattern = $true
    if ($PSCmdlet.ShouldProcess("Remove items that match ``$($Pattern)`` from machine level env path",'','')){
        $env_paths.RemoveMachineLevelEnvPaths($Pattern,$IsPattern)
    }
}