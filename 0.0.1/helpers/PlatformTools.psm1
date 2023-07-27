function Test-AdminPermission {
    $current_user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current_user)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $false
    }else{
        return $true
    }    
}
function Test-IfIsOnCertainPlatform{
<#
.DESCRIPTION
    Test if the current platform is compatible with the systemName.
    It only support Windows and Wsl2.
    If $ShowInfo is given, it will show the result.
.EXAMPLE
    Test-IfIsOnCertainPlatform -SystemName 'Windows' -ShowInfo
    Test-IfIsOnCertainPlatform -SystemName 'Wsl2' -ShowInfo
    Test-IfIsOnCertainPlatform -SystemName 'Linux' -ShowInfo
.OUTPUTS
    $true if compatible, otherwise $false.
#>
    param(
        [ValidateSet("Windows","Wsl2","Linux")]
        [string]$SystemName,
        [switch]$ShowInfo
    ) 
    if (($PSVersionTable.Platform -eq "Win32NT") -and ($SystemName.ToLower() -eq "windows")){
        if ($ShowInfo){
            Write-Host "The current platform, $($PSVersionTable.Platform), is compatible with the systemName, ${SystemName}."
        }
        return $true
    
    } elseif (($PSVersionTable.Platform -eq "Unix")-and ($SystemName.ToLower() -eq "wsl2")){
        if ($ShowInfo){
            Write-Host "The current platform, $($PSVersionTable.Platform), is compatible with the systemName, ${SystemName}."
        }
        return $true

    } elseif (($PSVersionTable.Platform -eq "Unix")-and ($SystemName.ToLower() -eq "Linux")){
        if ($ShowInfo){
            Write-Host "The current platform, $($PSVersionTable.Platform), is compatible with the systemName, ${SystemName}."
        }
        return $true    

    } else {
        if ($ShowInfo){
            Write-Host "The platform, $($PSVersionTable.Platform), is not compatible with the systemName, ${SystemName}."
        }
        return $false
    }
    
}