function Write-EnvModificationLog{
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
function Assert-ValidLevel4EnvTools{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [string]$Level
    )
    if ($Level -notin @('User','Process','Machine')){
        throw "The arg `$Level should be one of 'User','Process','Machine', not $Level."
    }elseif (($Level -eq 'Machine') -and (Test-Platform 'Windows')){
        Assert-AdminPermission
    }else{
        if (((Test-Platform 'Wsl2') -or (Test-Platform 'Linux'))`
            -and ($Level -in @('User','Machine'))){
            Write-VerboseLog  "The 'User' or 'Machine' level `$Env:PATH in current platform, $($PSVersionTable.Platform), are not supported. They can be get or set but this means nothing."
        }
    }
}

function Test-EnvPathExist{
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
        [string]$Level,
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Path,
        [switch]$SkipLevelCheck
    )
    if (-not $SkipLevelCheck){
        Assert-ValidLevel4EnvTools $Level
    }
    if ($Path -eq $null){
        Write-VerboseLog "The $Path in in '$Level' level `$Env:PATH is `$null."
        return $false
    }elseif ($Path -eq '') {
        Write-VerboseLog "The $Path in in '$Level' level `$Env:PATH is empty."
        return $false
    }elseif (-not (Test-Path -LiteralPath $Path)){
        Write-VerboseLog "The $Path in in '$Level' level `$Env:PATH is not exiting."
        return $false
    }else{
        return $true
    }
}
function Test-EnvPathNotDuplicated{
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
        [string]$Level,
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Container,
        [switch]$SkipLevelCheck
    )
    if (-not $SkipLevelCheck){
        Assert-ValidLevel4EnvTools $Level
    }
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
        [string]$Level,
        [switch]$SkipLevelCheck
    )
    if (-not $SkipLevelCheck){
        Assert-ValidLevel4EnvTools $Level
    }
    if (Test-Platform 'Windows'){
        return @([Environment]::GetEnvironmentVariable('Path',$Level) -Split ';')

    }elseif (Test-Platform 'Wsl2'){

        return @([Environment]::GetEnvironmentVariable('PATH',$Level) -Split ':')

    }elseif (Test-Platform 'Linux'){
        return @([Environment]::GetEnvironmentVariable('PATH',$Level) -Split ':')

    }else{
        Write-VerboseLog  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        exit -1
    }
}

function Set-EnvPathBySplit{
<#
See https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3 for ShouldProcess warnings given by PSScriptAnalyzer.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string[]]$Paths,
        [Parameter(Mandatory)]
        [string]$Level,
        [switch]$SkipLevelCheck
    )
    if (-not $SkipLevelCheck){
        Assert-ValidLevel4EnvTools $Level
    }

    if($PSCmdlet.ShouldProcess("$Level level `$Env:PATH","cover `{$Paths}` ")){
        if (Test-Platform 'Windows'){
            [Environment]::SetEnvironmentVariable('Path',$Paths -join ';',$Level)

        }elseif (Test-Platform 'Wsl2'){
            [Environment]::SetEnvironmentVariable('PATH',$Paths -join ':',$Level)

        }elseif (Test-Platform 'Linux'){
            [Environment]::SetEnvironmentVariable('PATH',$Paths -join ':',$Level)

        }else{
            Write-VerboseLog  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
            exit -1
        }
    }
}
function Format-EnvPath{
<#
.DESCRIPTION
    Format all paths of `$Env:PATH in $Level Level:
        1. Remove the invalid (non-existent or empty or duplicated) items.
        2. Format the content of all items by `Format-FileSystemPath` function.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Level,
        [switch]$SkipLevelCheck
    )
    if (-not $SkipLevelCheck){
        Assert-ValidLevel4EnvTools $Level
    }
    $env_paths = Get-EnvPathAsSplit -Level $Level -SkipLevelCheck
    $out_buf = @()
    $counter = 0  # count the number of invalid path (`non-existent` or `empty` or `duplicated`)
    foreach ($item in $env_paths)
    {
        Write-Verbose ($item) -Verbose
        Write-Verbose (Test-EnvPathExist -Level $Level -Path $item -SkipLevelCheck) -Verbose
        Write-Verbose (Test-Path $item) -Verbose
        if (Test-EnvPathExist -Level $Level -Path $item -SkipLevelCheck){
            $item = Format-FileSystemPath -Path $item
            if (Test-EnvPathNotDuplicated -Level $Level -Path $item -Container $out_buf -SkipLevelCheck){
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
    Set-EnvPathBySplit -Paths $out_buf -Level $Level -SkipLevelCheck
    Write-VerboseLog "Formating $Level level `$Env:PATH, $counter invalid(non-existent or empty or duplicated) items have been found and merged."
}
