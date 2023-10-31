param (
    [Parameter(Mandatory)]
    [string]$LoggingPath,
    [Parameter(Mandatory)]
    [string]$ModuleVersion
)

$script:LoggingPath = $LoggingPath
$script:ModuleVersion = $ModuleVersion

function Get-LogFileName{
<#
.DESCRIPTION
    Get the log file name according the key info, pre-defined `$LoggingPath` and pre-defined `$ModuleVersion`.
.PARAMETER KeyInfo
    A string to indicate the key info of the log file name.
.INPUTS
    String.
.OUTPUTS
    String.
#>
    [OutputType([string])]
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


function Write-FileLog{
<#
.DESCRIPTION
    Write log to a file.
.PARAMETER Message
    The message to be logged.
.INPUTS
    String.
.OUTPUTS
    None.
.NOTES
    If the log file does not exist, it will be created automatically. But the creation results will be muted to avoid some errors about bool function's return value.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )
    $log_file = Get-LogFileName
    $parent_dir = Split-Path -Path $log_file -Parent
    if ($PSCmdlet.ShouldProcess("Write logs to file:$log_file",'','')){
        if (!(Test-Path -LiteralPath $parent_dir)){
            New-Item -Path $parent_dir -ItemType Directory -Force | Out-Null
        }
        Add-Content -LiteralPath $log_file -Value $message
    }
}

function Write-Log{
<#
.DESCRIPTION
    Can write log to a file and output to the console simultaneously.
    Logging to a file is the default behavior.
    Logging to the console is an optional behavior, which can be controlled by the switch parameter `$ShowVerbose`.
.PARAMETER Message
    The message to be logged.
.PARAMETER ShowVerbose
    Whether to show the message to the console in verbose mode.
.INPUTS
    String.
.OUTPUTS
    None.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [switch]$ShowVerbose
    )
    $time_stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $message = "[${time_stamp}] ${Message}"
    Write-FileLog $message
    if($ShowVerbose){
        Write-Verbose $message -Verbose
    }
}