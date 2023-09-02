# Release v0.0.2

- Change logging behavior to deal with log file funding problems. 
    - Now it will check the log file's parent directory first. If the parent directory does not exist, it will create the directory before making logs.
    - Change logging path from the module path to the user's home path.
        - Now, all logs will be saved in ${Home}/.log/${ModuleName}/ by default.
        - The original logging path, ${ModulePath}/Logs/ has been deprecated.
        - It is recommended to remove the original logging path manually.
    

# Release v0.0.1

- It supports Windows, Linux and WSL2. 
- It derives from personal scenarios, which can help users configure their Windows PCs easily to realize many useful operations. 

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
- Path Management
    - `Get-GatewayIPV4`
    - `Get-LocalHostIPV4`
    - `Set-SystemProxyIPV4ForCurrentUser`
    - `Remove-SystemProxyIPV4ForCurrentUser`
    - `Set-EnvProxyIPV4ForShellProcess`
    - `Remove-EnvProxyIPV4ForShellProcess`