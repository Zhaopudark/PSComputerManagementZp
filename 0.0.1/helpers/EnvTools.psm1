Import-Module "${PSScriptRoot}\Logger.psm1" -Scope local
function local:Write-EnvModificationLog{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('User','Process','Machine')]
        [string]$Level,
        [Parameter(Mandatory)]
        [ValidateSet('Remove','Add','Maintain','Not Add','Not Remove')]
        [string]$Type,
        [string]$Path='' # $null will be converted to empty string
    )
    $message = "Try to $($Type.ToLower()) '$Path' in '$Level' level `$Env:PATH."
    Write-VerboseLog $message -Verbose
}
function local:Test-EnvPathLevelArg{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [string]$Level
    )
    if ($Level -notin @('User','Process','Machine')){
        throw "The arg `$Level should be one of 'User','Process','Machine', not $Level."
    }elseif (($Level -eq 'Machine') -and (Get-PlatformName -eq 'Windows')){
        Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
        if(-not(Test-AdminPermission)){
            throw [System.UnauthorizedAccessException]::new("You must run this function as administrator when arg `$Level is $Level.")
        }
        else{
            return $true
        }
    }else{
        if (((Get-PlatformName -eq 'Wsl2') -or (Get-PlatformName -eq 'Linux'))`
            -and (($Level -eq 'User') -or ($Level -eq 'Machine'))){
            Write-VerboseLog  "The 'User' or 'Machine' level `$Env:PATH in current platform, $($PSVersionTable.Platform), are not supported. They can be get or set but this means nothing."
        }
        return $true
    }
}
function local:Test-EnvPathExist{
<#
.DESCRIPTION
    Test if the `Path` is `existing` or not `empty` or not `$null`.
    Show corresonding logs.
.OUTPUTS
    $true: if the `Path` is `existing` and not `empty` and not `$null`.
    $false: if the `Path` is not `existing` or is `empty` or `$null`.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level,
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Path
    )
    if ($Path -eq $null){
        Write-VerboseLog "The $Path in in '$Level' level `$Env:PATH is `$null."
        return $false
    }elseif ($Path -eq '') {
        Write-VerboseLog "The $Path in in '$Level' level `$Env:PATH is empty."
        return $false
    }elseif (-not (Test-Path -Path $Path)){
        Write-VerboseLog "The $Path in in '$Level' level `$Env:PATH is not exiting."
        return $false
    }else{
        return $true
    }
}
function local:Test-EnvPathNotDuplicated{
    <#
    .DESCRIPTION
        Test if the `Path` is `duplicated` in the `$Container`.
        Show corresonding logs.
    .OUTPUTS
        $true: if the `Path` is not `duplicated` in the `$Container`.
        $false: if the `Path` is `duplicated` in the `$Container`.

    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level,
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Container
    )
    if ($Path -in $Container){
        Write-VerboseLog "The $Path in in '$Level' level `$Env:PATH is duplicated."
        return $false
    }else{
        return $true
    }
}

function Get-EnvPathAsSplit{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level
    )
    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
    if (Get-PlatformName -eq 'Windows'){
        return @([Environment]::GetEnvironmentVariable('Path',$Level) -Split ';')

    }elseif (Get-PlatformName -eq 'Wsl2'){

        return @([Environment]::GetEnvironmentVariable('PATH',$Level) -Split ':')

    }elseif (Get-PlatformName -eq 'Linux'){
        return @([Environment]::GetEnvironmentVariable('PATH',$Level) -Split ':')

    }else{
        Write-VerboseLog  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        exit -1
    }
}
function Set-EnvPathBySplit{
    [CmdletBinding()]
    param(
        [string[]]$Paths,
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level
    )
    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
    if (Get-PlatformName -eq 'Windows'){
        [Environment]::SetEnvironmentVariable('Path',$Paths -join ';',$Level)

    }elseif (Get-PlatformName -eq 'Wsl2'){
        [Environment]::SetEnvironmentVariable('PATH',$Paths -join ':',$Level)

    }elseif (Get-PlatformName -eq 'Linux'){
        [Environment]::SetEnvironmentVariable('PATH',$Paths -join ':',$Level)

    }else{
        Write-VerboseLog  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        exit -1
    }
}
function local:Format-EnvPath{
<#
.DESCRIPTION
    Format all paths of `$Env:PATH in $Level Level:
        1. Remove the invalid (non-existent or empty or duplicated) items.
        2. Format the content of all items by `Format-Path` function.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level
    )
    $env_paths = Get-EnvPathAsSplit -Level $Level
    $out_buf = @()
    $counter = 0  # count the number of invalid path (`non-existent` or `empty` or `duplicated`)
    foreach ($item in $env_paths)
    {
        if (Test-EnvPathExist -Level $Level -Path $item){
            Import-Module "${PSScriptRoot}\PathTools.psm1" -Scope local
            $item = Format-Path -Path $item
            if (Test-EnvPathNotDuplicated -Level $Level -Path $item -Container $out_buf ){
                $out_buf += $item
            }
            else{
                Write-EnvModificationLog -Level $Level -Type 'Remove' -Path $item
                $counter += 1
            }
        }else{
            Write-EnvModificationLog -Level $Level -Type 'Remove' -Path $item
            $counter += 1
        }

    }
    Set-EnvPathBySplit -Paths $out_buf -Level $Level
    Write-VerboseLog "Formating $Level level `$Env:PATH, $counter invalid(non-existent or empty or duplicated) items have been found and merged."
}

