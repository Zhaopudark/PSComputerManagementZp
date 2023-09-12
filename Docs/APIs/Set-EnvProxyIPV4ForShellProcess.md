---
external help file: PSComputerManagementZp-help.xml
Module Name: PSComputerManagementZp
online version:
schema: 2.0.0
---

# Set-EnvProxyIPV4ForShellProcess

## SYNOPSIS

## SYNTAX

```
Set-EnvProxyIPV4ForShellProcess [-ServerIP] <String> [-PortNumber] <Int32> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Set environment variables as `ServerIP:PortNumber` for the current shell process.

## EXAMPLES

### EXAMPLE 1
```
Set-EnvProxyIPV4ForShellProcess -ServerIP 127.0.0.1 -PortNumber 7890
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
Not influence system proxy.
Only support IPV4.

## RELATED LINKS

