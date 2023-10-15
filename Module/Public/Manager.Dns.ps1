function Get-TargetIPV6ByPattern{
<#
.DESCRIPTION
    Get a target IPV6 address by pattern.
    If multiple IPV6 addresses are found, return the last one.
    If the target IPV6 address is not found, throw an exception.
.INPUTS
    None.
.OUTPUTS
    String.
.NOTES
    Only support IPV6. Only support Windows.
.LINK
    [GetHostAddresses](https://learn.microsoft.com/en-us/dotnet/api/system.net.dns.gethostaddresses?view=net-7.0)
#>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory=$true)]
        [string]$AdapterPattern,
        [Parameter(Mandatory=$true)]
        [string]$AdressPattern

    )
    Assert-IsWindows

    $addresses = Get-NetIPAddress -AddressFamily IPv6 |`
        Where-Object {($_.InterfaceAlias -match $AdapterPattern) -and ($_.IPAddress -match $AdressPattern)}|`
        ForEach-Object {$_.IPAddress}

    if ($addresses.Count -eq 0){
        throw "No IPV6 address is found by the pattern, AdapterPattern: $AdapterPattern, AdressPattern: $AdressPattern."
        exit -1
    }elseif ($addresses.Count -gt 1){
        return $addresses[0]
    }else{
        return $addresses
    }
}
function Add-OrUpdateDnsDomainRecord4Aliyun{
<#
.DESCRIPTION
    Add or update a DNS domain record for Aliyun.
.NOTES
    Only 4 (mandatory) parameters are supported for customization, the rest will follow the default settings.
.LINK
    [Aliyun DNS API](https://help.aliyun.com/document_detail/124923.html)
    [AddDomainRecord](https://help.aliyun.com/document_detail/2355674.html?spm=a2c4g.29772.0.i0)
    [UpdateDomainRecord](https://help.aliyun.com/document_detail/2355677.html?spm=a2c4g.2355674.0.0.1684f0810Frt6B)
    [Redirection](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.3#example-3-send-success-warning-and-error-streams-to-a-file)
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DomainName,
        [Parameter(Mandatory=$true)]
        [string]$RecordName,
        [Parameter(Mandatory=$true)]
        [string]$RecordType,
        [Parameter(Mandatory=$true)]
        [string]$RecordValue
    )
    Assert-AliyunCLIAvailable
    $DescribeDomainRecords = aliyun alidns DescribeDomainRecords --DomainName little-train.com | ConvertFrom-Json
    $name_type_records = @()
    foreach($item in $DescribeDomainRecords.DomainRecords.Record){
        $name_type_records += $item.RR+$item.Type
    }

    $records = $DescribeDomainRecords.DomainRecords.Record | Foreach-Object {$_.RR+$_.Type}
    $index = $records.IndexOf($RecordName+$RecordType)

    if ($index -eq -1){
        # add
        $command = "aliyun alidns AddDomainRecord --DomainName $DomainName --RR $RecordName --Type $RecordType --Value $RecordValue"
        $output = (Invoke-Expression $command) 2>&1 | Out-String
        Write-Log $output -ShowVerbose
    }elseif ($RecordValue -ne $DescribeDomainRecords.DomainRecords.Record[$index].Value ){
        # update
        $RecordId = $DescribeDomainRecords.DomainRecords.Record[$index].RecordId
        $command = "aliyun alidns UpdateDomainRecord --RecordId $RecordId  --RR $RecordName --Type $RecordType --Value $RecordValue"
        $output = (Invoke-Expression $command) 2>&1 | Out-String
        Write-Log $output -ShowVerbose
    }else{
        # do nothing
        Write-Log "The DNS domain record does not need to be updated, do nothing." -ShowVerbose
    }
}