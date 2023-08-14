Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local

$local:log_dir = "$(Get-InstallPath)\Log"

if (!(Test-Path $script:log_dir)){
    New-Item -Path $script:log_dir -ItemType Directory -Force
}

$local:version = Get-Item "${PSScriptRoot}\..\" |Split-Path -Leaf

function Get-LogFileName{
    param(
        [string]$KeyInfo
    )
    if ($KeyInfo -ne ''){
        return "$script:log_dir\PSComputerManagementZp-v$script:version-($KeyInfo)-Log.txt"
    }
    else{
        return "$script:log_dir\PSComputerManagementZp-v$script:version-Log.txt"
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