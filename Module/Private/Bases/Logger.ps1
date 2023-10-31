param (
    [Parameter(Mandatory)]
    [string]$LoggingPath,
    [Parameter(Mandatory)]
    [string]$ModuleVersion
)

$script:LoggingPath = $LoggingPath
$script:ModuleVersion = $ModuleVersion

function Get-LogFileNameWithKeyInfo{
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
        [Parameter(Mandatory)]
        [string]$KeyInfo
    )
    return "$script:LoggingPath\$script:ModuleVersion\v$script:ModuleVersion($KeyInfo)-Log.txt"
}


$script:basic_log_file = "$script:LoggingPath\$script:ModuleVersion\v$script:ModuleVersion-Log.txt"
# $basic_log_file_name = [System.IO.Path]::GetFileName($script:basic_log_file)
$basic_log_file_parent_dir = [System.IO.Path]::GetDirectoryName($script:basic_log_file)
$basic_log_file_name_without_suffix = [System.IO.Path]::GetFileNameWithoutExtension($script:basic_log_file)
$basic_log_file_suffix = [System.IO.Path]::GetExtension($script:basic_log_file)
$script:basic_log_files_list = @($script:basic_log_file)
for ($i = 1; $i -lt 10; $i++){
    $script:basic_log_files_list += ("${basic_log_file_parent_dir}/${basic_log_file_name_without_suffix}.${i}${basic_log_file_suffix}")
}

function Get-CurrentLogFileNameInRotatingList{
<#
.DESCRIPTION
    Get the current log file name in a fixed and internal rotating list.
    The current (target) log file is the one that is the most recently modified and whose size is less than 10MB.
.INPUTS
    None.
.OUTPUTS
    String.
#>
    [OutputType([string])]
    param()
    $tmp_index = 0
    for ($i = 1; $i -lt 10; $i++){
        if (Test-Path -LiteralPath $script:basic_log_files_list[$i]){
            if ((Get-Item -LiteralPath $script:basic_log_files_list[$i]).LastWriteTime -gt (Get-Item -LiteralPath $script:basic_log_files_list[$tmp_index]).LastWriteTime){
                $tmp_index = $i
            }
        }
    }
    if ((Test-Path -LiteralPath $script:basic_log_files_list[$tmp_index]) -and
        ((Get-Item -LiteralPath $script:basic_log_files_list[$tmp_index]).Length /1MB -gt 10)){
        if ((Test-Path -LiteralPath $script:basic_log_files_list[($tmp_index + 1)%10]) -and
            ((Get-Item -LiteralPath $script:basic_log_files_list[($tmp_index + 1)%10]).Length /1MB -gt 10)){
            Remove-Item $script:basic_log_files_list[($tmp_index + 1)%10]                                                          
        }
        return $script:basic_log_files_list[($tmp_index + 1)%10]
    }else{
        return $script:basic_log_files_list[$tmp_index]
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
    $log_file = Get-CurrentLogFileNameInRotatingList
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