function Test-AdminPermission {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param()
    $current_user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current_user)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Verbose "Current process is not in AdminPermission."
        return $false
    }else{
        Write-Verbose "Current process is in in AdminPermission."
        return $true
    }
}
function local:Test-IsWSL2{
    $output = bash -c "cat /proc/version 2>&1"
    return $output.Contains("WSL2")
}

function Test-IfIsOnCertainPlatform{
<#
.DESCRIPTION
    Test if the current platform is compatible with the systemName.
    It only support Windows and Wsl2.
    If $Verbose is given, it will show the result.
.EXAMPLE
    Test-IfIsOnCertainPlatform -SystemName 'Windows' -Verbose
    Test-IfIsOnCertainPlatform -SystemName 'Wsl2' -Verbose
    Test-IfIsOnCertainPlatform -SystemName 'Linux' -Verbose
.OUTPUTS
    $true if compatible, otherwise $false.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [ValidateSet("Windows","Wsl2","Linux")]
        [string]$SystemName
    )
    if (($PSVersionTable.Platform -eq "Win32NT") -and ($SystemName.ToLower() -eq "windows")){
        Write-Verbose "The current platform, $($PSVersionTable.Platform), is compatible with the systemName, ${SystemName}."
        return $true
    } elseif (($PSVersionTable.Platform -eq "Unix") -and(Test-IsWSL2) -and ($SystemName.ToLower() -eq "wsl2")){
        Write-Verbose "The current platform, $($PSVersionTable.Platform), is compatible with the systemName, ${SystemName}."
        return $true
    } elseif (($PSVersionTable.Platform -eq "Unix")-and ($SystemName.ToLower() -eq "linux")){
        Write-Verbose  "The current platform, $($PSVersionTable.Platform), is compatible with the systemName, ${SystemName}."
        return $true
    } else {
        Write-Error  "The platform, $($PSVersionTable.Platform), is not compatible with the systemName, ${SystemName}."
        return $false
    }
}

function Get-InstallPath{
    [CmdletBinding()]
    [OutputType([System.String],[System.Management.Automation.PSCustomObject])]
    param()
    if (Test-IfIsOnCertainPlatform -SystemName 'Windows'){
        return "$(Split-Path -Path $PROFILE -Parent)\Modules\PSComputerManagementZp"
    }elseif (Test-IfIsOnCertainPlatform -SystemName 'Wsl2'){
        return "${Home}/.local/share/powershell/Modules/PSComputerManagementZp"
    }elseif (Test-IfIsOnCertainPlatform -SystemName 'Linux'){
        return "${Home}/.local/share/powershell/Modules/PSComputerManagementZp"
    }else{
        Write-Error "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        return $null
    }
}

