# Cross Platform Tools
function Test-Platform{
<#
.DESCRIPTION
    Test if the current platform is compatible with the arg `$Name`.
    Currently, it only support Windows, MacOS, Linux and Wsl2.
    If `$Verbose` is given, it will show the result.
.PARAMETER Name
    The platform name to be tested.
.PARAMETER Verbose
    Whether to show the result.
.EXAMPLE
    Test-Platform -Name 'Windows' -Verbose
    Test-Platform -Name 'Wsl2' -Verbose
    Test-Platform -Name 'Linux' -Verbose
    Test-Platform -Name 'MacOS' -Verbose
.INPUTS
    String.
.OUTPUTS
    Boolean.
.LINK
    [Automatic Variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.3&viewFallbackFrom=powershell-6#islinux) for `$IsWindows` and `$IsLinux`.
#>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
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
    } elseif ($IsMacOS){
        if ($Name.ToLower() -eq "macos"){
            Write-Verbose "The current platform, $($PSVersionTable.Platform), is compatible with ${Name}."
            return $true
        } else {
            Write-Verbose "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
            return $false
        }
    }
    else {
        throw "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    }
}
# Linux Only
function Test-IsWSL2{
<#
.DESCRIPTION
    Test if the current platform is Wsl2.
.INPUTS
    None.
.OUTPUTS
    Boolean.
#>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()
    $output = bash -c "cat /proc/version 2>&1"
    return $output.Contains("WSL2")
}
function Assert-IsLinuxOrWSL2{
<#
.DESCRIPTION
    Assert if the current platform is Linux or Wsl2.
.INPUTS
    None.
.OUTPUTS
    None.
#>
    [CmdletBinding()]
    [OutputType([void])]
    param ()
    if (!(Test-Platform -Name 'Linux') -and !(Test-Platform -Name 'Wsl2')){
        throw "The current platform shoule be Linux or Wsl2 but it is $($PSVersionTable.Platform)."
    }
}
# Windows Only
function Test-AdminPermission{
<#
.DESCRIPTION
    Test if the current process is in AdminPermission.
.INPUTS
    None.
.OUTPUTS
    Boolean.
#>
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
<#
.DESCRIPTION
    Assert if the current platform is Windows.
.INPUTS
    None.
.OUTPUTS
    None.
#>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    if (!(Test-Platform -Name 'Windows')){
        throw "The current platform shoule be Windows but it is $($PSVersionTable.Platform)."
    }
}
function Assert-AdminPermission{
<#
.DESCRIPTION
    Assert if the current process is in AdminPermission.
.INPUTS
    None.
.OUTPUTS
    None.
#>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    if (!(Test-AdminPermission)){
        Write-Verbose "Current process is not in AdminPermission."
        throw [System.UnauthorizedAccessException]::new("You must be in administrator privilege.")
    }
}
function Assert-IsWindowsAndAdmin{
<#
.DESCRIPTION
    Assert if the current platform is Windows and the current process is in AdminPermission.
.INPUTS
    None.
.OUTPUTS
    None.
#>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    Assert-IsWindows
    Assert-AdminPermission
}

function Assert-IsWindowsAndAdminIfOnWindows{
<#
.DESCRIPTION
    Assert if the current platform is Windows and the current process is in AdminPermission.
.INPUTS
    None.
.OUTPUTS
    None.
#>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    if (Test-Platform -Name 'Windows'){
        Assert-IsWindows
        Assert-AdminPermission
    }
}
function Assert-AdminRobocopyAvailable{
<#
.DESCRIPTION
    Assert the robocopy command is available.
    Assert if the current platform is Windows.
    Assert if the current process is in AdminPermission
.INPUTS
    None.
.OUTPUTS
    None.
#>
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

function Assert-AliyunCLIAvailable{
<#
.DESCRIPTION
    Assert the robocopy command is available.
    Assert if the current platform is Windows.
    Assert if the current process is in AdminPermission
.INPUTS
    None.
.OUTPUTS
    None.
#>
    [CmdletBinding()]
    [OutputType([void])]
    param()
    try {
        aliyun > $null
    }
    catch {
        Write-Verbose "Exception: $PSItem"
        throw "The aliyun-cli is not available, please install it first."
    }
    Assert-IsWindowsAndAdmin
}