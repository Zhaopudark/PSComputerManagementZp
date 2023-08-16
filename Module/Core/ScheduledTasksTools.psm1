Import-Module "${PSScriptRoot}\..\RegisterUtils.psm1" -Force -Scope Local
function Register-PS1ToScheduledTask{
<#
.SYNOPSIS
    Register a PS1 file to a scheduled task.

.DESCRIPTION
    It is a wrapper of Register-ScheduledTask, registering an action of
    running a PS1 file to a scheduled task at the trigger of Logon or Startup.
    It is forced to run with highest privilege and hidden window style.

.PARAMETER TaskName
    The name of the task.

.PARAMETER ScriptPath
    The path of the (ps1) script.

.PARAMETER ScriptArgs
    The arguments of the (ps1) script.

.PARAMETER AtLogon
    Switch Parameters.
    If the task should be triggered at logon.

.PARAMETER AtStartup
    Switch Parameters.
    If the task should be triggered at startup.
.NOTES
    This function does not do fully argument validation.
    One should make sure the arguments are valid, such as:
        1. The script path is valid.
        2. The script arguments are valid.
        3. The task name is valid.
        4. The task name is unique, unless the task should be overwritten.
        5. At least one flag (switch) of AtLogon and AtStartup is given.
#>
    param(
        [Parameter(Mandatory)][string]$TaskName,
        [Parameter(Mandatory)][string]$ScriptPath,
        [string]$ScriptArgs,
        [switch]$AtLogon,
        [switch]$AtStartup
    )

    $triggers = @()
    if($AtLogon){
        $triggers += New-ScheduledTaskTrigger -AtLogon
    }
    if($AtStartup){
        $triggers += New-ScheduledTaskTrigger -AtStartup
    }
    $actions = @()
    $actions += New-ScheduledTaskAction `
                -Execute "${Env:ProgramFiles}\PowerShell\7\pwsh.exe" `
                -Argument "-WindowStyle Hidden -File `"${ScriptPath}`" ${ScriptArgs}"
    Register-ScheduledTask -TaskName $TaskName -Trigger $triggers -Action $actions -RunLevel Highest -Force
}