$local:log_file_path = "${Home}\PowerShellLogs.txt"
function local:Write-EnvToolsHost{
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )
    $time_stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host $"[$time_stamp] --- $Message"
}
function local:Write-EnvToolsLogs{
    param(
        [Parameter(Mandatory)]
        [ValidateSet('User','Process','Machine')]
        [string]$Level,
        [Parameter(Mandatory)]
        [ValidateSet('Remove','Add','Maintain','Not Add','Not Remove')]
        [string]$Type,
        [string]$Path='' # $null will be converted to empty string
    )
    Write-EnvToolsHost "Try to $($Type.ToLower()) '$Path' in '$Level' level `$Env:Path."
    if($Level -in @('User','Machine')){
        Write-EnvToolsHost "See the log file at $log_file_path for more details."
        $message | Out-File -FilePath $log_file_path -Append
    }   
}
function local:Test-EnvPathLevelArg{
    param(
        [string]$Level
    )
    if ($Level -notin @('User','Process','Machine')){
        throw "The arg `$Level should be one of 'User','Process','Machine', not $Level."
    }elseif ($Level -eq 'Machine'){
        Import-Module "${PSScriptRoot}.\PlatformTools.psm1" -Scope local
        if(-not(Test-AdminPermission)){
            throw [System.UnauthorizedAccessException]::new("You must run this function as administrator when arg `$Level is $Level.")
        }
        else{
            return $true
        }
    }else{
        return $true
    }
}
function local:Test-EnvPathExists{
<#
.DESCRIPTION
    Test if the `Path` is `existing` or not `empty` or not `$null`.
    Show corresonding logs.
.OUTPUTS
    $true: if the `Path` is `existing` and not `empty` and not `$null`.
    $false: if the `Path` is not `existing` or is `empty` or `$null`.
#>
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
        Write-EnvToolsHost "The $Path in in '$Level' level `$Env:Path is `$null."
        return $false
    }elseif ($Path -eq '') {
        Write-EnvToolsHost "The $Path in in '$Level' level `$Env:Path is empty."
        return $false
    }elseif (-not (Test-Path -Path $Path)){
        Write-EnvToolsHost "The $Path in in '$Level' level `$Env:Path is not exiting."
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
            Write-EnvToolsHost "The $Path in in '$Level' level `$Env:Path is duplicated."
            return $false
        }else{
            return $true
        }
    }

function local:Format-EnvPath{
<#
.DESCRIPTION
    Format all paths of `$Env:Path in $Level Level:
        1. Remove the invalid (non-existent or empty or duplicated) items.
        2. Format the content of all items by `Format-Path` function.
    
#>
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level
    )
    $env_paths = @([Environment]::GetEnvironmentVariable('Path',$Level) -Split ';')
    $out_buf = @()
    $counter = 0  # count the number of invalid path (`non-existent` or `empty` or `duplicated`)
    foreach ($item in $env_paths)
    {
        if (Test-EnvPathExists -Level $Level -Path $item){
            Import-Module "${PSScriptRoot}.\PathTools.psm1" -Scope local
            $item = Format-Path -Path $item
            if (Test-EnvPathNotDuplicated -Level $Level -Path $item -Container $out_buf ){
                $out_buf += $item
            }
            else{
                Write-EnvToolsLogs -Level $Level -Type 'Remove' -Path $item
                $counter += 1
            }
        }else{
            Write-EnvToolsLogs -Level $Level -Type 'Remove' -Path $item
            $counter += 1
        }
        
    }
    [Environment]::SetEnvironmentVariable('Path',$out_buf -join ';',$Level)
    Write-EnvToolsHost "Formating $Level level `$Env:Path, $counter invalid(non-existent or empty or duplicated) items have been found and merged."
}

