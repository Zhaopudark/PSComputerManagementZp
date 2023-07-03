function Test-AdminPermission {
    $current_user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current_user)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $false
    }else{
        return $true
    }    
}


function local:Test-IfIsOnCertainPlatform{
    param(
        [ValidateSet("Windows","Wsl2")]
        [string]$SystemName
    ) 
    if (($PSVersionTable.Platform -eq "Win32NT") -and ($SystemName.ToLower() -eq "windows")){

        return $true
    
    } elseif (($PSVersionTable.Platform -eq "Unix")-and ($SystemName.ToLower() -eq "wsl2")){
        return $true
        
    } else {
        Write-Host "The platform, $($PSVersionTable.Platform), is not compatible with the systemName, ${SystemName}."
        return $false
    }
    
}