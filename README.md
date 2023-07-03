# PSComputerManagementZp

A customized PowerShell Module to help with computer management.

# How to install?

Make sure your PowerShell version is 5.0 or latter.

```powershell
git clone git@github.com:Zhaopudark/PSComputerManagementZp.git
cd PSComputerManagementZp
./install.ps1
```

# Supported functions

- `Get-GatewayIPV4`
- `Get-LocalHostIPV4`
- `Set-SystemProxyIPV4ForCurrentUser`
- `Register-PS1ToScheduledTask`
- `Remove-SystemProxyIPV4ForCurrentUser`
- `Set-EnvProxyIPV4ForShellProcess`
- `Remove-EnvProxyIPV4ForShellProcess`
- `Merge-EnvPathFromLocalMachineToCurrentUser`
- `Add-EnvPathToCurrentProcess`
- `Remove-EnvPathByPattern`
- `Remove-EnvPathByTargetPath`

# Risks

- [x] May not be compatible with other software or CLI tools or CLI commands or PowerShell Modules. Such as, if you have enabled `system proxy` in `clash`, there is no need to use the following case [Set IPV4 system proxy by `Localhost` with `PortNumber`](#Set IPV4 system proxy by `Localhost` with `PortNumber`).
- [x] This module will modify registry items in some cases. So, to reduce the potential conflicts with other software, tools, or commands, you have better backup all registry items before using the module. 
- [ ] #TODO, make automatic registry backup for risk operations. 

# Usage

After installation of this module, one can realize the following cases. Prerequisites:

- Make sure your PowerShell version is 5.0 or latter.
- Some cases need `Administrator` privilege.

## About Windows or WSL2 System Proxy

**Fundamental**: Modify `Current User` level registry items  `HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings` to set and unset system level proxy.

### Set system proxy IPV4 by `Localhost` with `PortNumber`

Please run PowerShell with `Administrator` privilege. 

Supposing the port number is `7890`, the following commands will automatically detect the IPV4 of localhost and then set system proxy by as 'localhost:7890':

```powershell
$module = Get-Module -ListAvailable | Where-Object {$_.Name -eq 'PSComputerManagementZp'}
$script_path = "$($module.Path | Split-Path -Parent)\samples\SetSystemProxy.ps1"
& $script_path -ServerType 'localhost' -PortNumber 7890
```

Then, open `Windows Settings->Network & Internet->Proxy` for checking:

<img src="./README.assets/image-20230703160155455.png" alt="image-20230703160155455" style="zoom:67%;" />

### Set system proxy IPV4 by `Gateway` with `PortNumber`

This case can be useful when you want to set your `Virtual Machine`'s system proxy and your `Host Machine` has already been proxied. The specific situations are as follows:

- `Host Machine` is running and has been proxied.
- `Host Machine` has detect the `Virtual Machine`'s  `Network Adapter`, such as `vEthernet (Default Switch)`
- `Host Machine` has enable `LAN proxy`.
- `Virtual Machine`'s gateway IP address is the above adapter' IP address.

Then, by following settings on the `Virtual Machine`, it can through its gateway to use `Host Machine`'s system proxy.

#### On virtual Windows

Please run PowerShell with `Administrator` privilege.  

Supposing the port number is `7890`, the following commands will automatically detect the IPV4 of gateway and then set system proxy by as 'gateway:7890':

```powershell
$module = Get-Module -ListAvailable | Where-Object {$_.Name -eq 'PSComputerManagementZp'}
$script_path = "$($module.Path | Split-Path -Parent)\samples\SetSystemProxy.ps1"
& $script_path -ServerType 'gateway' -PortNumber 7890
```

Then, open `Windows Settings->Network & Internet->Proxy` for checking:

<img src="./README.assets/image-20230703160317798.png" alt="image-20230703160317798" style="zoom:67%;" />

Optional: To inject this script `SetSystemProxy.ps1` into the the `virtual Windows` as a scheduled task `SetProxy`, setting proxy automatically when `logon` or `startup` , you can take the following further commands (Please run PowerShell with `Administrator` privilege.) :

```powershell
Set-ExecutionPolicy RemoteSigned
$module = Get-Module -ListAvailable | Where-Object {$_.Name -eq 'PSComputerManagementZp'}
$script_path = "$($module.Path | Split-Path -Parent)\samples\SetSystemProxy.ps1"

Stop-ScheduledTask -TaskName "SetProxy"
Import-Module PSComputerManagementZp -Scope Local -Force
Register-PS1ToScheduledTask -TaskName "SetProxy" -ScriptPath $script_path -ScriptArgs "-ServerType Gateway -PortNumber 7890" -AtLogon -AtStartup
Start-ScheduledTask -TaskName "SetProxy"
Remove-Module PSComputerManagementZp
```

Then, open `Computer Management->System Tools->Task Scheduler->Task Scheduler Library->SetProxy` for checking:

<img src="./README.assets/image-20230703170453897.png" alt="image-20230703170453897" style="zoom: 50%;" />

#### On WSL2

#TODO

### Remove the settings for system proxy

Please run PowerShell with `Administrator` privilege. 

Supposing  you have run the above commands to set system proxy, you can do the following to revoke the settings:

```powershell
$module = Get-Module -ListAvailable | Where-Object {$_.Name -eq 'PSComputerManagementZp'}
$script_path = "$($module.Path | Split-Path -Parent)\samples\RemoveSystemProxy.ps1"
& $script_path
```

Then, open `Windows Settings->Network & Internet->Proxy` for checking:

<img src="./README.assets/image-20230703161050758.png" alt="image-20230703161050758" style="zoom:67%;" />

# 
