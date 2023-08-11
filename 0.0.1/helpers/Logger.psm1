Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local

$local:log_dir = "$(Get-InstallPath)\Log"

if (!(Test-Path $local:log_dir)){
    New-Item -Path $local:log_dir -ItemType Directory -Force
}

$local:version = Get-Item "${PSScriptRoot}\..\" |Split-Path -Leaf
$local:log_file = "$local:log_dir\PSComputerManagementZp-v$local:version-Log.txt"

function Write-VerboseLog{
    [CmdletBinding()]
    param(
        [string]$Message
    )

    $time_stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $message = "[${time_stamp}] ${Message}"
    Write-Verbose $message
    Add-Content -Path $log_file -Value $message
    # Out-File -FilePath $log_file_path -Append
}