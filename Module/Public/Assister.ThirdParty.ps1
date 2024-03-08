function Register-FSLEnvForPwsh{
<#
.SYNOPSIS
    Setup FSL environment variables for pwsh as well as FSL's bash settings in .profile
.DESCRIPTION
    FSL is a comprehensive library of analysis tools for FMRI, MRI and diffusion brain imaging data.
    See the [FSL doc](ttps://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)

    This function is used to setup FSL environment variables for pwsh as well as FSL's bash settings in .profile.
    It mimics the following bash settings in .profile:

    ```bash
    FSL Setup
    FSLDIR=/home/some_user_name/fsl
    PATH=${FSLDIR}/share/fsl/bin:${PATH}
    export FSLDIR PATH
    ${FSLDIR}/etc/fslconf/fsl.sh
    ```

.PARAMETER FslDir
    The FSL installation directory.
.INPUTS
    String.
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

    Only support Linux and WSL2.
.LINK
    [FSL](https://fsl.fmrib.ox.ac.uk)
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$FslDir
        )
    Assert-IsLinuxOrWSL2
    if ($PSCmdlet.ShouldProcess("Setup FSL for pwsh.",'','')){
        # FSL Setup
        $Env:FSLDIR =  "$FslDir"
        Add-PathToCurrentProcessEnvPath "${Env:FSLDIR}/share/fsl/bin"

        if (Test-Path "${FSLDIR}/etc/fslversion" ){
            Add-PathToCurrentProcessEnvPath "${Env:FSLDIR}/share/fsl/bin"
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


function Register-AndBackupEnvItemForConda{
<#
.SYNOPSIS
    Register an item to the current process level environment variable.
    Before registering, the function will backup it into a variable with the same name but 'CONDA_BACK' suffix.
.DESCRIPTION
    The environment variables that associated with a conda environment can be saved in scripts that located
    in `$Env:CONDA_PREFIX/etc/conda/activate.d` and `$Env:CONDA_PREFIX/etc/conda/deactivate.d`.

    Scripts in `activate.d` are executed when the conda environment is activated, and scripts in `deactivate.d`
    are executed when the conda environment is deactivated.
    This mechanism is used to register and unregister temporary environment variables that are only for the current conda environment.
    See https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#saving-environment-variables.

    A traditional way to use this `saving-environment-variables` mechanism is like:
    Backup and register an environment variable in a script in `activate.d`:
    ```pwsh
    $Env:MY_ENV_VAR_CONDA_BACK = $Env:MY_ENV_VAR
    $Env:MY_ENV_VAR = "my_value"
    ```
    And unregister it in a script in `deactivate.d`:
    ```pwsh
    $Env:MY_ENV_VAR = $Env:MY_ENV_VAR_CONDA_BACK
    Remove-Item -Path Env:MY_ENV_VAR_CONDA_BACK
    ```

    This function is used to simplify the backup and register process.
.PARAMETER Name
    The name of the environment variable.
.PARAMETER Value
    The value of the environment variable.
.INPUTS
    String.
    String.
.OUTPUTS
    None.
.LINK
    [Conda | Saving environment variables](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#saving-environment-variables)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Value
        )
    
    if ($PSCmdlet.ShouldProcess("Register and backup the environment variable $Name.",'','')){
        $NameBack = "${Name}_CONDA_BACK"
        [Environment]::SetEnvironmentVariable($NameBack,[Environment]::GetEnvironmentVariable($Name))
        [Environment]::SetEnvironmentVariable($Name, $Value)
    }
}


function Unregister-WithBackupEnvItemForConda{
<#
.SYNOPSIS
    The reverse operation of Register-AndBackupEnvItemForConda.
    Retore an item from the current process level environment variable with the backup,
    and remove the backup.
.DESCRIPTION
    See https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#saving-environment-variables.

    A traditional way to use this `saving-environment-variables` mechanism is like:
    Backup and register an environment variable in a script in `activate.d`:
    ```pwsh
    $Env:MY_ENV_VAR_CONDA_BACK = $Env:MY_ENV_VAR
    $Env:MY_ENV_VAR = "my_value"
    ```
    And unregister it in a script in `deactivate.d`:
    ```pwsh
    $Env:MY_ENV_VAR = $Env:MY_ENV_VAR_CONDA_BACK
    Remove-Item -Path Env:MY_ENV_VAR_CONDA_BACK
    ```

    This function is used to simplify the unregister process.
.PARAMETER Name
    The name of the environment variable.
.INPUTS
    String.
.OUTPUTS
    None.
.LINK
    [Conda | Saving environment variables](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#saving-environment-variables)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$Name
        )
    if ($PSCmdlet.ShouldProcess("Unregister and restore the environment variable $Name.",'','')){
        $NameBack = "${Name}_CONDA_BACK"
        [Environment]::SetEnvironmentVariable($Name,[Environment]::GetEnvironmentVariable($NameBack))
        [Environment]::SetEnvironmentVariable($NameBack, "")
    }
}