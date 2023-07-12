# Navigation

- [Home](README.md)
- [AIPs](APIs.md)
- [Samples](Samples.md) 

# Backgrounds

I'm a researcher on Machine Learning, especially Deep Learning. In addition, I also do some software development. 

For some specific reasons, I cannot directly develop on a traditional Linux server and have to use a workstation-level PC with Windows (Win11) and WSL2 to realize my daily work. 

Using a shell for PC management is necessary for almost all developers. However, from what I was able to retrieve on the internet, it seems to assume a `Linux and Bash` based scenario for us, developers in many PC management tutorials or examples, which is far different from my working situation.

This makes me feel lonely helplessness and have to go through [Technical documentation | Microsoft Learn](https://learn.microsoft.com/en-us/docs/), trying to find a way to achieve my own goals.

As the consequence, I have to learn more about Windows development, especially PowerShell. 

Referring to some examples of `Linux and Bash` based operations, I tried to migrate them to my everyday usage scenarios (`Windows and PowerShell` based). In the beginning, these were only some simple commands. Then, I merged them into scripts. Now, I think it's time to integrate them into a PowerShell module and share, which not only can help me to simplify my configure operations but also may help those who have similar working scenarios as me.  

# Introduction

This customized PowerShell Module, `PSComputerManagementZp`, derives from my scenarios, which can help users to configure their Windows PCs easily to realize many useful operations, such as:

- Set system level proxy
- Set shell (process) level proxy
- Set/unset environment variables.
- Format path for both Windows and WSL2
- Set DDNS
- Deal with authorization problems on NTFS/ReFS
- ...

# How to install?

Make sure your PowerShell version is 5.0 or latter.

```powershell
git clone git@github.com:Zhaopudark/PSComputerManagementZp.git
cd PSComputerManagementZp
./install.ps1
```

# APIs

For all reachable functions, see [AIPs](APIs.md). The following are some useful examples:

- `Get-GatewayIPV4`
- `Get-LocalHostIPV4`
- `Set-SystemProxyIPV4ForCurrentUser`
- `Register-PS1ToScheduledTask`
- `Remove-SystemProxyIPV4ForCurrentUser`
- `Set-EnvProxyIPV4ForShellProcess`
- `Remove-EnvProxyIPV4ForShellProcess`
- `Merge-RedundantEnvPathFromLocalMachineToCurrentUser`
- `Add-EnvPathToCurrentProcess`
- `Remove-EnvPathByPattern`
- `Remove-EnvPathByTargetPath`


# Risks

- May not be compatible with other software or CLI tools or CLI commands or PowerShell Modules. Such as, if you have enabled `system proxy` in `clash`, there is no need to use the case [Set IPV4 system proxy by `Localhost` with `PortNumber`](#Set-system-proxy-IPV4-by-Localhost-with-PortNumber).
- This module will modify registry items in some cases. So, to reduce the potential conflicts with other software, tools, or commands, you have better backup all registry items before using the module. 
- [ ] #TODO: make automatic registry backup for risk operations. 

# Usage

After installation of this module, you can realize many PC management operations easily. See [Samples](Samples.md) for more details.

Generally, the prerequisites are:

- Make sure your PowerShell version is 5.0 or latter.
- Some cases need `Administrator` privilege.

The following is an example with this module:

## Set system proxy IPV4 by `Localhost` with `PortNumber`

**Fundamental**: Modify `Current User` level registry items  `HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings` to set and unset system level proxy.

Please run PowerShell with `Administrator` privilege. 

Supposing the port number is `7890`, the following commands will automatically detect the IPV4 of localhost and then set system proxy by as 'localhost:7890':

```powershell
$module = Get-Module -ListAvailable | Where-Object {$_.Name -eq 'PSComputerManagementZp'}
$script_path = "$($module.Path | Split-Path -Parent)\samples\SetSystemProxy.ps1"
& $script_path -ServerType 'localhost' -PortNumber 7890
```

Then, open `Windows Settings->Network & Internet->Proxy` for checking:

<img src="./README.assets/image-20230703160155455.png" alt="image-20230703160155455" style="zoom:67%;" />
