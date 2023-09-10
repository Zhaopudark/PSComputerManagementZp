

function Merge-RedundantEnvPathsFromCurrentMachineToCurrentUser{
<#
.DESCRIPTION
    Merge redundant items form the current machine level env paths to the current user level.
    Before merging, the function will check and de-duplicate the current machine level and the current user level env paths.
.INPUTS
    None.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.DESCRIPTION
    Sometimes, we may find some redundant items that both in the machine level and the user level env paths.
    This may because we have installed some software in different privileges.
    This function will help us to merge the redundant items from the machine level env paths to the user level.
    The operation can symplify the `$Env:PATH`.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param()
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPaths]::new()
    if($PSCmdlet.ShouldProcess("Merge redundant items from the current machine level env paths to the current user level",'','')){
        $env_paths.MergeDeDuplicatedEnvPathsFromMachineLevelToUserLevel()
    }
}

function Add-PathToCurrentProcessEnvPaths{
<#
.DESCRIPTION
    Append a path to the current process level env paths.
    Before appending, the function will check and de-duplicate the current process level env paths.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.EXAMPLE
    ```powershell
    Add-PathToCurrentProcessEnvPaths -Path 'C:\Program Files\Git\cmd'
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    $env_paths = [EnvPaths]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to process level env path",'','')){
        $env_paths.AppendProcessLevelEnvPaths($Path)
    }
}
function Add-PathToCurrentUserEnvPaths{
<#
.DESCRIPTION
    Append a path to the current user level env paths.
    Before appending, the function will check and de-duplicate the current user level env paths.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    ```powershell
    Add-PathToCurrentUserEnvPaths -Path 'C:\Program Files\Git\cmd'
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindows
    $env_paths = [EnvPaths]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to user level env path",'','')){
        $env_paths.AppendUserLevelEnvPaths($Path)
    }
}

function Add-PathToCurrentMachineEnvPaths{
<#
.DESCRIPTION
    Append a path to the current machine level env paths.
    Before appending, the function will check and de-duplicate the current machine level env paths.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    ```powershell
    Add-PathToCurrentMachineEnvPaths -Path 'C:\Program Files\Git\cmd'
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPaths]::new()
    if ($PSCmdlet.ShouldProcess("Append $Path to machine level env path",'','')){
        $env_paths.AppendMachineLevelEnvPaths($Path)
    }
}

function Remove-PathFromCurrentProcessEnvPaths{
<#
.DESCRIPTION
    Remove a path from the current process level env paths.
    Before removing, the function will check and de-duplicate the current process level env paths.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.EXAMPLE
    ```powershell
    Remove-PathFromCurrentProcessEnvPaths -Path 'C:\Program Files\Git\cmd'
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    $env_paths = [EnvPaths]::new()
    $IsPattern = $false
    if ($PSCmdlet.ShouldProcess("Remove $Path from process level env path",'','')){
        $env_paths.RemoveProcessLevelEnvPaths($Path,$IsPattern)
    }
}

function Remove-PathFromCurrentUserEnvPaths{
<#
.DESCRIPTION
    Remove a path from the current user level env paths.
    Before removing, the function will check and de-duplicate the current user level env paths.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    ```powershell
    Remove-PathFromCurrentUserEnvPaths -Path 'C:\Program Files\Git\cmd'
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindows
    $env_paths = [EnvPaths]::new()
    $IsPattern = $false
    if ($PSCmdlet.ShouldProcess("Remove $Path from user level env path",'','')){
        $env_paths.RemoveUserLevelEnvPaths($Path,$IsPattern)
    }
}

function Remove-PathFromCurrentMachineEnvPaths{
<#
.DESCRIPTION
    Remove a path from the current machine level env paths.
    Before removing, the function will check and de-duplicate the current machine level env paths.
.INPUTS
    A string of the path.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    ```powershell
    Remove-PathFromCurrentMachineEnvPaths -Path 'C:\Program Files\Git\cmd'
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPaths]::new()
    $IsPattern = $false
    if ($PSCmdlet.ShouldProcess("Remove $Path from machine level env path",'','')){
        $env_paths.RemoveMachineLevelEnvPaths($Path,$IsPattern)
    }
}
function Remove-MatchedPathsFromCurrentProcessEnvPaths{
<#
.DESCRIPTION
    Remove matched paths from the current process level env paths.
    Before removing, the function will check and de-duplicate the current process level env paths.
.INPUTS
    A string of pattern.
.OUTPUTS
    None.
.EXAMPLE
    ```powershell
    Remove-MatchedPathsFromCurrentProcessEnvPaths -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the process level env paths.
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    $env_paths = [EnvPaths]::new()
    $IsPattern = $true
    if ($PSCmdlet.ShouldProcess("Remove items that match ``$($Pattern)`` from process level env path",'','')){
        $env_paths.RemoveProcessLevelEnvPaths($Pattern,$IsPattern)
    }
}

function Remove-MatchedPathsFromCurrentUserEnvPaths{
<#
.DESCRIPTION
    Remove matched paths from the current user level env paths.
    Before removing, the function will check and de-duplicate the current user level env paths.
.INPUTS
    A string of pattern.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    ```powershell
    Remove-MatchedPathsFromCurrentUserEnvPaths -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the user level env paths.
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    Assert-IsWindows
    $env_paths = [EnvPaths]::new()
    $IsPattern = $true
    if ($PSCmdlet.ShouldProcess("Remove items that match ``$($Pattern)`` from user level env path",'','')){
        $env_paths.RemoveUserLevelEnvPaths($Pattern,$IsPattern)
    }
}

