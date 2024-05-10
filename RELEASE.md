# PSComputerManagementZp 0.1.x
## Release 0.1.4
On working...
## Release 0.1.3
- Add `Register-AndBackupEnvItemForConda` and `Unregister-WithBackupEnvItemForConda` in `Assister.ThirdParty.ps1` to help users to register and unregister the environment variables for `Conda` with backup. See [Conda | Saving environment variables](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#saving-environment-variables) and [the source code](https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/Module/Public/Assister.ThirdParty.ps1) for more details.
## Release 0.1.2
- Sorry for that v0.1.1 has been missed.
- Fix some documentation problems.
- Update codecov/codecov-action to v4.
- Apply more strict try-catch mechanism in `Reset-Authorization` function for better stability.

## Release 0.1.0
From the version 0.0.7, this module will use semantic version control formally. And its time to release the first formal version, 0.1.0.
So, we make the version fast forward to 0.1.0

Use semantic version control formally. For this project:
- We consider CI tests as alpha tests. So there is no alpha release.
- Use `z.y.0bn` as the pre-release (beta release) version number.
- Use `z.y.0` as the normal release version number.
- Use `z.y.n`, where `n > 0`, as the patch release version number.

# PSComputerManagementZp 0.0.x
## Release 0.0.7b1
- Prepare for a formal release.
- Prepare for sync to Zenodo.

## Release 0.0.7b0
- Fix some building bugs of this module.

## Release 0.0.6
- Normalize version numbers and status in `RELEASE.md` by Pythonic [Semantic Versioning](https://semver.org/) style as [PEP440](https://peps.python.org/pep-0440/).

## Release 0.0.6b0
- Support [Codecov](https://docs.codecov.com/docs) and add its badge.
- Now, Universal Naming Convention (UNC) paths, such as `\\wsl.localhost\Ubuntu\home\xxx` can be recognized and formatted correctly by `Get-FormattedFileSystemPath` on Windows.
- Risks: To support UNC paths, the class `FormattedFileSystemPath` has been modified. However, it may bring some potential risks because the tests cannot cover all scenarios. So, it is only recommended to use the `Get-FormattedFileSystemPath` function as the testing scenarios in [`Tests\APIs\Class.FormattedFileSystemPath.Tests.ps1`](https://github.com/Zhaopudark/PSComputerManagementZp/blob/main/Tests/APIs/Class.FormattedFileSystemPath.Tests.ps1).

## Release 0.0.5
- Fix some documentation problems.
- Now the 2 classes, `EnvPath` and `FormattedFileSystemPath`, are moved to be public APIs, along with their getting functions, `Get-EnvPath` and `Get-FormattedFileSystemPath`.
    - But for usage, only the getting functions are recommended.
    - Because these 2 classes are not able to be used directly by the syntax `[class_name]` in PowerShell, since the mechanism in [Using](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_using?view=powershell-7.3#module-syntax) and [Classes](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_classes?view=powershell-7.3#importing-classes-from-a-powershell-module).
- Fix installation bugs on WSL2.
- Now the public APIs, `Set-DirSymbolicLinkWithSync` and `Set-FileSymbolicLinkWithSync`, can also be used on non-Windows platforms. 

## Release 0.0.5b0
- Use rotation logs to prevent files from becoming too large.
    - Now, if the log file is larger than 10MB, a new log file will be generated with the identifier `.<index>.`.
    - Allows to keep up to 9 older log files in addition to the latest log file.

- Add public API functions `Register-ProgramIntoTaskScheduler` and `Register-PwshCommandsAsRepetedSchedulerTask` to register tasks into task scheduler.
    - It can help users to register many repeted tasks, such as `DDNS`, `Auto-Backup`, etc.
- Simplify the `DDNS` part of `Examples/README.md` with the new APIs.
- Add public API functions `Get-TempPath`, `Get-SelfInstallDir`, `Get-SelfBuildDir`.
- Change and fix the `tmp` path, which is used across this module, to the system's default temp path by `Get-TempPath`.
    - Now, in Windows, the `tmp` path used across this module is `$Env:TEMP` by default, instead of `C:\temp\` as before. 
- Tweak the organization of public and private APIs for simplification.

## Release 0.0.4

- Modify the underlying implementation of `Add-PathToCurrentProcessEnvPath`, `Add-PathToCurrentUserEnvPath`, and `Add-PathToCurrentMachineEnvPath` and change their default behaviors:
    - Now, by default, they will add the target path to the beginning instead of the end of the `$Env:Path` as before.
    - Now, if given the switch parameter `-IsAppend`, they will add the target path to the end of the `$Env:Path`.
    - Now, if the path already exists in the `$Env:Path`, it will be tweaked (before, it will just be skipped simply) to the beginning or the end of the `$Env:Path` according to `-IsAppend`.

- It may be difficult to support configuring the DNS over HTTPS by PowerShell well. So, this feature has been removed from current plan.

## Release 0.0.4b0
- Fix the logic bug of function `Assert-IsLinuxOrWSL2`.
- Add a component function `Format-VersionTo4Numbers`.
- Modify the class `EnvPath` for more stability.
- Start to support setting IPv6 DDNS with Aliyun.
- Try to support DNS over HTTPS.

## Release 0.0.3
- Adjusted the organization of private components to further reduce coupling.

## Release 0.0.3b1
- Move the public API function, `Register-FSLEnvForPwsh` to `Assister.ThirdParty.ps1` for better understanding and for further development.
- In the future, the `Assister.ThirdParty*` like files will be used to store all customized assistant APIs for third-party tools. Because these APIs are less of a generalization but indispensable.
- Give out more specific **comments** rules in `README.md`.
- Normalize the **comments** of all APIs and components.
- Use `config.ps1` as a global configuration file for the whole module.

## Release 0.0.3b0
- Add support for `MacOS`.
- Rename `Write-FileLogs` to `Write-FileLog` and `Write-Logs` to `Write-Log`.
    - There may be a PSScriptAnalyzer warning:
        ```PowerShell
        WARNING: The cmdlet 'Write-Log' is a cmdlet that is included with PowerShell (version core-6.1.0-windows) whose definition should not be overridden.
        ```
    - But it seem in powershell 7.x, there is no built-in `Write-Log` cmdlet. So, it is safe to ignore this warning.
- Make sure all `Assert-` functions return void.
- Make sure all `Test-` functions return boolean.
- Make sure all `ValidateScript()` use `Test-` functions instead of `Assert-` functions.
- Rename all APIs or components about `xEnvPaths` to `xEnvPath`.
- Add a public API function, `Register-FSLEnvForPwsh`, to register the [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/) environment variables for the current PowerShell session.
- Add a statement about the hard link in `README.md`.
- Modify all file names for a better understanding.
- Add `Export-ModuleMember` in `PSComputerManagementZp.psm1` to restrict the exported APIs. Even though it looks to be duplicated with `*.psd1`, it can used to restrict the exported APIs when someone imports `*.psm1` directly.
- Re-construct `Manager.Links`. Now the APIs about `Link Management` have been shrunk to:
    - `Set-DirSymbolicLinkWithSync`
    - `Set-FileSymbolicLinkWithSync`
    - `Set-DirJunctionWithSync`
    Since the hard link may bring potential problems, this module does not support the hard link's quick creation and synchronization. Do provide `Set-FileHardLinkWithSync` anymore.
- Define a mode for **Version Iteration** and write it into root `README.md`
    - For further development, `RELEASE.md` should have a structure as:
        ```markdown
        # Release v0.0.3
        ## Release v0.0.3-stable
        ## Release v0.0.3-beta0
        ```
- The `README.md` file for all public APIs can be automatically generated now.
- The `README.md` file for all private components can be automatically generated now.

## Release 0.0.2
- Change logging behavior to deal with log file funding problems. 
    - Now it will check the log file's parent directory first. If the parent directory does not exist, it will create the directory before making logs.
    - Change logging path from the module path to the user's home path.
        - Now, all logs will be saved in ${Home}/.log/${ModuleName}/ by default.
        - The original logging path, ${ModulePath}/Logs/ has been deprecated.
        - It is recommended to remove the original logging path manually.
- Change logging functions for easier understanding.
    - The principle is that when making logs, the logs will be written into files anyway. If a log needs to be displayed in the console, it will be done as a `Verbose` message. 
    - The private function `Write-FileLogs` should only be used in the private function `Write-Logs`, and the latter is the only logging function in all components. Also, the latter is not an API function for normal users.

- Re-construct `EnvManagers`. Now the APIs about `Environment Variables Management` have been re-write as:
    - `Merge-RedundantEnvPathsFromCurrentMachineToCurrentUser`
    - `Add-PathToCurrentProcessEnvPaths`
    - `Add-PathToCurrentUserEnvPaths`
    - `Add-PathToCurrentMachineEnvPaths`
    - `Remove-PathFromCurrentProcessEnvPaths`
    - `Remove-PathFromCurrentUserEnvPaths`
    - `Remove-PathFromCurrentMachineEnvPaths`
    - `Remove-MatchedPathsFromCurrentProcessEnvPaths`
    - `Remove-MatchedPathsFromCurrentUserEnvPaths`
    - `Remove-MatchedPathsFromCurrentMachineEnvPaths`

## Release 0.0.1
A PowerShell module that derives from personal scenarios, can help users configure the Windows PCs easily to realize many useful operations, involving authorization, env, links, proxy, etc. Some features are also available on WSL2 and Linux.

- Features: The main features that have been supported(opted) or remained to do(non-opted) are as:
    - [x] Set system-level proxy.
    - [x] Set shell (process) level proxy.
    - [x] Set/unset environment variables.
    - [x] Format path for both Windows and WSL2.
    - [x] Deal with authorization problems on the Windows file system.
    - [ ] Set DDNS.
    - [ ] Configure backup settings with backup tools, such as [FreeFileSync](https://freefilesync.org/download.php).

- APIs: Specifically, all supported public APIs are categorized as follows:
    - Authorization Management
        - `Reset-Authorization`
    - Environment Variables Management
        - `Merge-RedundantEnvPathFromLocalMachineToCurrentUser`
        - `Add-EnvPathToCurrentProcess`
        - `Remove-EnvPathByPattern`
        - `Remove-EnvPathByTargetPath`
    - Link Management
        - `Set-DirSymbolicLinkWithSync`
        - `Set-FileSymbolicLinkWithSync`
        - `Set-DirJunctionWithSync`
        - `Set-FileHardLinkWithSync`
    - Proxy Management
        - `Get-GatewayIPV4`
        - `Get-LocalHostIPV4`
        - `Set-SystemProxyIPV4ForCurrentUser`
        - `Remove-SystemProxyIPV4ForCurrentUser`
        - `Set-EnvProxyIPV4ForShellProcess`
        - `Remove-EnvProxyIPV4ForShellProcess`