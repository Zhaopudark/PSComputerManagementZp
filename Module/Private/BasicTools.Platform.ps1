# Cross Platform Tools
function Test-Platform{
<#
.DESCRIPTION
    Test if the current platform is compatible with the arg `Name`.
    Currently, it only support Windows, Linux and Wsl2.
    If $Verbose is given, it will show the result.
.EXAMPLE
    ```powershell
    Test-Platform -Name 'Windows' -Verbose
    Test-Platform -Name 'Wsl2' -Verbose
    Test-Platform -Name 'Linux' -Verbose
    ```
.OUTPUTS
    $true if compatible, otherwise $false.
#>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
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
            Write-Verbose "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
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
            Write-Verbose "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
            return $false
        }
    } else {
        throw "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    }
}
# Linux Only
function Test-IsWSL2{
    [CmdletBinding()]
    [OutputType([bool])]
    param ()
    $output = bash -c "cat /proc/version 2>&1"
    return $output.Contains("WSL2")
}
function Assert-IsLinuxOrWSL2{
    [CmdletBinding()]
    [OutputType([void])]
    param ()
    if (!(Test-Platform -Name 'Linux') -or !((Test-Platform -Name 'Wsl2'))){
        throw "The current platform shoule be Linux or Wsl2 but it is $($PSVersionTable.Platform)."
    } 
}
# Windows Only
function Test-AdminPermission {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    $current_user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current_user)

    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $true
    }else{
        return $false
    }
}
function Assert-IsWindows{
    [CmdletBinding()]
    [OutputType([void])]
    param()
    if (!(Test-Platform -Name 'Windows')){
        throw "The current platform shoule be Windows but it is $($PSVersionTable.Platform)."
    }
}
function Assert-AdminPermission {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    if (!(Test-AdminPermission)){
        Write-Verbose "Current process is not in AdminPermission."
        throw [System.UnauthorizedAccessException]::new("You must be in administrator privilege.")
    }
}
function Assert-IsWindowsAndAdmin{
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    Assert-IsWindows
    Assert-AdminPermission
}
function Assert-AdminRobocopyAvailable{
    [CmdletBinding()]
    [OutputType([void])]
    param()
    try {
        Robocopy > $null
    }
    catch {
        Write-Verbose "Exception: $PSItem"
        throw "The robocopy command is not available, please install it first."
    }
    Assert-IsWindowsAndAdmin
}