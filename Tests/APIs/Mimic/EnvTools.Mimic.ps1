function Assert-ValidLevel4EnvTools{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [string]$Level
    )
    if ($Level -notin @('User','Process','Machine')){
        throw "The arg `$Level should be one of 'User','Process','Machine', not $Level."
    }elseif (($Level -eq 'Machine') -and (Test-PlatformX 'Windows')){
        Assert-AdminPermissionX
        return $true
    }else{
        if (((Test-PlatformX 'Wsl2') -or (Test-PlatformX 'Linux'))`
            -and ($Level -in @('User','Machine'))){
            # Write-VerboseLog  "The 'User' or 'Machine' level `$Env:PATH in current platform, $($PSVersionTable.Platform), are not supported. They can be get or set but this means nothing."
        }
        return $true
    }
}



function Get-EnvPathAsSplit{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Assert-ValidLevel4EnvTools $_})]
        [string]$Level
    )
    if (Test-PlatformX 'Windows'){
        return @([Environment]::GetEnvironmentVariable('Path',$Level) -Split ';')

    }elseif (Test-PlatformX 'Wsl2'){

        return @([Environment]::GetEnvironmentVariable('PATH',$Level) -Split ':')

    }elseif (Test-PlatformX 'Linux'){
        return @([Environment]::GetEnvironmentVariable('PATH',$Level) -Split ':')

    }else{
        # Write-VerboseLog  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
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
        [ValidateScript({Assert-ValidLevel4EnvTools $_})]
        [string]$Level
    )
    if($PSCmdlet.ShouldProcess("$Level level `$Env:PATH","cover `{$Paths}` ")){
        if (Test-PlatformX 'Windows'){
            [Environment]::SetEnvironmentVariable('Path',$Paths -join ';',$Level)

        }elseif (Test-PlatformX 'Wsl2'){
            [Environment]::SetEnvironmentVariable('PATH',$Paths -join ':',$Level)

        }elseif (Test-PlatformX 'Linux'){
            [Environment]::SetEnvironmentVariable('PATH',$Paths -join ':',$Level)

        }else{
            # Write-VerboseLog  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
            exit -1
        }
    }
}