# <img src="https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/av_colors_128.svg?sanitize=true" alt="logo" style="zoom:50%;" /> PSComputerManagementZp

[![PowerShell-7.X](https://img.shields.io/badge/PowerShell-7.X-blue?logo=powershell)](https://learn.microsoft.com/en-us/powershell/)
[![GitHub tag (with filter)](https://img.shields.io/github/v/tag/Zhaopudark/PSComputerManagementZp)](https://github.com/Zhaopudark/PSComputerManagementZp/tags)
[![ReleaseDownloads](https://img.shields.io/github/downloads/Zhaopudark/PSComputerManagementZp/total.svg?style=flat-square)](https://github.com/Zhaopudark/PSComputerManagementZp/releases)

| Tests                                                        | Documentations                                               |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [![Intsallation-Tests.yaml](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/Intsallation-Tests.yaml/badge.svg)](https://github.com/Zhaopudark/PSComputerManagementZp/actions) | [![Home](https://img.shields.io/badge/Home-Home-blue)](README.md) |
| [![Components-Tests.yaml](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/Components-Tests.yaml/badge.svg)](https://github.com/Zhaopudark/PSComputerManagementZp/actions) | [![Public-AIPs](https://img.shields.io/badge/Public-AIPs-orange)](Tests/APIs/README.md) |
| [![APIs-Tests.yaml](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/APIs-Tests.yaml/badge.svg)](https://github.com/Zhaopudark/PSComputerManagementZp/actions) | [![Public-Examples](https://img.shields.io/badge/Public-Examples-red)](Examples/README.md) |

# Backgrounds

I'm a researcher on Machine Learning, especially Deep Learning. In addition, I also do some software development. 

For some specific reasons, I cannot directly develop on a traditional Linux server and have to use a workstation-level PC with Windows (Win11) and WSL2 to realize my daily work. 

Using a shell for PC management is necessary for almost all developers. However, from what I was able to retrieve on the internet, it seems to assume a `Linux and Bash`-based scenario for us, developers in many PC management tutorials or examples, which is far different from my working situation.

This makes me feel lonely helplessness and have to go through [Technical documentation | Microsoft Learn](https://learn.microsoft.com/en-us/docs/), trying to find a way to achieve my own goals.

As a consequence, I have to learn more about Windows development, especially PowerShell. 

Referring to some examples of `Linux and Bash`-based operations, I tried to migrate them to my everyday usage scenarios (`Windows and PowerShell`-based). In the beginning, these were only some simple commands. Then, I merged them into scripts. Now, I think it's time to integrate them into a PowerShell module and share, which not only can help me to simplify my configure operations but also may help those who have similar working scenarios as me.  

# Introduction

This customized PowerShell Module, `PSComputerManagementZp`, derives from my scenarios, which can help users configure their Windows PCs easily to realize many useful operations. The main features that have been supported(opted) or remained to do(non-opted) are as:

- [x] Set system-level proxy.
- [x] Set shell (process) level proxy.
- [x] Set/unset environment variables.
- [x] Format path for both Windows and WSL2.
- [x] Deal with authorization problems on the Windows file system.
- [ ] Set DDNS.
- [ ] Configure backup settings with backup tools, such as [FreeFileSync](https://freefilesync.org/download.php).

Some features are also available on WSL2 and Linux.

# Installation
There are two ways to install and use this module. Make sure your PowerShell version is 7.0 or later.

- From source:

  ```powershell
  git clone git@github.com:Zhaopudark/PSComputerManagementZp.git
  cd PSComputerManagementZp
  ./install.ps1
  ```

- From [PowerShell Gallery](https://www.powershellgallery.com/)

  ```powershell
  Install-Module -Name PSComputerManagementZp
  ```

# Limitations or Risks

- May not be compatible with other software, CLI tools, CLI commands or PowerShell Modules. Such as, if you have enabled `system proxy` in `Clash`, there is no need to use the case [Set IPV4 system proxy by `Localhost` with `PortNumber`](#Set-system-proxy-IPV4-by-Localhost-with-PortNumber).
- This module can modify the `User` and `Machine` level environment variables in some cases, which should be noticed.

# Usage

After installation of this module, you can realize many PC management operations easily. See [Samples](Samples.md) for more details.

Generally, the prerequisites are:

- Make sure your PowerShell version is 7.0 or later.
- Some cases need `Administrator` privilege.

The following is an example:

## Set system proxy IPV4 by `Localhost` with `PortNumber`

**Fundamental**: Modify `Current User` level registry items  `HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings` to set and unset system level proxy.

Please run PowerShell with `Administrator` privilege. 

Supposing the port number is `7890`, the following commands will automatically detect the IPV4 of localhost and then set the system proxy as 'localhost:7890':

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

Here are some formative rules of this module's development:
- **Variable Naming**: `snake_case` is used to indicate private variables while `PascalCase` is used for non-private variables. So, in code style consistency, please consider the above rule.
- **Paths**: Almost all components deal only with existent and accessible paths. If a path is nonexistent or not accessible, errors or warnings will be thrown. This rule is to avoid unexpected operations and can be seen in almost all components of this module.
- **Comments** : `.SYNOPSIS` and `.DESCRIPTION` are both used to describe the function's usage and details, with the former being a brief description of key points and the latter being a detailed description with rationales and ideas. And, `.SYNOPSIS` may use more normal language than `.DESCRIPTION`. There is no restriction that they must be used together.
- **Logging**: The principle is that when making logs, the logs will be written into files anyway. If a log needs to be displayed in the console, it will be done as a `Verbose` message. The private function `Write-FileLogs` should only be used in the private function `Write-Logs`, and the latter is the only logging function in all components. Also, the latter is not an API function for normal users.