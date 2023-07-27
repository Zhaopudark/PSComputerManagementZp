function Get-GatewayIPV4{
<#
.DESCRIPTION
    Get the gateway IP address(IPV4) of the current system.
.INPUTS
    None
.OUTPUTS
    System.String
.NOTES
    It only support IPV4.
#> 
    [CmdletBinding()]
    param()    
    if (Test-IfIsOnCertainPlatform -SystemName 'Windows'){
        # get Gateway IP, see https://blog.csdn.net/YOLO3/article/details/81117952
        $wmi = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"
        return $wmi.DefaultIPGateway
    }elseif (Test-IfIsOnCertainPlatform -SystemName 'Wsl2'){
        $gateway_ip = $(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*') #get gateway_ip
        return $gateway_ip
    }else{
        Write-Host "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        exit -1
    }
}
function Get-LocalHostIPV4{
<#
.DESCRIPTION
    Get the localhost IP address(IPV4) of the current system.
.INPUTS
    None
.OUTPUTS
    System.String
.NOTES
    It only support IPV4.
#> 
    [CmdletBinding()]
    param()    
    $localhostIPv4 = [System.Net.Dns]::GetHostAddresses("localhost") | Where-Object { $_.AddressFamily -eq 'InterNetwork' }
    if ($localhostIPv4.Count -gt 0) {
        return $($localhostIPv4[0].IPAddressToString)
    }else {
        return  $null
    }
}

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
    $regKey = 'HKCU:/Software/Microsoft/Windows/CurrentVersion/Internet Settings'

    # 设置系统代理(修改当前用户的注册表项, 即当前用户级别)
    Set-ItemProperty -Path $regKey -Name 'ProxyServer' -Value $proxyAddress
    Set-ItemProperty -Path $regKey -Name 'ProxyEnable' -Value 1
    Set-ItemProperty -Path $regKey -Name 'ProxyOverride' -Value $bypass_address


    # 设置绕过代理的地址
    # $existingBypass = (Get-ItemProperty -Path $regKey -Name 'ProxyOverride').ProxyOverride
    # $newBypass = "$existingBypass;$bypass_address"
    # Set-ItemProperty -Path $regKey -Name 'ProxyOverride' -Value $newBypass

    # 显示设置后的代理信息
    $proxyInfo = Get-ItemProperty -Path $regKey | Select-Object -Property ProxyServer, ProxyEnable, ProxyOverride
    $proxyInfo 
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
    param()    
    # 指定注册表项
    $regKey = 'HKCU:/Software/Microsoft/Windows/CurrentVersion/Internet Settings'

    Set-ItemProperty -Path $regKey -Name 'ProxyServer' -Value ''
    # Remove-ItemProperty -Path $regKey -Name 'ProxyServer'
    Set-ItemProperty -Path $regKey -Name 'ProxyEnable' -Value 0
    # Remove-ItemProperty -Path $regKey -Name 'ProxyEnable'
    Set-ItemProperty -Path $regKey -Name 'ProxyOverride' -Value ''
    # Remove-ItemProperty -Path $regKey -Name 'ProxyOverride'
    # TODO 
    # There may be some bugs that `Remove-ItemProperty` do not work. (Removing will be successful but
    # `Windows Settings->Network & Internet->Proxy` still exists)

    # 显示设置后的代理信息
    $proxyInfo = Get-ItemProperty -Path $regKey | Select-Object -Property ProxyServer, ProxyEnable, ProxyOverride
    $proxyInfo
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
    param(
        [Parameter(Mandatory)]
        [string]$ServerIP,
        [Parameter(Mandatory)]
        [int]$PortNumber
    )  
    [Environment]::SetEnvironmentVariable('http_proxy',"http://${ServerIP}:${PortNumber}")
    [Environment]::SetEnvironmentVariable('https_proxy',"http://${ServerIP}:${PortNumber}")
    [Environment]::SetEnvironmentVariable('all_proxy',"http://${ServerIP}:${PortNumber}")
    [Environment]::SetEnvironmentVariable('ftp_proxy',"http://${ServerIP}:${PortNumber}")
    [Environment]::SetEnvironmentVariable('socks_proxy',"socks5://${ServerIP}:${PortNumber}")  
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
    param()  
    [Environment]::SetEnvironmentVariable('http_proxy','')
    [Environment]::SetEnvironmentVariable('https_proxy','')
    [Environment]::SetEnvironmentVariable('all_proxy','')
    [Environment]::SetEnvironmentVariable('ftp_proxy','')
    [Environment]::SetEnvironmentVariable('socks_proxy','') 
}