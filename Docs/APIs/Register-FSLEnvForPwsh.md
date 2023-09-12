---
external help file: PSComputerManagementZp-help.xml
Module Name: PSComputerManagementZp
online version:
schema: 2.0.0
---

# Register-FSLEnvForPwsh

## SYNOPSIS
Setup FSL environment variables for pwsh as well as FSL's bash settings in .profile

## SYNTAX

```
Register-FSLEnvForPwsh [-FslDir] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
FSL is a comprehensive library of analysis tools for FMRI, MRI and diffusion brain imaging data.
See the [FSL doc](ttps://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)

This function is used to setup FSL environment variables for pwsh as well as FSL's bash settings in .profile.
It mimics the following bash settings in .profile:

```bash
# FSL Setup
FSLDIR=/home/some_user_name/fsl
PATH=${FSLDIR}/share/fsl/bin:${PATH}
export FSLDIR PATH
.
${FSLDIR}/etc/fslconf/fsl.sh
```

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -FslDir
The FSL installation directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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
When it comes to setup FSL, the official scripts [fslinstaller.py](https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py)
do not support pwsh, but support bash.
It will automatically register procedures in .profile.
to setup FSL environment variables.

If we use pwsh in WSL2 directly, i.e., set pwsh as the default shell in WSL2, we have to mimic all bash settings to maintain corresponding
components, especially environment variables, including the FSL's bash settings.

But actually, we usually do not launch pwsh directly, but launch bash first, then call pwsh in bash.
This priority (launching sequence) is also suitable for using pwsh in VS Code remote.

The normal launch sequence of bash and its configuration files is:
    bash-\>.profile(where .bashrc is contained and called once, and append some extra settings.)
Then, the normal interactive terminal is presented.
For following  calls of bash, .profile will not be executed, but .bashrc will be executed each time.
In normal usage, we usually call pwsh after bash is launched.
So the FSL environment variables that
have been set in .profile will be inherited by pwsh.

So, there is no need to setup FSL environment variables for pwsh again.
This function is just for a record.

Only support Linux and WSL2.

## RELATED LINKS

[FSL](https://fsl.fmrib.ox.ac.uk)
[ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)


