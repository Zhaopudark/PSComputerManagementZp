#Requires -Version 7.0
#Requires -RunAsAdministrator
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ServerType,
    [Parameter(Mandatory)]
    [int]$PortNumber,
    [string]$ServerIP
)
<#
.SYNOPSIS
    Set system proxy.
    It can be used on a windows `Virtual Machine` that hosted by a `Host Machine`
    which has been proxied and enabled `proxy on LAN (Local Area Network)`.

.DESCRIPTION
    Set system proxy as `ServerIP:PortNumber` for the current user.
    It does not influence environment variables, such as
        $Env:http_proxy, $Env:https_proxy, $Env:ftp_proxy, $Env:socks_proxy etc.
    It is not for all users (not on `local machine` level).
    Automatically add bypass list.
    It only support IPV4.

.PARAMETER ServerType
    String in @('Gateway','LocalHost','Others')
    If $ServerType is `Gateway` or `LocalHost`, the $ServerIP will be ignored and automatically set as
    correspointing gateway IP(IPV4) or localhost IP(IPV4).

.PARAMETER PortNumber
    The port number for proxy.

.PARAMETER ServerIP
    The server IP address for proxy.
    If $ServerType is not `Gateway` or `LocalHost`, the $ServerIP is needed and will be used as the proxy server IP.

.COMPONENT
    Module PSComputerManagementZp
    Get-GatewayIPV4
    Get-LocalHostIPV4
    Set-SystemProxyIPV4ForCurrentUser

.NOTES
    Make sure the module `PSComputerManagementZp` has been
        installed (can be founded in PowerShell Mudules Paths).
        Such as in $Home\Documents\WindowsPowerShell\Modules.
.EXAMPLE
    # This can be used on Hyper-V Windows-11, if whose host has been enable `Allow LAN`(in Clash),
    # since by default the gateway IP of a Hyper-V windows is the IP of vEthernet (Default Switch) on its host.
    # To specific:
    ./SetSystemProxy.ps1 -ServerType 'gateway' -PortNumber 7890

#>
try {
    Import-Module PSComputerManagementZp -Scope Local -Force
    if ($ServerType.ToLower() -eq 'gateway') {
        $ServerIP = Get-GatewayIPV4
    } elseif ($ServerType.ToLower() -eq 'localhost') {
        $ServerIP = Get-LocalHostIPV4
    }
    else {
        if ($ServerIP -eq $null) {
            throw "ServerIP is needed when ServerType is not Gateway or LocalHost"
        }
    }
    Set-SystemProxyIPV4ForCurrentUser -ServerIP $ServerIP -PortNumber $PortNumber
    Remove-Module PSComputerManagementZp
}
catch {
    Write-VerboseLog  "Exception caught: $_"
    Write-VerboseLog  "Set system proxy failed."
    exit -1
}