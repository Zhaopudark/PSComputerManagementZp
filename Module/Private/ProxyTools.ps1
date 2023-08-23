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
    if (Test-Platform 'Windows'){
        # get Gateway IP, see https://blog.csdn.net/YOLO3/article/details/81117952
        # $wmi = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"
        # File 'ProxyTools.psm1' uses WMI cmdlet. For PowerShell 3.0 and above, use CIM cmdlet
        # which perform the same tasks as the WMI cmdlets. The CIM cmdlets comply with WS-Management (WSMan) standards
        # and with the Common Information Model (CIM) standard, which enables the cmdlets to use the same techniques
        # to manage Windows computers and those running other operating systems.
        # So, use Get-CimInstance to replace Get-WmiObject
        $wmi = Get-CimInstance win32_networkadapterconfiguration -filter "ipenabled = 'true'"
        return $wmi.DefaultIPGateway
    }elseif (Test-Platform 'Linux'){
        $gateway_ip = $(Get-Content /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*') #get gateway_ip
        return $gateway_ip
    }elseif (Test-Platform 'Wsl2'){
        $gateway_ip = $(Get-Content /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*') #get gateway_ip
        return $gateway_ip
    }else{
        Write-VerboseLog  "The current platform, $($PSVersionTable.Platform), has not been supported yet."
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