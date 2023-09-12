---
external help file: PSComputerManagementZp-help.xml
Module Name: PSComputerManagementZp
online version:
schema: 2.0.0
---

# Reset-Authorization

## SYNOPSIS
Reset the ACL and attributes of a path to its default state if we have already known the default state exactly.
For more information on the motivations, rationale, logic, limitations and usage of this function, see the [post](https://little-train.com/posts/7fdde8eb.html).

## SYNTAX

```
Reset-Authorization [-Path] <FormattedFileSystemPath>] [-Recurse] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Reset ACL of `$Path` to its default state by 3 steps:
    1.
Get path type by `Get-PathType`
    2.
Get default SDDL of `$Path` by `Get-DefaultSddl` according to `$path_type`
    3.
Set SDDL of `$Path` to default SDDL by `Set-Acl`

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
The path to be reset.

```yaml
Type: FormattedFileSystemPath
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse
A switch parameter to indicate whether to reset the ACL of all files and directories in the path recursively.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### String or FormattedFileSystemPath.
## OUTPUTS

### None.
## NOTES
Only support Windows.

## RELATED LINKS

[Authorization](https://little-train.com/posts/7fdde8eb.html).
[ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)


