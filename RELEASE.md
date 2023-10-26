# Release v0.0.4
## Release v0.0.4-beta0
- Fix the logic bug of function `Assert-IsLinuxOrWSL2`.
- Add a component function `Format-VersionTo4Numbers`.
- Modify the class `EnvPath` for more stability.
- Start to support setting IPv6 DDNS with Aliyun.
- Try to support DNS over HTTPS.

# Release v0.0.3
## Release v0.0.3-stable
- Adjusted the organization of private components to further reduce coupling.
## Release v0.0.3-beta1
- Move the public API function, `Register-FSLEnvForPwsh` to `Assister.ThirdParty.ps1` for better understanding and for further development.
- In the future, the `Assister.ThirdParty*` like files will be used to store all customized assistant APIs for third-party tools. Because these APIs are less of a generalization but indispensable.
- Give out more specific **comments** rules in `README.md`.
- Normalize the **comments** of all APIs and components.
- Use `config.ps1` as a global configuration file for the whole module.

## Release v0.0.3-beta0
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

# Release v0.0.2

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

# Release v0.0.1

A PowerShell module that derives from personal scenarios, can help users configure the Windows PCs easily to realize many useful operations, involving authorization, env, links, proxy, etc. Some features are also available on WSL2 and Linux.

## Features
The main features that have been supported(opted) or remained to do(non-opted) are as:

- [x] Set system-level proxy.
- [x] Set shell (process) level proxy.
- [x] Set/unset environment variables.
- [x] Format path for both Windows and WSL2.
- [x] Deal with authorization problems on the Windows file system.
- [ ] Set DDNS.
- [ ] Configure backup settings with backup tools, such as [FreeFileSync](https://freefilesync.org/download.php).

## APIs
Specifically, all supported public APIs are categorized as follows:
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