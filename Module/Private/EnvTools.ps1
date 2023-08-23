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
function Assert-ValidEnvPathLevel{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [string]$Level
    )
    if ($Level -notin @('User','Process','Machine')){
        throw "The arg `$Level should be one of 'User','Process','Machine', not $Level."
    }elseif (($Level -eq 'Machine') -and (Test-Platform 'Windows')){
        return Assert-AdminPermission
    }else{
        if (((Test-Platform 'Wsl2') -or (Test-Platform 'Linux'))`
            -and (($Level -eq 'User') -or ($Level -eq 'Machine'))){
            Write-VerboseLog  "The 'User' or 'Machine' level `$Env:PATH in current platform, $($PSVersionTable.Platform), are not supported. They can be get or set but this means nothing."
        }
        return $true
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
        [ValidateScript({Assert-ValidEnvPathLevel $_})]
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
        [ValidateScript({Assert-ValidEnvPathLevel $_})]
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

function Format-EnvPath{
<#
.DESCRIPTION
    Format all paths of `$Env:PATH in $Level Level:
        1. Remove the invalid (non-existent or empty or duplicated) items.
        2. Format the content of all items by `Format-LiteralPath` function.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Assert-ValidEnvPathLevel $_})]
        [string]$Level
    )
    $env_paths = Get-EnvPathAsSplit -Level $Level
    $out_buf = @()
    $counter = 0  # count the number of invalid path (`non-existent` or `empty` or `duplicated`)
    foreach ($item in $env_paths)
    {
        if (Test-EnvPathExist -Level $Level -Path $item){
            $item = [FormattedPath]::new($item)
            # Format-LiteralPath $item
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
