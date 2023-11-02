function Register-PwshCommandsAsRepetedSchedulerTask{
<#
.DESCRIPTION
    Register pwsh commands as a task into windows task scheduler as `$TaskName` within root\`$TaskPath`.
    The task will be triggered at once and then repeat with the interval.
    Additional triggers can be specified by `$AtLogon` and `$AtStartup`.
.PARAMETER TaskName
    The name of the task.
.PARAMETER TaskPath
    The target path of the task.
.PARAMETER Commands
    The pwsh commands to be executed.
.PARAMETER RepetitionInterval
    The interval of repetition.
.PARAMETER AtLogon
    A switch parameter to indicate whether to add a trigger at logon.
.PARAMETER AtStartup
    A switch parameter to indicate whether to add a trigger at startup.
.INPUTS
    String.
    String.
    String.
    TimeSpan.
    Switch.
    Switch.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
    Need Administrator privilege.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName,
        [Parameter(Mandatory)]
        [string]$TaskPath,
        [Parameter(Mandatory)]
        [scriptblock]$Commands,
        [timespan]$RepetitionInterval,
        [switch]$AtLogon,
        [switch]$AtStartup
        )
    Assert-IsWindowsAndAdmin
    $action = New-ScheduledTaskAction -Execute "${Env:ProgramFiles}\PowerShell\7\pwsh.exe" -Argument "-NoProfile -WindowStyle Hidden -Command $Commands"
    $triggers = @(New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(5) -RepetitionInterval $RepetitionInterval)
    If ($AtLogon){
        $triggers += New-ScheduledTaskTrigger -AtLogon
    }
    If ($AtStartup){
        $triggers += New-ScheduledTaskTrigger -AtStartup
    }    
    $user_id = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $principal =  New-ScheduledTaskPrincipal -UserId $user_id -LogonType S4U -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
    
    if($PSCmdlet.ShouldProcess("Register pwsh commands as task `($TaskName)` into $TaskPath of ScheduledTasks",'','')){
        Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Action $action -Principal $principal -Settings $settings -Trigger $triggers -Force 
    }    
}