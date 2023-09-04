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


function Write-FileLogs{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Void])]
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )
    $log_file = Get-LogFileName
    $parent_dir = Split-Path -Path $log_file -Parent
    if ($PSCmdlet.ShouldProcess("Write logs to file:$log_file",'','')){
        if (!(Test-Path -LiteralPath $parent_dir)){
            New-Item -Path $parent_dir -ItemType Directory -Force | Out-Null # to avoiding some errors about bool function's return value
        } 
        Add-Content -LiteralPath $log_file -Value $message
    }
}

function Write-Logs{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Void])]
    param(
        [string]$Message,
        [switch]$ShowVerbose
    )
    $time_stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $message = "[${time_stamp}] ${Message}"
    Write-FileLogs $message
    if($ShowVerbose){
        Write-Verbose $message -Verbose
    }    
}