function Merge-EnvPathFromLocalMachineToCurrentUser{
    Import-Module "${PSScriptRoot}.\PlatformTools.psm1" -Scope local
    if(-not(Test-AdminPermission)){
        throw [System.UnauthorizedAccessException]::new("You must run this function as administrator.")
    }
    $user_env_paths = @([Environment]::GetEnvironmentVariable('Path','User') -Split ';')
    $machine_env_paths = @([Environment]::GetEnvironmentVariable('Path','Machine') -Split ';')
    $out_buf = @()
    $counter = 0  # count the number of invalid path (`non-existent` or `empty` or `duplicated`)
    foreach ($item in $machine_env_paths)
    {
        # `non-existent` and `empty` situations have been removed in `Format-EnvPath` function.
        if ($item -notin $user_env_paths){
            $out_buf += $item
        }
        else{
            Write-EnvToolsLogs -Type 'Remove' -Path $item -Level 'Machine'
            $counter += 1
        }
    }
    [Environment]::SetEnvironmentVariable('Path',$out_buf -join ';','Machine')
    Write-EnvToolsHost "$counter duplicated items between Machine level and User level `$Env:Path have been found. And, they have been merged into User level `$Env:Path"

}
function Add-EnvPathToCurrentProcess{
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Format-EnvPath -Level 'Process'

    # User Machine Process[Default]
    $env_paths = @([Environment]::GetEnvironmentVariable('Path') -Split ';') 
    if (Test-EnvPathExists -Level 'Process' -Path $Path){
        Import-Module "${PSScriptRoot}.\PathTools.psm1" -Scope local
        $Path = Format-Path -Path $Path
        if (Test-EnvPathNotDuplicated -Level 'Process' -Path $Path -Container $env_paths ){
            Write-EnvToolsLogs -Level 'Process' -Type 'Add' -Path $Path
            $env_paths += $Path
            [Environment]::SetEnvironmentVariable('Path',$env_paths -join ';','Process')
            Write-EnvToolsHost "The path '$Path' has been added into Process level `$Env:Path."
        }
        else{
            Write-EnvToolsLogs -Level 'Process' -Type 'Maintain' -Path $Path
        }
    }else{
        Write-EnvToolsLogs -Level 'Process' -Type 'Not Add' -Path $Path
    }
}


function local:Remove-EnvPathByPattern{
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level
    )
   
    Format-EnvPath -Level $Level
    $env_paths = @([Environment]::GetEnvironmentVariable('Path',$Level) -Split ';')
    $out_buf = @()
    $counter = 0
    foreach ($item in $env_paths)
    {
        if ($item -notmatch $Pattern){
            $out_buf += $item
        }
        else{
            Write-EnvToolsLogs -Level $Level -Type 'Remove' -Path $item
            $counter += 1
        }
    }
    [Environment]::SetEnvironmentVariable('Path',$out_buf -join ';',$Level)
    Write-EnvToolsHost "$counter paths match pattern $Pattern have been totally removed from $Level level `$Env:Path."
}
function local:Remove-EnvPathByTarget{
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath,
        [Parameter(Mandatory)]
        [ValidateScript({Test-EnvPathLevelArg $_})]
        [string]$Level
    )
    Format-EnvPath -Level $Level
    $env_paths = @([Environment]::GetEnvironmentVariable('Path',$Level) -Split ';')
    $out_buf = @()
    $counter = 0
    if (Test-EnvPathExists -Level $Level -Path $TargetPath){
        Import-Module "${PSScriptRoot}.\PathTools.psm1" -Scope local
        $TargetPath = Format-Path -Path $TargetPath
        foreach ($item in $env_paths)
        {
            if ($item -ne $TargetPath){
                $out_buf += $item
            }
            else{
                Write-EnvToolsLogs -Level $Level -Type 'Remove' -Path $item
                $counter += 1
            }
        }
    }else{
        Write-EnvToolsLogs -Level $Level -Type 'Not Remove' -Path $TargetPath
    }   
    [Environment]::SetEnvironmentVariable('Path',$out_buf -join ';',$Level)
    Write-EnvToolsHost "$counter paths eq target $TargetPath have been totally removed from $Level level `$Env:Path."
}