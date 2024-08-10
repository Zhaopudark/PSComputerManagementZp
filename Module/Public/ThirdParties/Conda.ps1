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
    Retore an item from the current process level environment variable with the backup, and remove the backup.
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