<div align="center">
<strong>
<samp>

<img src="https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/av_colors_128.svg?sanitize=true" alt="logo" /> 

# PSComputerManagementZp

[![PowerShell-7.X](https://img.shields.io/badge/PowerShell-7.X-blue?logo=powershell)](https://learn.microsoft.com/en-us/powershell/)
[![GitHub release (with filter)](https://img.shields.io/github/v/release/Zhaopudark/PSComputermanagementZp?logo=github)](https://github.com/Zhaopudark/PSComputerManagementZp/releases)
[![GitHub tag (with filter)](https://img.shields.io/github/v/tag/Zhaopudark/PSComputerManagementZp?logo=github)](https://github.com/Zhaopudark/PSComputerManagementZp/tags)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/PSComputerManagementZp?logo=powershell&label=PowerShell%20Gallery%20downloads)](https://www.powershellgallery.com/packages/PSComputerManagementZp)
[![GitHub Release Downloads](https://img.shields.io/github/downloads/Zhaopudark/PSComputerManagementZp/total?logo=github&label=Github%20Release%20downloads)
](https://github.com/Zhaopudark/PSComputerManagementZp/releases)
[![GitHub](https://img.shields.io/github/license/Zhaopudark/PSComputerManagementZp)](https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/LICENSE)
[![Codecov](https://img.shields.io/codecov/c/github/Zhaopudark/PSComputerManagementZp?label=Codecov-on-Windows)](https://app.codecov.io/gh/Zhaopudark/PSComputerManagementZp)


[![Home](https://img.shields.io/badge/Home-Home-blue)](README.md)
[![Public-Examples](https://img.shields.io/badge/Public-Examples-royalblue)](Examples/README.md)
[![Public-AIPs](https://img.shields.io/badge/Public-AIPs-orange)](Docs/APIs/README.md)
[![Private-Components](https://img.shields.io/badge/Private-Components-pink)](Docs/Components/README.md)
</samp>
</strong>
</div>

# CI Tests on multiple platforms

| Linux (Restricted Features)                                  | Windows (Full Features)                                      | MacOS(Restricted Features)                                   |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [![Intsallation-Tests-on-Linux.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/Intsallation-Tests-on-Linux.yaml?label=Intsallation%20on%20Linux)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/Intsallation-Tests-on-Linux.yaml) | [![Intsallation-Tests-on-Windows.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/Intsallation-Tests-on-Windows.yaml?label=Intsallation%20on%20Windows)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/Intsallation-Tests-on-Windows.yaml) | [![Intsallation-Tests-on-MacOS.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/Intsallation-Tests-on-MacOS.yaml?label=Intsallation%20on%20MacOS)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/Intsallation-Tests-on-MacOS.yaml) |
| [![Components-Tests-on-Linux.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/Components-Tests-on-Linux.yaml?label=Components%20Tests%20on%20Linux)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/Components-Tests-on-Linux.yaml) | [![Components-Tests-on-Windows.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/Components-Tests-on-Windows.yaml?label=Components%20Tests%20on%20Windows)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/Components-Tests-on-Windows.yaml) | [![Components-Tests-on-MacOS.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/Components-Tests-on-MacOS.yaml?label=Components%20Tests%20on%20MacOS)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/Components-Tests-on-MacOS.yaml) |
| [![APIs-Tests-on-Linux.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/APIs-Tests-on-Linux.yaml?label=APIs%20Tests%20on%20Linux)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/APIs-Tests-on-Linux.yaml) | [![APIs-Tests-on-Windows.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/APIs-Tests-on-Windows.yaml?label=APIs%20Tests%20on%20Windows)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/APIs-Tests-on-Windows.yaml) | [![APIs-Tests-on-MacOS.yaml](https://img.shields.io/github/actions/workflow/status/Zhaopudark/PSComputerManagementZp/APIs-Tests-on-MacOS.yaml?label=APIs%20Tests%20on%20MacOS)](https://github.com/Zhaopudark/PSComputerManagementZp/actions/workflows/APIs-Tests-on-MacOS.yaml) |

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
- [x] Set DDNS. (Only support Aliyun DDNS now)

Some features are also available on WSL2 and Linux.

# Installation
There are two ways to install and use this module. Make sure your PowerShell version is 7.0 or later.

- **From source**, with the latest version (maybe pre-release version):

  ```powershell
  git clone git@github.com:Zhaopudark/PSComputerManagementZp.git
  cd PSComputerManagementZp
  ./install.ps1
  ```

- **From source**, with a specific version:

  ```powershell
  git clone git@github.com:Zhaopudark/PSComputerManagementZp.git
  cd PSComputerManagementZp
  git checkout v0.0.3
  ./install.ps1
  ```
  
- **From [PowerShell Gallery](https://www.powershellgallery.com/)**, with the stable version:

  ```powershell
  Install-Module -Name PSComputerManagementZp -Force
  ```
  If it has been installed already, just update:
  ```powershell
  Update-Module -Name PSComputerManagementZp -Force
  ```

- **From [PowerShell Gallery](https://www.powershellgallery.com/)**, with the latest version(maybe pre-release version):

  ```powershell
  Install-Module -Name PSComputerManagementZp -Force -AllowPrerelease
  ```
  If it has been installed already, just update:
  ```powershell
  Update-Module -Name PSComputerManagementZp -Force -AllowPrerelease
  ```

# Limitations or Risks

- May not be compatible with other software, CLI tools, CLI commands or PowerShell Modules. Such as, if you have enabled `system proxy` in some tools, there is no need to use the case [Set IPV4 system proxy by `Localhost` with `PortNumber`](https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/Examples/README.md#set-system-proxy-ipv4-by-localhost-with-portnumber).
- This module can modify the `User` and `Machine` level environment variables in some cases, which should be noticed.

# Usage

After installation of this module, you can realize many PC management operations easily. See the [samples](Examples/README.md) for more details and more samples.

Generally, the prerequisites are:

- Make sure your PowerShell version is 7.0 or later.
- Some cases need `Administrator` privilege.

## Usage Examples
The following is an example: Set system proxy IPV4 by `Localhost` with `PortNumber`.

**Fundamental**: Modify `Current User` level registry items  `HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings` to set and unset system level proxy.

**Note**: ==This module is not a proxy tool, but a tool to help you configure the system level proxy. So, you should have a proxy server first.==

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

See [Contribution Guide](CONTRIBUTION.md) for more details.
