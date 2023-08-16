param (
    [Parameter(Mandatory=$true)]
    [string]$ModuleName
)

function Get-InstallPath{
    [CmdletBinding()]
    [OutputType([System.String],[System.Management.Automation.PSCustomObject])]
    param()
    if (Test-Platform 'Windows'){
        return "$(Split-Path -Path $PROFILE -Parent)\Modules\$ModuleName"
    }elseif (Test-Platform 'Wsl2'){
        return "${Home}\.local\share\powershell\Modules\$ModuleName"
    }elseif (Test-Platform 'Linux'){
        return "${Home}\.local\share\powershell\Modules\$ModuleName"
    }else{
        Write-Warning "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        return $null
    }
}
