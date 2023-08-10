$local:log_file_path = "${Home}\PowerShellLogs.txt"

function Write-VerboseLog{
    [CmdletBinding()]
    param(
        [string]$Message
    )
    $time_stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $message = "[${time_stamp}] ${Message}"
    Write-Verbose $message
    Add-Content -Path $log_file_path -Value $message
    # Out-File -FilePath $log_file_path -Append
}