function Get-GatewayIPV4{
<#
.DESCRIPTION
    Get the gateway IP address(IPV4) of the current system.
.INPUTS
    None.
.OUTPUTS
    String.
.NOTES
    Only support IPV4.
    Originally, refer to the post [Get Gateway IP Address](https://blog.csdn.net/YOLO3/article/details/81117952).
    But there will be a warning like:
    ```markdown
    File 'xxx' uses WMI cmdlet. For PowerShell 3.0 and above, use CIM cmdlet, which perform the same tasks as the WMI cmdlets.
    The CIM cmdlets comply with WS-Management (WSMan) standards and with the Common Information Model (CIM) standard, which enables the cmdlets to use the same techniques
    to manage Windows computers and those running other operating systems.
    ```
    So in this function, `Get-CimInstance` is used to replace `Get-WmiObject`
.LINK
    [Get Gateway IP Address](https://blog.csdn.net/YOLO3/article/details/81117952).
    [Select-String](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-string?view=powershell-7.3)
#>
    [CmdletBinding()]
    param()
    if (Test-Platform 'Windows'){
        $wmi = Get-CimInstance win32_networkadapterconfiguration -filter "ipenabled = 'true'"
        if ($wmi.DefaultIPGateway.Count -gt 0){
            $gateway_ip = $wmi.DefaultIPGateway[0]
        }
        else{
            $gateway_ip = ''
        }
    }elseif (Test-Platform 'Linux'){
        $gateway_ip = (Select-String '/etc/resolv.conf' -Pattern "nameserver (.*)").Matches.Groups[1].Value #get gateway_ip
    }elseif (Test-Platform 'Wsl2'){
        $gateway_ip = (Select-String '/etc/resolv.conf' -Pattern "nameserver (.*)").Matches.Groups[1].Value #get gateway_ip
    }elseif (Test-Platform 'MacOS') {
        $gateway_ip = $(Get-Content /etc/resolv.conf) #get gateway_ip
    }else{
        throw  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        exit -1
    }
    if ($gateway_ip -match "^([\d]{1,3}[.]){3}\d{1,3}$"){
        return $gateway_ip
    }else{
        throw  "Get the gateway ip faild, only support IPV4, but get ``$gateway_ip``."
        exit -1
    }
}
function Get-LocalHostIPV4{
<#
.DESCRIPTION
    Get the localhost IP address(IPV4) of the current system.
.INPUTS
    None.
.OUTPUTS
    String.
.NOTES
    Only support IPV4.
.LINK
    [GetHostAddresses](https://learn.microsoft.com/en-us/dotnet/api/system.net.dns.gethostaddresses?view=net-7.0).
#>
    [CmdletBinding()]
    param()
    $localhost_addresses = [System.Net.Dns]::GetHostAddresses("localhost") | Where-Object { $_.AddressFamily -eq 'InterNetwork' }
    if ($localhost_addresses.Count -gt 0) {
        $localhost_ip = $localhost_addresses[0].IPAddressToString
    }else {
        $localhost_ip = ''
    }
    if ($localhost_ip -match "^([\d]{1,3}[.]){3}\d{1,3}$"){
        return $localhost_ip
    }else{
        throw  "Get the localhost ip faild, only support IPV4, but get ``$localhost_ip``."
        exit -1
    }
}
function Set-SystemProxyIPV4ForCurrentUser{
<#
.DESCRIPTION
    Set system proxy as `ServerIP:PortNumber` for the current user.
.PARAMETER ServerIP
    The server IP address for proxy.
.PARAMETER PortNumber
    The port number for proxy.
.EXAMPLE
    Set-SystemProxyIPV4ForCurrentUser -ServerIP 127.0.0.1 -PortNumber 7890
.INPUTS
    String.
    String or Int.
.OUTPUTS
    None.
.NOTES
    Not influence environment variables, such as `$Env:http_proxy`, `$Env:https_proxy`, `$Env:ftp_proxy`, `$Env:socks_proxy` etc.
    Not for all users (not on `local machine` level).
    Automatically add bypass list.
    Only support IPV4.
    Limitation: This function has only been tested on a Windows 11 `Virtual Machine` that is hosted by a Windows 11 `Virtual Machine` `Host Machine`.
.LINK
    [Windows core proxy](https://www.mikesay.com/2020/02/03/windows-core-proxy/#%E7%B3%BB%E7%BB%9F%E7%BA%A7%E5%88%AB%E7%9A%84%E8%AE%BE%E7%BD%AE).
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ServerIP,
        [Parameter(Mandatory)]
        [int]$PortNumber
    )

    # set bypass address
    # where <local> and the `Don‘t use proxy server for local (intranet) addresses` option in Windows Settings are related
    $bypass_address = "<local>;localhost;127.*;10.*;172.16.*;" +`
    "172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;" +`
    "172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*"

    # merge the server ip and port number
    $proxyAddress = "${ServerIP}:${PortNumber}"
    # assign the registry key on the current user
    $regKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

    if ($PSCmdlet.ShouldProcess("Set System Proxy IPV4 as $proxyAddress on $regKey",'','')){
        # set system proxy(modify the registry)

        Set-ItemProperty -Path $regKey -Name 'ProxyServer' -Value $proxyAddress
        Set-ItemProperty -Path $regKey -Name 'ProxyEnable' -Value 1
        Set-ItemProperty -Path $regKey -Name 'ProxyOverride' -Value $bypass_address
    }
    # show the proxy info after setting
    $proxyInfo = Get-ItemProperty -Path $regKey | Select-Object -Property ProxyServer, ProxyEnable, ProxyOverride
    Write-Log $proxyInfo -ShowVerbose
}
function Remove-SystemProxyIPV4ForCurrentUser{
<#
.DESCRIPTION
    Revokes all opeartions in function `Set-SystemProxyIPV4ForCurrentUser`
.INPUTS
    None.
.OUTPUTS
    None.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    # assign the registry key on the current user
    $regKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
    if ($PSCmdlet.ShouldProcess("Unset System Proxy IPV4 on $regKey",'','')){
        Set-ItemProperty $regKey -Name 'ProxyServer' -Value ''
        # Remove-ItemProperty $regKey -Name 'ProxyServer'
        Set-ItemProperty $regKey -Name 'ProxyEnable' -Value 0
        # Remove-ItemProperty $regKey -Name 'ProxyEnable'
        Set-ItemProperty $regKey -Name 'ProxyOverride' -Value ''
        # Remove-ItemProperty $regKey -Name 'ProxyOverride'
        # TODO
        # There may be some bugs that `Remove-ItemProperty` do not work. (Removing will be successful but
        # `Windows Settings->Network & Internet->Proxy` still exists)
    }

    # show the proxy info after removing
    $proxyInfo = Get-ItemProperty $regKey | Select-Object -Property ProxyServer, ProxyEnable, ProxyOverride
    Write-Log $proxyInfo -ShowVerbose
}
function Set-EnvProxyIPV4ForShellProcess{
<#
.DESCRIPTION
    Set environment variables as `ServerIP:PortNumber` for the current shell process.
.PARAMETER ServerIP
    The server IP address for proxy.
.PARAMETER PortNumber
    The port number for proxy.
.EXAMPLE
    Set-EnvProxyIPV4ForShellProcess -ServerIP 127.0.0.1 -PortNumber 7890
.INPUTS
    String.
    String or Int.
.OUTPUTS
    None.
.NOTES
    Not influence system proxy.
    Only support IPV4.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ServerIP,
        [Parameter(Mandatory)]
        [int]$PortNumber
    )
    if ($PSCmdlet.ShouldProcess("Set env items http_proxy,https_proxy,all_proxy,ftp_proxy,socks_proxy as IPV4 ${ServerIP}:${PortNumber} for the current shell process",'','')){
        [Environment]::SetEnvironmentVariable('http_proxy',"http://${ServerIP}:${PortNumber}")
        [Environment]::SetEnvironmentVariable('https_proxy',"http://${ServerIP}:${PortNumber}")
        [Environment]::SetEnvironmentVariable('all_proxy',"http://${ServerIP}:${PortNumber}")
        [Environment]::SetEnvironmentVariable('ftp_proxy',"http://${ServerIP}:${PortNumber}")
        [Environment]::SetEnvironmentVariable('socks_proxy',"socks5://${ServerIP}:${PortNumber}")
    }

}
function Remove-EnvProxyIPV4ForShellProcess{
<#
.DESCRIPTION
    Revokes all opeartions in function `Set-EnvProxyIPV4ForShellProcess`.
.INPUTS
    None.
.OUTPUTS
    None.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($PSCmdlet.ShouldProcess("Unset env items http_proxy,https_proxy,all_proxy,ftp_proxy,socks_proxy for the current shell process",'','')){
        [Environment]::SetEnvironmentVariable('http_proxy','')
        [Environment]::SetEnvironmentVariable('https_proxy','')
        [Environment]::SetEnvironmentVariable('all_proxy','')
        [Environment]::SetEnvironmentVariable('ftp_proxy','')
        [Environment]::SetEnvironmentVariable('socks_proxy','')
    }
}