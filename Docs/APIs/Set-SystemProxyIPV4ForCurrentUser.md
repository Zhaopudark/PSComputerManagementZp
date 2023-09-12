---
external help file: PSComputerManagementZp-help.xml
Module Name: PSComputerManagementZp
online version:
schema: 2.0.0
---

# Set-SystemProxyIPV4ForCurrentUser

## SYNOPSIS

## SYNTAX

```
Set-SystemProxyIPV4ForCurrentUser [-ServerIP] <String> [-PortNumber] <Int32> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Set system proxy as `ServerIP:PortNumber` for the current user.

## EXAMPLES

### EXAMPLE 1
```
Set-SystemProxyIPV4ForCurrentUser -ServerIP 127.0.0.1 -PortNumber 7890
```

## PARAMETERS

### -ServerIP
The server IP address for proxy.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PortNumber
The port number for proxy.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String.
### String or Int.
## OUTPUTS

### None.
## NOTES
Not influence environment variables, such as `$Env:http_proxy`, `$Env:https_proxy`, `$Env:ftp_proxy`, `$Env:socks_proxy` etc.
Not for all users (not on `local machine` level).
Automatically add bypass list.
Only support IPV4.
Limitation: This function has only been tested on a Windows 11 `Virtual Machine` that is hosted by a Windows 11 `Virtual Machine` `Host Machine`.

## RELATED LINKS

[Windows core proxy](https://www.mikesay.com/2020/02/03/windows-core-proxy/#%E7%B3%BB%E7%BB%9F%E7%BA%A7%E5%88%AB%E7%9A%84%E8%AE%BE%E7%BD%AE).