function Remove-MatchedPathsFromCurrentMachineEnvPaths{
<#
.DESCRIPTION
    Remove matched paths from the current machine level env paths.
    Before removing, the function will check and de-duplicate the current machine level env paths.
.INPUTS
    A string of pattern.
.OUTPUTS
    None.
.NOTES
    Support Windows only.
    Need Administrator privilege.
    See the [doc](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3) for ShouldProcess warnings given by PSScriptAnalyzer.
.EXAMPLE
    ```powershell
    Remove-MatchedPathsFromCurrentMachineEnvPaths -Pattern 'Git'
    # It will remove all the paths that match the pattern 'Git' in the machine level env paths.
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    Assert-IsWindowsAndAdmin
    $env_paths = [EnvPaths]::new()
    $IsPattern = $true
    if ($PSCmdlet.ShouldProcess("Remove items that match ``$($Pattern)`` from machine level env path",'','')){
        $env_paths.RemoveMachineLevelEnvPaths($Pattern,$IsPattern)
    }
}
function Register-FSLEnvForPwsh{
<#
.SYNOPSIS
    Setup FSL environment variables for pwsh as well as FSL's bash settings in .profile
.DESCRIPTION
    FSL is a comprehensive library of analysis tools for FMRI, MRI and diffusion brain imaging data.
    See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/

    This function is used to setup FSL environment variables for pwsh as well as FSL's bash settings in .profile.
    It mimics the following bash settings in .profile:

    ```bash
    # FSL Setup
    FSLDIR=/home/some_user_name/fsl
    PATH=${FSLDIR}/share/fsl/bin:${PATH}
    export FSLDIR PATH
    . ${FSLDIR}/etc/fslconf/fsl.sh
    ```
.INPUTS
    A path string of the FSL directory.
.OUTPUTS
    None.
.NOTES
    When it comes to setup FSL, the official scripts [fslinstaller.py](https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py)
    do not support pwsh, but support bash. It will automatically register procedures in .profile. to setup FSL environment variables.

    If we use pwsh in WSL2 directly, i.e., set pwsh as the default shell in WSL2, we have to mimic all bash settings to maintain corresponding
    components, especially environment variables, including the FSL's bash settings.

    But actually, we usually do not launch pwsh directly, but launch bash first, then call pwsh in bash.
    This priority (launching sequence) is also suitable for using pwsh in VS Code remote.

    The normal launch sequence of bash and its configuration files is:
        bash->.profile(where .bashrc is contained and called once, and append some extra settings.)
    Then, the normal interactive terminal is presented.
    For following  calls of bash, .profile will not be executed, but .bashrc will be executed each time.
    In normal usage, we usually call pwsh after bash is launched. So the FSL environment variables that
    have been set in .profile will be inherited by pwsh.

    So, there is no need to setup FSL environment variables for pwsh again.
    This function is just for a record.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param ([string]$FslDir)
    Assert-IsLinuxOrWSL2
    if ($PSCmdlet.ShouldProcess("Setup FSL for pwsh.",'','')){
        # FSL Setup
        $Env:FSLDIR =  "$FslDir"
        Add-PathToCurrentProcessEnvPaths "${Env:FSLDIR}/share/fsl/bin"

        if (Test-Path "${FSLDIR}/etc/fslversion" ){
            Add-PathToCurrentProcessEnvPaths "${Env:FSLDIR}/share/fsl/bin"
        }
        $Env:FSLOUTPUTTYPE = "NIFTI_GZ"
        $Env:FSLMULTIFILEQUIT = "TRUE"
        $Env:FSLTCLSH = "${Env:FSLDIR}/bin/fsltclsh"
        $Env:FSLWISH = "${Env:FSLDIR}/bin/fslwish"
        $Env:FSLGECUDAQ = "cuda.q"
        $Env:FSL_LOAD_NIFTI_EXTENSIONS = 0
        $Env:FSL_SKIP_GLOBAL = 0
    }
}