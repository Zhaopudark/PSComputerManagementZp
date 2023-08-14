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


function Test-Platform{
<#
.DESCRIPTION
    Test if the current platform is compatible with the arg `Name`.
    Currently, it only support Windows, Linux and Wsl2.
    If $Verbose is given, it will show the result.
.EXAMPLE
    Test-Platform -Name 'Windows' -Verbose
    Test-Platform -Name 'Wsl2' -Verbose
    Test-Platform -Name 'Linux' -Verbose
.OUTPUTS
    $true if compatible, otherwise $false.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean],[System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    # if ($IsWindows){
    #     Write-Verbose "Windows"
    #     return 'Windows'
    # } elseif ($IsLinux -and (Test-IsWSL2)){
    #     Write-Verbose "Wsl2"
    #     return 'Wsl2'
    # } elseif ($IsLinux -and(!(Test-IsWSL2))){
    #     Write-Verbose "Linux"
    #     return 'Linux'
    # } else {
    #     Write-Warning  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    #     return $null
    # }
    # see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.3&viewFallbackFrom=powershell-6#islinux
    # for more information about $IsWindows and $IsLinux
    if ($IsWindows){
        if ($Name.ToLower() -eq "windows"){
            Write-Verbose "The current platform, $($PSVersionTable.Platform), is compatible with ${Name}."
            return $true
        } else {
            Write-Verbose  "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
            return $false
        }
    } elseif ($IsLinux -and (Test-IsWSL2)){
        if ($Name.ToLower() -eq "wsl2"){
            Write-Verbose "The current platform, $($PSVersionTable.Platform), is compatible with ${Name}."
            return $true
        } else {
            Write-Verbose  "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
            return $false
        }
    } elseif ($IsLinux -and(!(Test-IsWSL2))){
        if ($Name.ToLower() -eq "linux"){
            Write-Verbose "The current platform, $($PSVersionTable.Platform), is compatible with ${Name}."
            return $true
        } else {
            Write-Verbose  "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
            return $false
        }
    } else {
        Write-Warning  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        return $null
    }
}

function Get-InstallPath{
    [CmdletBinding()]
    [OutputType([System.String],[System.Management.Automation.PSCustomObject])]
    param()
    if (Test-Platform 'Windows'){
        return "$(Split-Path -Path $PROFILE -Parent)\Modules\PSComputerManagementZp"
    }elseif (Test-Platform 'Wsl2'){
        return "${Home}/.local/share/powershell/Modules/PSComputerManagementZp"
    }elseif (Test-Platform 'Linux'){
        return "${Home}/.local/share/powershell/Modules/PSComputerManagementZp"
    }else{
        Write-Warning "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        return $null
    }
}

