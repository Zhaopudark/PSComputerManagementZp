param (
    [Parameter(Mandatory=$true)]
    [string]$InstallPath,
    [Parameter(Mandatory=$true)]
    [string]$ModuleVersion,
    [Parameter(Mandatory=$true)]
    [string]$LogDir
)
function Get-LogFileName{
    param(
        [string]$KeyInfo
    )
    if ($KeyInfo -ne ''){
        return "$script:InstallPath\$script:ModuleVersion\$script:LogDir\v$script:ModuleVersion($KeyInfo)-Log.txt"
    }
    else{
        return "$script:InstallPath\$script:ModuleVersion\$script:LogDir\v$script:ModuleVersion-Log.txt"
    }
}

function Write-VerboseLog{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Message
    )
    $time_stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $message = "[${time_stamp}] ${Message}"
    Write-Verbose $message
    $log_file = Get-LogFileName
    if ($PSCmdlet.ShouldProcess("$log_file","record logs")){
        Add-Content -Path $log_file -Value $message
        # Out-File -FilePath $log_file -Append
    }
}