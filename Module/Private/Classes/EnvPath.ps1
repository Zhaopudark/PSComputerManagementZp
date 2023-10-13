class EnvPath{
<#
.DESCRIPTION
    A class that maintains the process, user, and machine level `$Env:PATH`, holds the de-duplicated paths, and provides some useful methods for some scenarios that need to modify the `$Env:PATH`.
.INPUTS
    None.
.OUTPUTS
    EnvPath.
.NOTES
    Do not check any path's existence or validity.
#>
    [ValidateNotNullOrEmpty()][string] $OriginalPlatform
    [ValidateNotNullOrEmpty()][string] $Indicator
    [ValidateNotNullOrEmpty()][string] $Separator
    [ValidateNotNullOrEmpty()][string[]] $ProcessLevelEnvPath
    [AllowNull()][string[]] $UserLevelEnvPath
    [AllowNull()][string[]] $MachineLevelEnvPath
    [ValidateNotNullOrEmpty()][string[]] $DeDuplicatedProcessLevelEnvPath
    [AllowNull()][string[]] $DeDuplicatedUserLevelEnvPath
    [AllowNull()][string[]] $DeDuplicatedMachineLevelEnvPath
    EnvPath() {
        if ([Environment]::OSVersion.Platform -eq "Win32NT"){
            $this.OriginalPlatform = "Win32NT"
            $this.Indicator = 'Path'
            $this.Separator = ';'
        }elseif ([Environment]::OSVersion.Platform -eq "Unix") {
            $this.OriginalPlatform = "Unix"
            $this.Indicator = 'PATH'
            $this.Separator = ':'
        }else{
            throw "Only Win32NT and Unix are supported, not $($global:PSVersionTable.Platform)."
        }

        $this.ProcessLevelEnvPath = $this.DeEmptyAndDeShadow([Environment]::GetEnvironmentVariable($this.Indicator,'Process') -Split $this.Separator)
        $this.UserLevelEnvPath = $this.DeEmptyAndDeShadow([Environment]::GetEnvironmentVariable($this.Indicator,'User') -Split $this.Separator)
        $this.MachineLevelEnvPath = $this.DeEmptyAndDeShadow([Environment]::GetEnvironmentVariable($this.Indicator,'Machine') -Split $this.Separator)

        if ($this.OriginalPlatform -eq "Unix"){
            if ($this.UserLevelEnvPath.Count -ne 0){
                throw "In Unix platform, the User level `$Env:PATH` should be empty. But it is $($this.UserLevelEnvPath)."
            }
            if ($this.MachineLevelEnvPath.Count -ne 0){
                throw "In Unix platform, the Machine level `$Env:PATH` should be empty. But it is $($this.MachineLevelEnvPath)."
            }
        }
        $verbose = $false
        $this.DeDuplicatedProcessLevelEnvPath = $this.DeDuplicate($this.ProcessLevelEnvPath,'Process',$verbose)
        $this.DeDuplicatedUserLevelEnvPath = $this.DeDuplicate($this.UserLevelEnvPath,'Process',$verbose)
        $this.DeDuplicatedMachineLevelEnvPath = $this.DeDuplicate($this.MachineLevelEnvPath,'Process',$verbose)
    }

    [void] FindDuplicatedPaths([string[]] $Paths, [string] $Level,[bool]$Verbose){
        $grouped_paths = $Paths | Group-Object
        $duplicated_groups = $grouped_paths | Where-Object { $_.Count -gt 1 }

        if ($Verbose){
            foreach ($group in $duplicated_groups) {
                Write-Log "[`$Env:PATH` Duplicated] The $($group.Name) in '$Level' level `$Env:PATH` exists $($group.Count) times." -ShowVerbose
            }
        }else{
            foreach ($group in $duplicated_groups) {
                Write-Log "[`$Env:PATH` Duplicated] The $($group.Name) in '$Level' level `$Env:PATH` exists $($group.Count) times."
            }
        }
    }
    [string[]] DeEmptyAndDeShadow([string[]] $Paths){
        # remove '' and '.' paths
        $buf = @()
        foreach ($item in $Paths)
        {
            if ($item.Trim('. ')){
                $buf += $item
            }
        }
        return $buf
    }
    [string[]] DeDuplicate([string[]] $Paths, [string] $Level,[bool]$Verbose){
        $this.FindDuplicatedPaths($Paths,$Level,$Verbose)
        $buf = @()
        foreach ($item in $Paths)
        {
            if (-not $buf.Contains($item)){
                $buf += $item
            }
        }
        return $buf
    }
    [void] SetEnvPath([string[]] $Paths, [string] $Level){
        [Environment]::SetEnvironmentVariable($this.Indicator,$Paths -join $this.Separator,$Level)
    }
    [void] DeDuplicateProcessLevelEnvPath(){
        $verbose = $true
        $this.ProcessLevelEnvPath = $this.DeDuplicate($this.ProcessLevelEnvPath,'Process',$verbose)
        $this.SetEnvPath($this.ProcessLevelEnvPath,'Process')
        Write-Log "[`$Env:PATH` Modifed] The 'Process' level `$Env:PATH` has been de-duplicated." -ShowVerbose
    }
    [void] DeDuplicateUserLevelEnvPath(){
        $verbose = $true
        $this.UserLevelEnvPath = $this.DeDuplicate($this.UserLevelEnvPath,'User',$verbose)
        $this.SetEnvPath($this.UserLevelEnvPath,'User')
        Write-Log "[`$Env:PATH` Modifed] The 'User' level `$Env:PATH` has been de-duplicated." -ShowVerbose
    }
    [void] DeDuplicateMachineLevelEnvPath(){
        $verbose = $true
        $this.MachineLevelEnvPath = $this.DeDuplicate($this.MachineLevelEnvPath,'Machine',$verbose)
        $this.SetEnvPath($this.MachineLevelEnvPath,'Machine')
        Write-Log "[`$Env:PATH` Modifed] The 'Machine' level `$Env:PATH` has been de-duplicated." -ShowVerbose
    }
    [void] MergeDeDuplicatedEnvPathFromMachineLevelToUserLevel(){
        $this.DeDuplicateUserLevelEnvPath()
        $this.DeDuplicateMachineLevelEnvPath()

        $buf = $this.UserLevelEnvPath+$this.MachineLevelEnvPath
        $verbose = $true
        $this.FindDuplicatedPaths($buf,'User+Machine',$verbose)
        $buf = @()
        foreach ($item in $this.MachineLevelEnvPath)
        {
            if (-not $this.UserLevelEnvPath.Contains($item)){
                $buf += $item
            }
        }
        $this.MachineLevelEnvPath = $buf
        $this.SetEnvPath($this.MachineLevelEnvPath,'Machine')
        Write-Log "[`$Env:PATH` Modifed] The items duplicated across 'Machine' level and 'User' level `$Env:PATH` have been merged into 'User' level `$Env:PATH`." -ShowVerbose
    }
    [string[]] Append([string[]] $Paths, [string] $Level,[string] $Path){
        $buf = $Paths.Clone()
        if (-not $buf.Contains($Path)){
            $buf += $Path
        }else{
            Write-Log "[`$Env:PATH` Duplicated] The $Path in '$Level' level is existing already." -ShowVerbose
        }
        return $buf
    }

    [void] AppendProcessLevelEnvPath([string] $Path){
        $this.DeDuplicateProcessLevelEnvPath()
        $this.ProcessLevelEnvPath = $this.Append($this.ProcessLevelEnvPath,'Process',$Path)
        $this.SetEnvPath($this.ProcessLevelEnvPath,'Process')
        Write-Log "[`$Env:PATH` Modifed] The $Path has been appended into 'Process' level `$Env:PATH`." -ShowVerbose
    }
    [void] AppendUserLevelEnvPath([string] $Path){
        $this.DeDuplicateUserLevelEnvPath()
        $this.UserLevelEnvPath = $this.Append($this.UserLevelEnvPath,'User',$Path)
        $this.SetEnvPath($this.UserLevelEnvPath,'User')
        Write-Log "[`$Env:PATH` Modifed] The $Path has been appended into 'User' level `$Env:PATH`." -ShowVerbose
    }
    [void] AppendMachineLevelEnvPath([string] $Path){
        $this.DeDuplicateMachineLevelEnvPath()
        $this.MachineLevelEnvPath = $this.Append($this.MachineLevelEnvPath,'Machine',$Path)
        $this.SetEnvPath($this.MachineLevelEnvPath,'Machine')
        Write-Log "[`$Env:PATH` Modifed] The $Path has been appended into 'Machine' level `$Env:PATH`." -ShowVerbose
    }

    [string[]] Remove([string[]] $Paths, [string] $Level, [string] $Path, [bool] $IsPattern){
        $buf = @()
        foreach ($item in $Paths)
        {
            if ($IsPattern){
                if ($item -NotMatch $Path){
                    $buf += $item
                }else{
                    Write-Log "[`$Env:PATH` to Remove] The $item in '$Level' level will be removed." -ShowVerbose
                }
            }else{
                if ($item -ne $Path){
                    $buf += $item
                }else{
                    Write-Log "[`$Env:PATH` to Remove] The $item in '$Level' level will be removed." -ShowVerbose
                }
            }
        }
        return $buf
    }
    [void] RemoveProcessLevelEnvPath([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateProcessLevelEnvPath()
        $this.ProcessLevelEnvPath = $this.Remove($this.ProcessLevelEnvPath,'Process',$Target,$IsPattern)
        $this.SetEnvPath($this.ProcessLevelEnvPath,'Process')
        Write-Log "[`$Env:PATH` Modifed] The removement has been done on 'Process' level `$Env:PATH`." -ShowVerbose
    }
    [void] RemoveUserLevelEnvPath([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateUserLevelEnvPath()
        $this.UserLevelEnvPath = $this.Remove($this.UserLevelEnvPath,'User',$Target,$IsPattern)
        $this.SetEnvPath($this.UserLevelEnvPath,'User')
        Write-Log "[`$Env:PATH` Modifed] The removement has been done on 'User' level `$Env:PATH`." -ShowVerbose
    }
    [void] RemoveMachineLevelEnvPath([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateMachineLevelEnvPath()
        $this.MachineLevelEnvPath = $this.Remove($this.MachineLevelEnvPath,'Machine',$Target,$IsPattern)
        $this.SetEnvPath($this.MachineLevelEnvPath,'Machine')
        Write-Log "[`$Env:PATH` Modifed] The removement has been done on 'Machine' level `$Env:PATH`." -ShowVerbose
    }
}

function Get-EnvPath{
<#
.DESCRIPTION
    A function to apply the class EnvPath.
    Return an instance of it.
.INPUTS
    None.
.OUTPUTS
    EnvPath.
#>
    param()
    return [EnvPath]::new()
}