param (
    [Parameter(Mandatory)]
    [string]$LoggingPath,
    [Parameter(Mandatory)]
    [string]$ModuleVersion
)

$script:LoggingPath = $LoggingPath
$script:ModuleVersion = $ModuleVersion

function Get-LogFileName{
    param(
        [string]$KeyInfo
    )
    if ($KeyInfo -ne ''){
        return "$script:LoggingPath\$script:ModuleVersion\v$script:ModuleVersion($KeyInfo)-Log.txt"
    }
    else{
        return "$script:LoggingPath\$script:ModuleVersion\v$script:ModuleVersion-Log.txt"
    }
}

function Write-VerboseLog{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Void])]
    param(
        [string]$Message
    )
    $time_stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $message = "[${time_stamp}] ${Message}"
    Write-Verbose $message
    $log_file = Get-LogFileName
    if ($PSCmdlet.ShouldProcess("$log_file","record logs")){
        $parent_dir = Split-Path -Path $log_file -Parent
        if (!(Test-Path -LiteralPath $parent_dir)){
            New-Item -Path $parent_dir -ItemType Directory -Force | Out-Null # to avoiding some errors about bool function's return value
        } 
        Add-Content -LiteralPath $log_file -Value $message
        # Out-File -FilePath $log_file -Append
    }
}

