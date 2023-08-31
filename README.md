


# Navigation
[![PowerShell-7.X](https://img.shields.io/badge/PowerShell-7.X-blue?logo=powershell)](https://learn.microsoft.com/en-us/powershell/)

[![PSComputerManagementZp-Home](https://img.shields.io/badge/PSComputerManagementZp-Home-yellow)](README.md)[![PSComputerManagementZp-AIPs](https://img.shields.io/badge/PSComputerManagementZp-AIPs-orange)](Tests/APIs/APIs.md)[![PSComputerManagementZp-Examples](https://img.shields.io/badge/PSComputerManagementZp-Examples-red)](Examples/Examples.md)

![GitHub tag (with filter)](https://img.shields.io/github/v/tag/Zhaopudark/PSComputerManagementZp)[![Windows-11](https://img.shields.io/badge/Windows--11-Passing-green)](Examples/Examples.md)[![Ubuntu|WSL2](https://img.shields.io/badge/Ubuntu|WSL2-Passing-green)](Examples/Examples.md)


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

Make sure your PowerShell version is 7.0 or latter.

```powershell
git clone git@github.com:Zhaopudark/PSComputerManagementZp.git
cd PSComputerManagementZp
./install.ps1
```

# APIs

For all reachable functions, see [AIPs](APIs.md). 

# Risks

- May not be compatible with other software or CLI tools or CLI commands or PowerShell Modules. Such as, if you have enabled `system proxy` in `clash`, there is no need to use the case [Set IPV4 system proxy by `Localhost` with `PortNumber`](#Set-system-proxy-IPV4-by-Localhost-with-PortNumber).
- This module will modify registry items in some cases. So, to reduce the potential conflicts with other software, tools, or commands, you have better backup all registry items before using the module. 

# Usage

After installation of this module, you can realize many PC management operations easily. See [Samples](Samples.md) for more details.

Generally, the prerequisites are:

- Make sure your PowerShell version is 7.0 or latter.
- Some cases need `Administrator` privilege.

The following is an example with this module:

## Set system proxy IPV4 by `Localhost` with `PortNumber`

**Fundamental**: Modify `Current User` level registry items  `HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings` to set and unset system level proxy.

Please run PowerShell with `Administrator` privilege. 

Supposing the port number is `7890`, the following commands will automatically detect the IPV4 of localhost and then set system proxy by as 'localhost:7890':

```powershell
#Requires -Version 7.0
#Requires -RunAsAdministrator
Import-Module PSComputerManagementZp -Scope Local -Force
$server_ip = Get-LocalHostIPV4
Set-SystemProxyIPV4ForCurrentUser -ServerIP $server_ip -PortNumber 7890
Remove-Module PSComputerManagementZp
```

Then, open `Windows Settings->Network & Internet->Proxy` for checking:

<img src="./Assets/README.assets/image-20230703160155455.png" alt="image-20230703160155455" style="zoom:67%;" />

# Contribution

Contributions are welcome. But recently, the introduction and documentation are not complete. So, please wait for a while.

A simple way to contribute is to open an issue to report bugs or request new features.

A formative rule is, for variable's name, `snake_case` is used to indicate private variables wile `PascalCase` is used for non-private variables. So, in code style consistency, please consider the above rule.

Another formative rule is that almost all components deal only with existent and accessible paths. If a path is not existent or not accessible, errors or warnings will be thrown. This rule is to avoid unexpected operations and can be seen in almost all components of this module.

On comments, `.SYNOPSIS` and `.DESCRIPTION` may have been used to describe the function's usage and details, with the former being a brief description of key points and the latter being a detailed description with principles and ideas usually. And, `.SYNOPSIS` may use more normal language than `.DESCRIPTION`.