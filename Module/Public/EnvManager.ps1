function Merge-RedundantEnvPathFromLocalMachineToCurrentUser{
<#
.SYNOPSIS
    Merge redundant items form Machine Level env PATH to User Level Env PATH.
.DESCRIPTION
    Sometimes, we may find some redundant items that both
    in Machine Level $Env:PATH and User Level $Env:PATH.
    This may because we have installed some software in different privileges.

    This function will help us to merge the redundant items from Machine Level $Env:PATH to User Level $Env:PATH.
    The operation will symplify the `$Env:PATH`.

    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.NOTES
    Do not check or remove the invalid (non-existent or empty or duplicated) items in each single level as the `Format-EnvPath` function does.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Assert-IsWindowsAndAdmin
    $user_env_paths = Get-EnvPathAsSplit -Level 'User' -SkipLevelCheck
    $machine_env_paths = Get-EnvPathAsSplit -Level 'Machine' -SkipLevelCheck
    $out_buf = @()
    $log_buf = @() # Record the number of invalid path (`non-existent` or `empty` or `duplicated`)
    foreach ($item in $machine_env_paths)
    {
        # `non-existent` and `empty` situations have been removed in `Format-EnvPath` function.
        if ($item -notin $user_env_paths){
            $out_buf += $item
        }
        else{
            $log_buf += $item
            Write-EnvModificationLog -Type 'Remove' -Path $item -Level 'Machine'
        }
    }
    if($PSCmdlet.ShouldProcess("Merge $($log_buf.Count) redundant items:"+[Environment]::NewLine+
        "$log_buf"+[Environment]::NewLine+
        "from Machine Level to User Level `$Env:PATH",'','')){
        Set-EnvPathBySplit -Paths $out_buf -Level 'Machine' -SkipLevelCheck
        Write-VerboseLog "$counter duplicated items between Machine level and User level `$Env:PATH have been found. And, they have been merged into User level `$Env:PATH"
    }
}


function Add-EnvPathToCurrentProcess{
<#
.DESCRIPTION
    Add the `Path` to the `$Env:PATH` in `Process` level.
    Format the `Process` level `$Env:PATH` by the function `Format-EnvPath` at the same time.
.EXAMPLE
    Add-EnvPathToCurrentProcess -Path 'C:\Program Files\Git\cmd'
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [FormattedFileSystemPath]$Path
    )
    Format-EnvPath -Level 'Process' -SkipLevelCheck

    # User Machine Process[Default]
    $env_paths = Get-EnvPathAsSplit -Level 'Process' -SkipLevelCheck

    if (Test-Path -LiteralPath $Path){

        if ($Path -notin $env_paths){
            Write-EnvModificationLog -Level 'Process' -Type 'Add' -Path $Path
            $env_paths += $Path
            Set-EnvPathBySplit -Paths $env_paths -Level 'Process' -SkipLevelCheck
            Write-VerboseLog "The path '$Path' has been added into Process level `$Env:PATH."
        }
        else{
            Write-EnvModificationLog -Level 'Process' -Type 'Maintain' -Path $Path
        }
    }else{
        Write-EnvModificationLog -Level 'Process' -Type 'Not Add' -Path $Path
    }
}


function Remove-EnvPathByPattern{
<#
.DESCRIPTION
    Remove the paths that match the pattern in `$Env:PATH` in the specified level.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    # It will remove all the paths that match the pattern 'Git' in the Process level `$Env:PATH`.
    Remove-EnvPathByPattern -Pattern 'Git' -Level 'Process'.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [Parameter(Mandatory)]
        [string]$Level
    )
    Assert-ValidLevel4EnvTools $Level
    if($PSCmdlet.ShouldProcess("$Level level `$Env:PATH","remove items matched pattern `{$Pattern}` ")){
        Format-EnvPath -Level $Level -SkipLevelCheck
        $env_paths = Get-EnvPathAsSplit -Level $Level -SkipLevelCheck
        $out_buf = @()
        $counter = 0
        foreach ($item in $env_paths)
        {
            if ($item -notmatch $Pattern){
                $out_buf += $item
            }
            else{
                Write-EnvModificationLog -Level $Level -Type 'Remove' -Path $item
                $counter += 1
            }
        }
        Set-EnvPathBySplit -Paths $out_buf -Level $Level -SkipLevelCheck
        Write-VerboseLog "$counter paths match pattern $Pattern have been totally removed from $Level level `$Env:PATH."
    }
}
function Remove-EnvPathByTargetPath{
<#
.DESCRIPTION
    Remove the target path in `$Env:PATH` in the specified level.
    See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    Remove-EnvPathByTargetPath -TargetPath 'C:\Program Files\Git\cmd' -Level 'Process'
    # It will remove the path 'C:\Program Files\Git\cmd' in the Process level `$Env:PATH`.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath,
        [Parameter(Mandatory)]
        [string]$Level
    )
    Assert-ValidLevel4EnvTools $Level
    if($PSCmdlet.ShouldProcess("$Level level `$Env:PATH","remove target `{$TargetPath}` ")){
        Format-EnvPath -Level $Level -SkipLevelCheck
        $env_paths = Get-EnvPathAsSplit -Level $Level -SkipLevelCheck
        $out_buf = @()
        $counter = 0
        if (Test-Path -LiteralPath $TargetPath){

            $TargetPath = [FormattedFileSystemPath]::new($TargetPath)
            foreach ($item in $env_paths)
            {
                if ($item -ne $TargetPath){
                    $out_buf += $item
                }
                else{
                    Write-EnvModificationLog -Level $Level -Type 'Remove' -Path $item
                    $counter += 1
                }
            }
        }else{
            Write-EnvModificationLog -Level $Level -Type 'Not Remove' -Path $TargetPath
        }
        Set-EnvPathBySplit -Paths $out_buf -Level $Level -SkipLevelCheck
        Write-VerboseLog "$counter paths eq target $TargetPath have been totally removed from $Level level `$Env:PATH."
    }
}