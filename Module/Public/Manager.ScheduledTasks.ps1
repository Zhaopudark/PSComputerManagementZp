function Register-ProgramIntoTaskScheduler{
<#
.DESCRIPTION
    Register a program into windows task scheduler as `$TaskName` within root\`$TaskPath`.
    Support 3 simple triggers: `RepetitionInterval`, `AtLogon`, and`AtStartup`.
.PARAMETER TaskName
    The name of the task.
.PARAMETER TaskPath
    The target path of the task.
.PARAMETER ProgramPath
    The path of the program.
.PARAMETER ProgramArguments
    The arguments of the program.
.PARAMETER WorkingDirectory
    The working directory of the program.
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
        [string]$ProgramPath,
        [string]$ProgramArguments,
        [string]$WorkingDirectory,
        [timespan]$RepetitionInterval,
        [switch]$AtLogon,
        [switch]$AtStartup
        )
    Assert-IsWindowsAndAdmin
    $action = New-ScheduledTaskAction -Execute $ProgramPath -Argument $ProgramArguments -WorkingDirectory $WorkingDirectory
    $triggers = @()
    if ($RepetitionInterval){
        $triggers += New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(5) -RepetitionInterval $RepetitionInterval
    }
    if ($AtLogon){
        $triggers += New-ScheduledTaskTrigger -AtLogon
    }
    if ($AtStartup){
        $triggers += New-ScheduledTaskTrigger -AtStartup
    }
    if($triggers.Count -eq 0){
        throw "At least one of the parameters `RepetitionInterval`, `AtLogon` and `AtStartup` should be specified to make a trigger."
    } 
    $user_id = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $principal =  New-ScheduledTaskPrincipal -UserId $user_id -LogonType S4U -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
    
    if($PSCmdlet.ShouldProcess("Register task `($TaskName)` into $TaskPath of ScheduledTasks",'','')){
        Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Action $action -Principal $principal -Settings $settings -Trigger $triggers -Force 
    }    
}

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
    ScriptBlock.
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
        [Parameter(Mandatory)]
        [timespan]$RepetitionInterval,
        [switch]$AtLogon,
        [switch]$AtStartup
        )
    Register-ProgramIntoTaskScheduler `
        -TaskName $TaskName `
        -TaskPath $TaskPath `
        -ProgramPath "${Env:ProgramFiles}\PowerShell\7\pwsh.exe" `
        -ProgramArguments "-NoProfile -WindowStyle Hidden -Command $Commands" `
        -WorkingDirectory ${Home} `
        -RepetitionInterval $RepetitionInterval -AtLogon:$AtLogon -AtStartup:$AtStartup
}