function Test-PlatformX{
<#
.DESCRIPTION
    Test if the current platform is compatible with the arg `Name`.
    Currently, it only support Windows, Linux and Wsl2.
    If $Verbose is given, it will show the result.
.EXAMPLE
    Test-PlatformX -Name 'Windows' -Verbose
    Test-PlatformX -Name 'Wsl2' -Verbose
    Test-PlatformX -Name 'Linux' -Verbose
.OUTPUTS
    $true if compatible, otherwise $false.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [switch]$Throw
        
    )
    # if ($IsWindows){
    #     Write-Verbose "Windows"
    #     return 'Windows'
    # } elseif ($IsLinux -and (Test-IsWSL2X)){
    #     Write-Verbose "Wsl2"
    #     return 'Wsl2'
    # } elseif ($IsLinux -and(!(Test-IsWSL2X))){
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
            $info = "The current platform, $($PSVersionTable.Platform), is compatible with ${Name}."
            $output = $true
        } else {
            $info = "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
            $output = $false
        }
    } elseif ($IsLinux -and (Test-IsWSL2X)){
        if ($Name.ToLower() -eq "wsl2"){
            $info = "The current platform, $($PSVersionTable.Platform), is compatible with ${Name}."
            $output = $true
        } else {
            $info =  "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
            $output = $false
        }
    } elseif ($IsLinux -and(!(Test-IsWSL2X))){
        if ($Name.ToLower() -eq "linux"){
            $info = "The current platform, $($PSVersionTable.Platform), is compatible with ${Name}."
            $output = $true
        } else {
            $info = "The platform, $($PSVersionTable.Platform), is not compatible with ${Name}."
            $output = $false
        }
    } else {
        $info = "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        $output = $null
    }

    if ($output -eq $true){
        Write-Verbose $info
    }elseif ($null -eq $output) {
        Write-Warning $info
    }else {
        <# Action when all if and elseif conditions are false #>
        if($Throw){
            throw $info
        }else{
            Write-Verbose $info
        }
    }
    if(!$Throw){
        return $output
    }
}


function Test-IsWSL2X{
    $output = bash -c "cat /proc/version 2>&1"
    return $output.Contains("WSL2")
}
function Assert-AdminPermissionX {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param()
    $current_user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current_user)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Verbose "Current process is not in AdminPermission."
        throw [System.UnauthorizedAccessException]::new("You must run in administrator privilege.")
    }else{
        Write-Verbose "Current process is in in AdminPermission."
        # return $true
    }
}
function Assert-AdminRobocopyAvailableX{
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    try {
        Robocopy > $null
    }
    catch {
        Write-Verbose "Exception: $PSItem"
        throw "The robocopy command is not available, please install it first."
    }
    Test-PlatformX -Name 'Windows' -Throw
    Assert-AdminPermissionX
}

function Assert-IsWindowsAndAdminX{
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    Test-PlatformX -Name 'Windows' -Throw
    Assert-AdminPermissionX
}
    