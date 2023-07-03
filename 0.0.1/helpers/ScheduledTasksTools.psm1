function Register-PS1ToScheduledTask{
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
                -Execute "${Env:WinDir}\System32\WindowsPowerShell\v1.0\powershell.exe" `
                -Argument "-WindowStyle Hidden -File `"${ScriptPath}`" ${ScriptArgs}"
    Register-ScheduledTask -TaskName $TaskName -Trigger $triggers -Action $actions -RunLevel Highest -Force
}