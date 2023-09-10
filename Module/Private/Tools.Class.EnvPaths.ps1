class EnvPaths{
<#
.SYNOPSIS
    A class that maintains the process, user, and machine level env paths, holds the de-duplicated paths, and provides some useful methods for some scenarios that need to modify the env paths.
.NOTES
    Do not check any path's existence or validity.
#>
    [ValidateNotNullOrEmpty()][string] $OriginalPlatform
    [ValidateNotNullOrEmpty()][string] $Indicator
    [ValidateNotNullOrEmpty()][string] $Separator
    [ValidateNotNullOrEmpty()][string[]] $ProcessLevelEnvPaths
    [AllowNull()][string[]] $UserLevelEnvPaths
    [AllowNull()][string[]] $MachineLevelEnvPaths
    [ValidateNotNullOrEmpty()][string[]] $DeDuplicatedProcessLevelEnvPaths
    [AllowNull()][string[]] $DeDuplicatedUserLevelEnvPaths
    [AllowNull()][string[]] $DeDuplicatedMachineLevelEnvPaths
    EnvPaths() {
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
        $this.ProcessLevelEnvPaths = @([Environment]::GetEnvironmentVariable($this.Indicator,'Process') -Split $this.Separator)
        $this.UserLevelEnvPaths = @([Environment]::GetEnvironmentVariable($this.Indicator,'User') -Split $this.Separator)
        $this.MachineLevelEnvPaths = @([Environment]::GetEnvironmentVariable($this.Indicator,'Machine') -Split $this.Separator)

        $this.ProcessLevelEnvPaths = $this.DeEmpty($this.ProcessLevelEnvPaths)
        $this.UserLevelEnvPaths = $this.DeEmpty($this.UserLevelEnvPaths)
        $this.MachineLevelEnvPaths = $this.DeEmpty($this.MachineLevelEnvPaths)

        if ($this.OriginalPlatform -eq "Unix"){
            if ($this.UserLevelEnvPaths.Count -ne 0){
                throw "In Unix platform, the User level env path should be empty. But it is $($this.UserLevelEnvPaths)."
            }
            if ($this.MachineLevelEnvPaths.Count -ne 0){
                throw "In Unix platform, the Machine level env path should be empty. But it is $($this.MachineLevelEnvPaths)."
            }
        }
        $verbose = $false
        $this.DeDuplicatedProcessLevelEnvPaths = $this.DeDuplicate($this.ProcessLevelEnvPaths,'Process',$verbose)
        $this.DeDuplicatedUserLevelEnvPaths = $this.DeDuplicate($this.UserLevelEnvPaths,'Process',$verbose)
        $this.DeDuplicatedMachineLevelEnvPaths = $this.DeDuplicate($this.MachineLevelEnvPaths,'Process',$verbose)
    }

    [void] FindDuplicatedPaths([string[]] $Paths, [string] $Level,[bool]$Verbose){
        $grouped_paths = $Paths | Group-Object
        $duplicated_groups = $grouped_paths | Where-Object { $_.Count -gt 1 }

        if ($Verbose){
            foreach ($group in $duplicated_groups) {
                Write-Log "[Env Paths Duplicated] The $($group.Name) in '$Level' level env path exists $($group.Count) times." -ShowVerbose
            }
        }else{
            foreach ($group in $duplicated_groups) {
                Write-Log "[Env Paths Duplicated] The $($group.Name) in '$Level' level env path exists $($group.Count) times."
            }
        }
    }
    [string[]] DeEmpty([string[]] $Paths){
        $buf = @()
        foreach ($item in $Paths)
        {
            if ($item.Trim()){
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
    [void] DeDuplicateProcessLevelEnvPaths(){
        $verbose = $true
        $this.ProcessLevelEnvPaths = $this.DeDuplicate($this.ProcessLevelEnvPaths,'Process',$verbose)
        $this.SetEnvPath($this.ProcessLevelEnvPaths,'Process')
        Write-Log "[Env Paths Modifed] The 'Process' level env path has been de-duplicated." -ShowVerbose
    }
    [void] DeDuplicateUserLevelEnvPaths(){
        $verbose = $true
        $this.UserLevelEnvPaths = $this.DeDuplicate($this.UserLevelEnvPaths,'User',$verbose)
        $this.SetEnvPath($this.UserLevelEnvPaths,'User')
        Write-Log "[Env Paths Modifed] The 'User' level env path has been de-duplicated." -ShowVerbose
    }
    [void] DeDuplicateMachineLevelEnvPaths(){
        $verbose = $true
        $this.MachineLevelEnvPaths = $this.DeDuplicate($this.MachineLevelEnvPaths,'Machine',$verbose)
        $this.SetEnvPath($this.MachineLevelEnvPaths,'Machine')
        Write-Log "[Env Paths Modifed] The 'Machine' level env path has been de-duplicated." -ShowVerbose
    }
    [void] MergeDeDuplicatedEnvPathsFromMachineLevelToUserLevel(){
        $this.DeDuplicateUserLevelEnvPaths()
        $this.DeDuplicateMachineLevelEnvPaths()

        $buf = $this.UserLevelEnvPaths+$this.MachineLevelEnvPaths
        $verbose = $true
        $this.FindDuplicatedPaths($buf,'User+Machine',$verbose)
        $buf = @()
        foreach ($item in $this.MachineLevelEnvPaths)
        {
            if (-not $this.UserLevelEnvPaths.Contains($item)){
                $buf += $item
            }
        }
        $this.MachineLevelEnvPaths = $buf
        $this.SetEnvPath($this.MachineLevelEnvPaths,'Machine')
        Write-Log "[Env Paths Modifed] The items duplicated across 'Machine' level and 'User' level env path have been merged into 'User' level env path." -ShowVerbose
    }
    [string[]] Append([string[]] $Paths, [string] $Level,[string] $Path){
        $buf = $Paths.Clone()
        if (-not $buf.Contains($Path)){
            $buf += $Path
        }else{
            Write-Log "[Env Paths Duplicated] The $Path in '$Level' level is existing already." -ShowVerbose
        }
        return $buf
    }

    [void] AppendProcessLevelEnvPaths([string] $Path){
        $this.DeDuplicateProcessLevelEnvPaths()
        $this.ProcessLevelEnvPaths = $this.Append($this.ProcessLevelEnvPaths,'Process',$Path)
        $this.SetEnvPath($this.ProcessLevelEnvPaths,'Process')
        Write-Log "[Env Paths Modifed] The $Path has been appended into 'Process' level env path." -ShowVerbose
    }
    [void] AppendUserLevelEnvPaths([string] $Path){
        $this.DeDuplicateUserLevelEnvPaths()
        $this.UserLevelEnvPaths = $this.Append($this.UserLevelEnvPaths,'User',$Path)
        $this.SetEnvPath($this.UserLevelEnvPaths,'User')
        Write-Log "[Env Paths Modifed] The $Path has been appended into 'User' level env path." -ShowVerbose
    }
    [void] AppendMachineLevelEnvPaths([string] $Path){
        $this.DeDuplicateMachineLevelEnvPaths()
        $this.MachineLevelEnvPaths = $this.Append($this.MachineLevelEnvPaths,'Machine',$Path)
        $this.SetEnvPath($this.MachineLevelEnvPaths,'Machine')
        Write-Log "[Env Paths Modifed] The $Path has been appended into 'Machine' level env path." -ShowVerbose
    }

    [string[]] Remove([string[]] $Paths, [string] $Level, [string] $Path, [bool] $IsPattern){
        $buf = @()
        foreach ($item in $Paths)
        {
            if ($IsPattern){
                if ($item -NotMatch $Path){
                    $buf += $item
                }else{
                    Write-Log "[Env Paths to Remove] The $item in '$Level' level will be removed." -ShowVerbose
                }
            }else{
                if ($item -ne $Path){
                    $buf += $item
                }else{
                    Write-Log "[Env Paths to Remove] The $item in '$Level' level will be removed." -ShowVerbose
                }
            }
        }
        return $buf
    }
    [void] RemoveProcessLevelEnvPaths([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateProcessLevelEnvPaths()
        $this.ProcessLevelEnvPaths = $this.Remove($this.ProcessLevelEnvPaths,'Process',$Target,$IsPattern)
        $this.SetEnvPath($this.ProcessLevelEnvPaths,'Process')
        Write-Log "[Env Paths Modifed] The removement has been done on 'Process' level env path." -ShowVerbose
    }
    [void] RemoveUserLevelEnvPaths([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateUserLevelEnvPaths()
        $this.UserLevelEnvPaths = $this.Remove($this.UserLevelEnvPaths,'User',$Target,$IsPattern)
        $this.SetEnvPath($this.UserLevelEnvPaths,'User')
        Write-Log "[Env Paths Modifed] The removement has been done on 'User' level env path." -ShowVerbose
    }
    [void] RemoveMachineLevelEnvPaths([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateMachineLevelEnvPaths()
        $this.MachineLevelEnvPaths = $this.Remove($this.MachineLevelEnvPaths,'Machine',$Target,$IsPattern)
        $this.SetEnvPath($this.MachineLevelEnvPaths,'Machine')
        Write-Log "[Env Paths Modifed] The removement has been done on 'Machine' level env path." -ShowVerbose
    }
}

function Get-EnvPaths{
<#
.DESCRIPTION
    A function to apply the class EnvPaths.
    Return an instance of it.
#>
    param()
    return [EnvPaths]::new()
}