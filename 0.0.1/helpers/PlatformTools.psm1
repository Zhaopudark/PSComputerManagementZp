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


function Get-PlatformName{
<#
.DESCRIPTION
    Get the current platform name.
    It only support Windows, Linux or Wsl2.
.OUTPUTS
    String of platform name with initial capitalized.
#>
    [CmdletBinding()]
    [OutputType([System.String],[System.Management.Automation.PSCustomObject])]
    param()
    if ($IsWindows){
        Write-Verbose "Windows"
        return 'Windows'
    } elseif ($IsLinux -and (Test-IsWSL2)){
        Write-Verbose "Wsl2"
        return 'Wsl2'
    } elseif ($IsLinux -and(!(Test-IsWSL2))){
        Write-Verbose "Linux"
        return 'Linux'
    } else {
        Write-Warning  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        return $null
    }
}

function Get-InstallPath{
    [CmdletBinding()]
    [OutputType([System.String],[System.Management.Automation.PSCustomObject])]
    param()
    if (Get-PlatformName -eq 'Windows'){
        return "$(Split-Path -Path $PROFILE -Parent)\Modules\PSComputerManagementZp"
    }elseif (Get-PlatformName -eq 'Wsl2'){
        return "${Home}/.local/share/powershell/Modules/PSComputerManagementZp"
    }elseif (Get-PlatformName -eq 'Linux'){
        return "${Home}/.local/share/powershell/Modules/PSComputerManagementZp"
    }else{
        Write-Warning "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        return $null
    }
}

