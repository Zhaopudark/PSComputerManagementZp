param (
    [Parameter(Mandatory)]
    [string]$InstallPath,
    [Parameter(Mandatory)]
    [string]$ModuleVersion,
    [Parameter(Mandatory)]
    [string]$LogDir
)

$script:InstallPath = $InstallPath
$script:ModuleVersion = $ModuleVersion
$script:LogDir = $LogDir
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
        $parent_dir = Split-Path -Path $log_file -Parent
        if (!(Test-Path -LiteralPath $parent_dir)){
            New-Item -Path $parent_dir -ItemType Directory -Force
        } 
        Add-Content -LiteralPath $log_file -Value $message
        # Out-File -FilePath $log_file -Append
    }
}