function Merge-RedundantEnvPathFromLocalMachineToCurrentUser{
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
    [CmdletBinding()]
    param()
    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
    if(-not(Test-AdminPermission)){
        throw [System.UnauthorizedAccessException]::new("You must run this function as administrator.")
    }
    $user_env_paths = Get-EnvPathAsSplit -Level 'User'
    $machine_env_paths = Get-EnvPathAsSplit -Level 'Machine'
    $out_buf = @()
    $counter = 0  # count the number of invalid path (`non-existent` or `empty` or `duplicated`)
    foreach ($item in $machine_env_paths)
    {
        # `non-existent` and `empty` situations have been removed in `Format-EnvPath` function.
        if ($item -notin $user_env_paths){
            $out_buf += $item
        }
        else{
            Write-EnvModificationLog -Type 'Remove' -Path $item -Level 'Machine'
            $counter += 1
        }
    }
    Set-EnvPathBySplit -Paths $out_buf -Level 'Machine'
    Write-VerboseLog "$counter duplicated items between Machine level and User level `$Env:PATH have been found. And, they have been merged into User level `$Env:PATH"

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
        [string]$Path
    )
    Format-EnvPath -Level 'Process'

    # User Machine Process[Default]
    $env_paths = Get-EnvPathAsSplit -Level 'Process'

    if (Test-EnvPathExist -Level 'Process' -Path $Path){
        Import-Module "${PSScriptRoot}\PathTools.psm1" -Scope local
        $Path = Format-Path -Path $Path
        if (Test-EnvPathNotDuplicated -Level 'Process' -Path $Path -Container $env_paths ){
            Write-EnvModificationLog -Level 'Process' -Type 'Add' -Path $Path
            $env_paths += $Path
            Set-EnvPathBySplit -Paths $env_paths -Level 'Process'
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
.EXAMPLE
    # It will remove all the paths that match the pattern 'Git' in the Process level `$Env:PATH`.
    Remove-EnvPathByPattern -Pattern 'Git' -Level 'Process'.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level
    )

    Format-EnvPath -Level $Level
    $env_paths = Get-EnvPathAsSplit -Level $Level
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
    Set-EnvPathBySplit -Paths $out_buf -Level $Level
    Write-VerboseLog "$counter paths match pattern $Pattern have been totally removed from $Level level `$Env:PATH."
}
function Remove-EnvPathByTargetPath{
<#
.DESCRIPTION
    Remove the target path in `$Env:PATH` in the specified level.
.EXAMPLE
    Remove-EnvPathByTargetPath -TargetPath 'C:\Program Files\Git\cmd' -Level 'Process'
    # It will remove the path 'C:\Program Files\Git\cmd' in the Process level `$Env:PATH`.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath,
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level
    )
    Format-EnvPath -Level $Level
    $env_paths = Get-EnvPathAsSplit -Level $Level
    $out_buf = @()
    $counter = 0
    if (Test-EnvPathExist -Level $Level -Path $TargetPath){
        Import-Module "${PSScriptRoot}\PathTools.psm1" -Scope local
        $TargetPath = Format-Path -Path $TargetPath
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
    Set-EnvPathBySplit -Paths $out_buf -Level $Level
    Write-VerboseLog "$counter paths eq target $TargetPath have been totally removed from $Level level `$Env:PATH."
}