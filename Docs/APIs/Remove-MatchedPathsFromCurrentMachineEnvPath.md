---
external help file: PSComputerManagementZp-help.xml
Module Name: PSComputerManagementZp
online version:
schema: 2.0.0
---

# Remove-MatchedPathsFromCurrentMachineEnvPath

## SYNOPSIS

## SYNTAX

```
Remove-MatchedPathsFromCurrentMachineEnvPath [-Pattern] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove matched paths from the current machine level `$Env:PATH`.
Before removing, the function will check and de-duplicate the current machine level `$Env:PATH`.

## EXAMPLES

### EXAMPLE 1
```
Remove-MatchedPathsFromCurrentMachineEnvPath -Pattern 'Git'
# It will remove all the paths that match the pattern 'Git' in the machine level `$Env:PATH`.
```

## PARAMETERS

### -Pattern
The pattern to be matched to represent the items to be removed.

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
## OUTPUTS

### None.
## NOTES
Only support Windows.
Need Administrator privilege.

## RELATED LINKS

[ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)


