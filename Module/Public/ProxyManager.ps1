function Set-SystemProxyIPV4ForCurrentUser{
<#
.DESCRIPTION
    Set system proxy as `ServerIP:PortNumber` for the current user.
    It does not influence environment variables, such as
        $Env:http_proxy, $Env:https_proxy, $Env:ftp_proxy, $Env:socks_proxy etc.
    It is not for all users (not on `local machine` level).
    Automatically add bypass list.
    It only support IPV4.
    Refer to https://www.mikesay.com/2020/02/03/windows-core-proxy/#%E7%B3%BB%E7%BB%9F%E7%BA%A7%E5%88%AB%E7%9A%84%E8%AE%BE%E7%BD%AE
    Refer to [Chat-GPT](https://chat.openai.com/)

.PARAMETER ServerIP
    The server IP address for proxy.

.PARAMETER PortNumber
    The port number for proxy.

.EXAMPLE
    Set-SystemProxyIPV4ForCurrentUser -ServerIP 127.0.0.1 -PortNumber 7890.

.NOTES
    Limitation: This function has only been tested on a Windows 11 `Virtual Machine` that hosted
    by a Windows 11 `Virtual Machine` `Host Machine`.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ServerIP,
        [Parameter(Mandatory)]
        [int]$PortNumber
    )

    # 设置绕过代理的地址
    # 其中 <local> 和Window系统设置中，代理设置的`Don‘t use proxy server for local (intranet) addresses` 选项有关
    $bypass_address = "<local>;localhost;127.*;10.*;172.16.*;" +`
    "172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;" +`
    "172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*"

    # 将代理服务器地址和端口地址合并
    $proxyAddress = "${ServerIP}:${PortNumber}"
    # 指定注册表项
    $regKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'

    if ($PSCmdlet.ShouldProcess("Set System Proxy IPV4 as $proxyAddress on $regKey",'','')){
        # 设置系统代理(修改当前用户的注册表项, 即当前用户级别)
        Set-ItemProperty -Path $regKey -Name 'ProxyServer' -Value $proxyAddress
        Set-ItemProperty -Path $regKey -Name 'ProxyEnable' -Value 1
        Set-ItemProperty -Path $regKey -Name 'ProxyOverride' -Value $bypass_address


        # 设置绕过代理的地址
        # $existingBypass = (Get-ItemProperty -Path $regKey -Name 'ProxyOverride').ProxyOverride
        # $newBypass = "$existingBypass;$bypass_address"
        # Set-ItemProperty -Path $regKey -Name 'ProxyOverride' -Value $newBypass
    }
    # 显示设置后的代理信息
    $proxyInfo = Get-ItemProperty -Path $regKey | Select-Object -Property ProxyServer, ProxyEnable, ProxyOverride
    Write-VerboseLog $proxyInfo -Verbose
}
function Remove-SystemProxyIPV4ForCurrentUser{
<#
.DESCRIPTION
    Revokes all opeartions in function `Set-SystemProxyIPV4ForCurrentUser`
.INPUTS
    None
.OUTPUTS
    None
#>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    # 指定注册表项
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

    # 显示设置后的代理信息
    $proxyInfo = Get-ItemProperty $regKey | Select-Object -Property ProxyServer, ProxyEnable, ProxyOverride
    Write-VerboseLog $proxyInfo -Verbose
}
function Set-EnvProxyIPV4ForShellProcess{
<#
.DESCRIPTION
    Set environment variables as `ServerIP:PortNumber` for the current shell process.
    It does not influence system proxy.
    It only support IPV4.

.PARAMETER ServerIP
    The server IP address for proxy.

.PARAMETER PortNumber
    The port number for proxy.

.EXAMPLE
    Set-EnvProxyIPV4ForShellProcess -ServerIP 127.0.0.1 -PortNumber 7890.

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
    Revokes all opeartions in function `Set-EnvProxyIPV4ForShellProcess`
.INPUTS
    None
.OUTPUTS
    None
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