---
external help file: PSComputerManagementZp-help.xml
Module Name: PSComputerManagementZp
online version:
schema: 2.0.0
---

# Get-GatewayIPV4

## SYNOPSIS

## SYNTAX

```
Get-GatewayIPV4 [<CommonParameters>]
```

## DESCRIPTION
Get the gateway IP address(IPV4) of the current system.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### String.
## NOTES
Only support IPV4.
Originally, refer to the post [Get Gateway IP Address](https://blog.csdn.net/YOLO3/article/details/81117952).
But there will be a warning like:
```markdown
File 'xxx' uses WMI cmdlet.
For PowerShell 3.0 and above, use CIM cmdlet, which perform the same tasks as the WMI cmdlets.
The CIM cmdlets comply with WS-Management (WSMan) standards and with the Common Information Model (CIM) standard, which enables the cmdlets to use the same techniques
to manage Windows computers and those running other operating systems.
```
So in this function, `Get-CimInstance` is used to replace `Get-WmiObject`

## RELATED LINKS

[Get Gateway IP Address](https://blog.csdn.net/YOLO3/article/details/81117952).
[Select-String](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-string?view=powershell-7.3)


