All `private Components` are recorded here. (Only for Contributors)
## Classes
## Functions
### Assert-AdminPermission
    
- **Description**

    Assert if the current process is in AdminPermission.
- **Inputs**

    None.
- **Outputs**

    None.
    
### Assert-AdminRobocopyAvailable
    
- **Description**

    Assert the robocopy command is available.
    Assert if the current platform is Windows.
    Assert if the current process is in AdminPermission
- **Inputs**

    None.
- **Outputs**

    None.
    
### Assert-AliyunCLIAvailable
    
- **Description**

    Assert the robocopy command is available.
    Assert if the current platform is Windows.
    Assert if the current process is in AdminPermission
- **Inputs**

    None.
- **Outputs**

    None.
    
### Assert-IsLinuxOrWSL2
    
- **Description**

    Assert if the current platform is Linux or Wsl2.
- **Inputs**

    None.
- **Outputs**

    None.
    
### Assert-IsWindows
    
- **Description**

    Assert if the current platform is Windows.
- **Inputs**

    None.
- **Outputs**

    None.
    
### Assert-IsWindowsAndAdmin
    
- **Description**

    Assert if the current platform is Windows and the current process is in AdminPermission.
- **Inputs**

    None.
- **Outputs**

    None.
    
### Assert-IsWindowsAndAdminIfOnWindows
    
- **Description**

    Assert if the current platform is Windows and the current process is in AdminPermission.
- **Inputs**

    None.
- **Outputs**

    None.
    
### Assert-ValidPath4Authorization
    
- **Synopsis**

    Check if a path is valid as the rule defined in the [post](https://little-train.com/posts/ebaccba2.html).
- **Description**

    Check if $Path is valid as the rule defined in the [post](https://little-train.com/posts/ebaccba2.html).
    Only the following 4 types of paths are valid:
    1. root path of Non-system disk
    2. other path in Non-system disk
    3. path of ${Home}
    4. other path in ${Home}
- **Parameter** `$Path`

    The path to be checked.
- **Inputs**

    String or FormattedFileSystemPath.
- **Outputs**

    None.
- **Link**

    [Authorization](https://little-train.com/posts/ebaccba2.html).
    
### Copy-DirWithBackup
    
- **Description**

    Copy a simple directory to a destination.
    If the destination exists, the source directory will be merged to the destination directory.
    Before the merging, both the source and destination will be backup to a directory.
- **Parameter** `$Path`

    The source directory path.
- **Parameter** `$Destination`

    The destination directory path.
- **Parameter** `$BackupDir`

    The backup directory path.
- **Parameter** `$Indicator`

    The indicator string to indicate the backup directory.
- **Inputs**

    String or FormattedFileSystemPath.
    String.
    String or FormattedFileSystemPath.
    String.
- **Outputs**

    None.
- **Notes**

    Only support a simple directory.
    Do not support a file, a directory symbolic link, or a junction point.
    Try Robocopy first, if failed, use Copy-Item instead. But Copy-Item will loss the metadata of directories in the source.
    Patched to avoid Copy-Item's ambiguity:
    If the destination is existing, Copy-Item will merge the source to the destination. (Items within the source will be copied and to the destination, covering the existing items with the same name.)
    If the destination is non-existing, Copy-Item will create a new directory with the source's name.
    
    Refer to the [doc](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy) for more information about Copy-Item.
    |Robocopy args| effections|
    |---|---|
    | /e | Copies subdirectories. This option automatically includes empty directories.|
    | /copyall | Copies all file information (equivalent to /copy:DATSOU).|
    | /dcopy:DATE | Specifies what to copy in directories. D-Data A-Attributes T-Time stamps E-Extended attribute|
    | /log+:<logfile> | Writes the status output to the log file (appends the output to the existing log file).|
- **Link**

    [Type assignment/converting](https://stackoverflow.com/a/77062276/17357963).
    [Robocopy](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy).
    
### Copy-FileWithBackup
    
- **Description**

    Copy a simple file to a destination. If the destination exists, the source file will cover the destination file. Before the covering, the destination file will be backup to a directory.
- **Parameter** `$Path`

    The source file path.
- **Parameter** `$Destination`

    The destination file path.
- **Parameter** `$BackupDir`

    The backup directory path.
- **Parameter** `$Indicator`

    The indicator string to indicate the backup file.
- **Inputs**

    String or FormattedFileSystemPath.
    String.
    String or FormattedFileSystemPath.
    String.
- **Outputs**

    None.
- **Notes**

    Only support a simple file.
    Do not support a directory, a file symbolic link, or a hard link.
- **Link**

    [Type assignment/converting](https://stackoverflow.com/a/77062276/17357963).
    
### Format-Doc2Markdown
    
- **Description**

    Convert a function doc to markdown string with a fixed format.
- **Notes**

    The formatted markdown string is like this:
    ```markdown
    - Synopsis
    
    xxx
    - Description
    
    xxx
    - Parameters `$Aa`
    
    xxx
    - Parameters `$Bb`
    
    xxx
    ```
- **Inputs**

    String.
- **Outputs**

    String.
    
### Get-ClassDoc
    
- **Description**

    Get class docs from a script file.
    Return a hashtable with class names as keys and class docs as values.
- **Inputs**

    String.
- **Outputs**

    Hashtable.
    
### Get-CurrentLogFileNameInRotatingList
    
- **Description**

    Get the current log file name in a fixed and internal rotating list.
    The current (target) log file is the one that is the most recently modified and whose size is less than 10MB.
- **Inputs**

    None.
- **Outputs**

    String.
    
### Get-DefaultSddl
    
- **Synopsis**

    Get the default SDDL of a specific path type that defined in `Get-PathType`.
- **Description**

    Get the default SDDL of the `$PathType`.
    The relationship between the `$PathType` and its default SDDL are the following mappings:
    | Type                                            | SDDL                                                         |
    | ----------------------------------------------- | ------------------------------------------------------------ |
    | `NonSystemDisk[NTFS]\Root`                      | `O:SYG:SYD:AI(A;OICIIO;SDGXGWGR;;;AU)(A;;0x1301bf;;;AU)(A;;FA;;;SY)(A;OICIIO;GA;;;SY)(A;OICIIO;GA;;;BA)(A;;FA;;;BA)(A;;0x1200a9;;;BU)(A;OICIIO;GXGR;;;BU)` |
    | `NonSystemDisk[ReFS]\Root`                      | `O:BAG:SYD:AI(A;OICIIO;SDGXGWGR;;;AU)(A;;0x1301bf;;;AU)(A;OICIIO;GA;;;SY)(A;;FA;;;SY)(A;OICI;FA;;;BA)(A;;0x1200a9;;;BU)(A;OICIIO;GXGR;;;BU)` |
    | `Home\Root`                                     | `O:BAG:SYD:PAI(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;FA;;;${UserSid})` |
    | `NonSystemDisk[NTFS]\System Volume Information` | `O:BAG:SYD:PAI(A;OICI;FA;;;SY)`                              |
    | `NonSystemDisk[NTFS]\$Recycle.Bin`              | `O:${UserSid}G:${UserSid}D:PAI(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;;0x1201ad;;;BU)` |
    | `NonSystemDisk[ReFS]\System Volume Information` | `O:BAG:SYD:PAI(A;OICI;FA;;;SY)`                              |
    | `NonSystemDisk[ReFS]\$Recycle.Bin`              | `O:${UserSid}G:${UserSid}D:PAI(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;;0x1201ad;;;BU)` |
    | `Home\Directory`                                | `O:${UserSid}G:${UserSid}D:AI(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;FA;;;${UserSid})` |
    | `Home\SymbolicLinkDirectory`                    | `O:BAG:${UserSid}D:AI(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;FA;;;${UserSid})` |
    | `Home\Junction`                                 | `O:${UserSid}G:${UserSid}D:AI(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;FA;;;${UserSid})` |
    | `NonSystemDisk[NTFS]\Directory`                 | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;ID;FA;;;BA)(A;OICIIOID;GA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)` |
    | `NonSystemDisk[NTFS]\SymbolicLinkDirectory`     | `O:BAG:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;ID;FA;;;BA)(A;OICIIOID;GA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)` |
    | `NonSystemDisk[NTFS]\Junction`                  | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;ID;FA;;;BA)(A;OICIIOID;GA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)` |
    | `NonSystemDisk[ReFS]\Directory`                 | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;OICIID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)` |
    | `NonSystemDisk[ReFS]\SymbolicLinkDirectory`     | `O:BAG:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;OICIID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)` |
    | `NonSystemDisk[ReFS]\Junction`                  | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;OICIID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)` |
    | `Home\desktop.ini`                              | `O:${UserSid}G:${UserSid}D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;FA;;;${UserSid})` |
    | `Home\SymbolicLinkFile`                         | `O:BAG:${UserSid}D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;FA;;;${UserSid})` |
    | `Home\File`                                     | `O:${UserSid}G:${UserSid}D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;FA;;;${UserSid})` |
    | `Home\HardLink`                                 | `O:${UserSid}G:${UserSid}D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;FA;;;${UserSid})` |
    | `NonSystemDisk[NTFS]\desktop.ini`               | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)` |
    | `NonSystemDisk[NTFS]\SymbolicLinkFile`          | `O:BAG:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)` |
    | `NonSystemDisk[NTFS]\File`                      | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)` |
    | `NonSystemDisk[NTFS]\HardLink`                  | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)` |
    | `NonSystemDisk[ReFS]\desktop.ini`               | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)` |
    | `NonSystemDisk[ReFS]\SymbolicLinkFile`          | `O:BAG:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)` |
    | `NonSystemDisk[ReFS]\File`                      | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)` |
    | `NonSystemDisk[ReFS]\HardLink`                  | `O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)` |
    
    where, `$UserSid = (Get-LocalUser -Name ([Environment]::UserName)).SID.Value`.
    All `SDDLs` are from a origin installed native system, so we can ensure it is in the default state.
    
- **Parameter** `$PathType`

    The path type to be checked.
- **Inputs**

    String.
- **Outputs**

    String or Null.
- **Link**

    [Authorization](https://little-train.com/posts/ebaccba2.html)
    
### Get-FunctionDoc
    
- **Description**

    Get function docs from a script file.
    Return a hashtable with function names as keys and function docs as values.
- **Inputs**

    String.
- **Outputs**

    Hashtable.
    
### Get-LogFileNameWithKeyInfo
    
- **Description**

    Get the log file name according the key info, pre-defined `$LoggingPath` and pre-defined `$ModuleVersion`.
- **Parameter** `$KeyInfo`

    A string to indicate the key info of the log file name.
- **Inputs**

    String.
- **Outputs**

    String.
    
### Get-PathType
    
- **Synopsis**

    Get a customized path type of a fileSystem path(disk, directory, file, link, etc.), according to the `Types of Items` described in the [post](https://little-train.com/posts/ebaccba2.html).
- **Description**

    Basing on [`New-Item -ItemType`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.2#-itemtype), this function defines 38 types of items, including the 28 types of items that defined in the [post](https://little-train.com/posts/ebaccba2.html).
    
    | Types Description                                 | Path Example                          |
    | -----------------------------------------------   | --------------------------------------|
    | `NonSystemDisk[NTFS]\Root`                        | `X:\`                                 |
    | `NonSystemDisk[ReFS]\Root`                        | `X:\`                                 |
    | `NonSystemDisk[FAT32]\Root`                       | `X:\`                                 |
    | `Home\Root`                                       | `${Home}\`                            |
    | `NonSystemDisk[NTFS]\System Volume Information`   | `X:\System Volume Information\`       |
    | `NonSystemDisk[ReFS]\System Volume Information`   | `X:\System Volume Information\`       |
    | `NonSystemDisk[FAT32]\System Volume Information`  | `X:\System Volume Information\`       |
    | `NonSystemDisk[NTFS]\$Recycle.Bin`                | `X:\$Recycle.Bin\`                    |
    | `NonSystemDisk[ReFS]\$Recycle.Bin`                | `X:\$Recycle.Bin\`                    |
    | `NonSystemDisk[FAT32]\$Recycle.Bin`               | `X:\$Recycle.Bin\`                    |
    | `Home\Directory`                                  | `${Home}\*some_nomrmal_dir\`          |
    | `Home\SymbolicLinkDirectory`                      | `${Home}\*some_symbolic_link_dir\`    |
    | `Home\Junction`                                   | `${Home}\*some_junction\`             |
    | `NonSystemDisk[NTFS]\Directory`                   | `X:\*some_nomrmal_dir\`               |
    | `NonSystemDisk[ReFS]\Directory`                   | `X:\*some_nomrmal_dir\`               |
    | `NonSystemDisk[FAT32]\Directory`                  | `X:\*some_nomrmal_dir\`               |
    | `NonSystemDisk[NTFS]\SymbolicLinkDirectory`       | `X:\*some_symbolic_link_dir\`         |
    | `NonSystemDisk[ReFS]\SymbolicLinkDirectory`       | `X:\*some_symbolic_link_dir\`         |
    | `NonSystemDisk[FAT32]\SymbolicLinkDirectory`      | `X:\*some_symbolic_link_dir\`         |
    | `NonSystemDisk[NTFS]\Junction`                    | `X:\*some_junction\`                  |
    | `NonSystemDisk[ReFS]\Junction`                    | `X:\*some_junction\`                  |
    | `NonSystemDisk[FAT32]\Junction`                   | `X:\*some_junction\`                  |
    | `Home\desktop.ini`                                | `${Home}\*desktop.ini`                |
    | `Home\SymbolicLinkFile`                           | `${Home}\*some_symbolic_link_file`    |
    | `Home\File`                                       | `${Home}\*some_normal_file`           |
    | `Home\HardLink`                                   | `${Home}\*some_hardlink`              |
    | `NonSystemDisk[NTFS]\desktop.ini`                 | `X:\*desktop.ini`                     |
    | `NonSystemDisk[ReFS]\desktop.ini`                 | `X:\*desktop.ini`                     |
    | `NonSystemDisk[FAT32]\desktop.ini`                | `X:\*desktop.ini`                     |
    | `NonSystemDisk[NTFS]\SymbolicLinkFile`            | `X:\*some_symbolic_link_file`         |
    | `NonSystemDisk[ReFS]\SymbolicLinkFile`            | `X:\*some_symbolic_link_file`         |
    | `NonSystemDisk[FAT32]\SymbolicLinkFile`           | `X:\*some_symbolic_link_file`         |
    | `NonSystemDisk[NTFS]\File`                        | `X:\*some_normal_file`                |
    | `NonSystemDisk[ReFS]\File`                        | `X:\*some_normal_file`                |
    | `NonSystemDisk[FAT32]\File`                       | `X:\*some_normal_file`                |
    | `NonSystemDisk[NTFS]\HardLink`                    | `X:\*some_hardlink`                   |
    | `NonSystemDisk[ReFS]\HardLink`                    | `X:\*some_hardlink`                   |
    | `NonSystemDisk[FAT32]\HardLink`                   | `X:\*some_hardlink`                   |
    
    Here `NonSystemDisk[NTFS/ReFS/FAT32]` means, `X` is not system disk drive letter and `X:\` is in one of NTFS/ReFS/FAT32 file system. When output, a spcific file system will be shown, such as `NonSystemDisk[NTFS]`. Here `Home` means be or in `${Home}` directory.
    
    Actually, some paths have a hierarchical relationship and can belong to both types as the above, and we return only the first type recognized in the above order. That is to say, the above shown order is the key to identify all customized path types.
    
- **Parameter** `$Path`

    The path to be checked to get its type.
    
- **Parameter** `$SkipPlatformCheck`

    Switch to disable platform check at the beginning.
    If true(given), the platform will not be checked at the beginning.
    
- **Parameter** `$SkipPathCheck`

    Switch to disable path check at the beginning.
    If true(given), the path will not be checked at the beginning.
- **Inputs**

    String or FormattedFileSystemPath.
- **Outputs**

    String or Null.
- **Link**

    [`New-Item -ItemType`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.2#-itemtype),
    [Authorization](https://little-train.com/posts/ebaccba2.html)
    
### Get-SortedNameWithDocFromScript
    
- **Description**

    Get sorted function names with docs from a script file or script files.
    Return a hashtable enumerator with sorted function names as keys(names) and function docs as values.
- **Parameter** `$Path`

    The path of a script file or script files.
- **Parameter** `$DocType`

    The type of docs, 'Function' or 'Class'.
- **Inputs**

    String[].
    String.
- **Outputs**

    System.Collections.DictionaryEntry.
- **Link**

    [Why both `Name` and `Key` are available?](https://stackoverflow.com/a/77083569/17357963)
    [Types.ps1xml](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_types.ps1xml?view=powershell-7.3)
    
### Move-Target2Source4SoftLink
    
- **Synopsis**

    Fro some purposes about setting a soft link (symbolic link or junction point), move the target item to the source, if the target and the source meet some conditions.
    Backup can be conducted when needed.
    Then the target item will be removed, along with some post-processing procedures.
- **Description**

    When we want to set a soft link (symbolic link or junction point) from `A` to `B`, as $A\rightarrow B$, we may find that `A` is non-existing while `B` is existing.
    That is not our expectation. We may need to move `B` to `A` at first, then go back to set the link $A\rightarrow B$.
    
    Worsely, if we find `A` and `B` are both existing at first, we may need to consider merging or backuping procedures.
    
    This function can help users to do the above things easily, i.e., it can move the target item to the source automatically, with essential backup.
    It can be used before setting a soft link from the source to the target.
- **Parameter** `$Target`

    The target item path.
- **Parameter** `$Source`

    The source item path.
- **Parameter** `$BackupDir`

    The backup directory path.
- **Inputs**

    String.
    String.
    String or FormattedFileSystemPath.
- **Outputs**

    None.
- **Notes**

    This function is not generic and is more of an integration for a class of business.
    The following are the main rules of this function:
    
    **First**, check the target and source path if they are both in the following conditions:
    
    1. non-existing
    2. existing-simple-file
    3. existing-simple-directory
    4. existing-file-symbolic-link
    5. existing-directory-symbolic-link
    6. existing-directory-junction-point
    
    **Second**, there are 6*6=36 combinations of the target and source path. For each combination, we have a specific operation:
    
    |Conditions  |Target                            | Source                    | Opeartion|
    |------------|----------------------------------|---------------------------|----------|
    |1           | non-existing                     | non-existing              | throw error|
    |1           | non-existing                     | existing-simple-file      | pass(do nothing)|
    |1           | non-existing                     | existing-simple-directory | pass(do nothing)|
    |3           | non-existing                     | one of the 3 link types   | throw error|
    |1           | existing-simple-file             | non-existing              | copy target to source, del target|
    |1           | existing-simple-file             | existing-simple-file      | backup source, copy target to cover source, del target|
    |1           | existing-simple-file             | existing-simple-directory | throw error|
    |3           | existing-simple-file             | one of the 3 link types   | throw error|
    |1           | existing-simple-directory        | non-existing              | copy target to source, del target|
    |1           | existing-simple-directory        | existing-simple-file      | throw error|
    |1           | existing-simple-directory        | existing-simple-directory | backup source, backup target, merge target to source (items within target will cover), del target|
    |3           | existing-simple-directory        | one of the 3 link types   | throw error|
    |1           | existing-file-symbolic-link      | non-existing              | throw error|
    |1           | existing-file-symbolic-link      | existing-simple-file      | del target |
    |1           | existing-file-symbolic-link      | existing-simple-directory | throw error|
    |3           | existing-file-symbolic-link      | one of the 3 link types   | throw error|
    |1           | existing-directory-symbolic-link | non-existing              | throw error|
    |1           | existing-directory-symbolic-link | existing-simple-file      | throw error|
    |1           | existing-directory-symbolic-link | existing-simple-directory | del target|
    |3           | existing-directory-symbolic-link | one of the 3 link types   | throw error|
    |1           | existing-directory-junction-point| non-existing              | throw error|
    |1           | existing-directory-junction-point| existing-simple-file      | throw error|
    |1           | existing-directory-junction-point| existing-simple-directory | del target|
    |3           | existing-directory-junction-point| one of the 3 link types   | throw error|
    
    The other conditions out of the above 36 conditions will throw error as well.
- **Link**

    [Type assignment/converting](https://stackoverflow.com/a/77062276/17357963).
    
### Reset-PathAttribute
    
- **Synopsis**

    Reset the attributes of a path to the original status, when the path matches one of the special path types that are defined in this function.
    
- **Description**

    Reset the attributes of $Path to the original status, when it matches one of the following 8 types (appended with corresponding standard attriibuts):
    
    | Type      | Specific Path Example           | Default Attributes        |
    | --------- | ------------------------------- | ------------------------- |
    | Directory | `X:\ `                          | Hidden, System, Directory |
    | Directory | `X:\System Volume Information\` | Hidden, System, Directory |
    | Directory | `X:\$Recycle.Bin\`              | Hidden, System, Directory |
    | Directory | `X:\*some_symbolic_link_dir\`   | Directory, ReparsePoint   |
    | Directory | `X:\*some_junction\`            | Directory, ReparsePoint   |
    | File      | `X:\*desktop.ini`               | Hidden, System, Archive   |
    | File      | `X:\*some_symbolic_link_file`   | Archive, ReparsePoint     |
    | File      | `X:\*some_hardlink`             | Archive                   |
    
    Here the `X` represents any drive disk letter. And, if `X` represents the system disk drive letter, the path should only be or in `${Home}`.
    Other directories' attributes will not be reset. And other files' attributes will not be reset. See the [post](https://little-train.com/posts/ebaccba2.html) for more details.
    
    Many (perhaps all) attributes can be find by `[enum]::GetValues([System.IO.FileAttributes])`:
    ```powershell
    ReadOnly, Hidden, System, Directory, Archive, Device,
    Normal, Temporary, SparseFile, ReparsePoint, Compressed,
    Offline, NotContentIndexed, Encrypted, IntegrityStream, NoScrubData.
    ```
    
    We can use the command `Set-ItemProperty $Path -Name Attributes -Value $some_attributes`. But `$some_attributes` can only support `Archive, Hidden, Normal, ReadOnly, or System` and their permutations.
    
    So, to reset the attributes to standard status, we cannot directly give the target attributes, but use a specific `$some_attributes`.
    
- **Parameter** `$Path`

    The path to be checked to reset its attributes.
    
- **Parameter** `$SkipPlatformCheck`

    Switch to disable platform check at the beginning.
    If true(given), the platform will not be checked at the beginning.
    
- **Parameter** `$SkipPathCheck`

    Switch to disable path check at the beginning.
    If true(given), the path will not be checked at the beginning.
- **Inputs**

    String or FormattedFileSystemPath.
- **Outputs**

    None.
- **Component**

    To set the attributes of `$Path`:
    
    ```powershell
    Set-ItemProperty $Path -Name Attributes -Value $some_attributes
    ```
- **Link**

    [Authorization](https://little-train.com/posts/ebaccba2.html)
    
### Test-AdminPermission
    
- **Description**

    Test if the current process is in AdminPermission.
- **Inputs**

    None.
- **Outputs**

    Boolean.
    
### Test-IsWSL2
    
- **Description**

    Test if the current platform is Wsl2.
- **Inputs**

    None.
- **Outputs**

    Boolean.
    
### Test-Platform
    
- **Description**

    Test if the current platform is compatible with the arg `$Name`.
    Currently, it only support Windows, MacOS, Linux and Wsl2.
    If `$Verbose` is given, it will show the result.
- **Parameter** `$Name`

    The platform name to be tested.
- **Parameter** `$Verbose`

    Whether to show the result.
- **Example**

    Test-Platform -Name 'Windows' -Verbose
    Test-Platform -Name 'Wsl2' -Verbose
    Test-Platform -Name 'Linux' -Verbose
    Test-Platform -Name 'MacOS' -Verbose
- **Inputs**

    String.
- **Outputs**

    Boolean.
- **Link**

    [Automatic Variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.3&viewFallbackFrom=powershell-6#islinux) for `$IsWindows` and `$IsLinux`.
    
### Write-FileLog
    
- **Description**

    Write log to a file.
- **Parameter** `$Message`

    The message to be logged.
- **Inputs**

    String.
- **Outputs**

    None.
- **Notes**

    If the log file does not exist, it will be created automatically. But the creation results will be muted to avoid some errors about bool function's return value.
    
### Write-Log
    
- **Description**

    Can write log to a file and output to the console simultaneously.
    Logging to a file is the default behavior.
    Logging to the console is an optional behavior, which can be controlled by the switch parameter `$ShowVerbose`.
- **Parameter** `$Message`

    The message to be logged.
- **Parameter** `$ShowVerbose`

    Whether to show the message to the console in verbose mode.
- **Inputs**

    String.
- **Outputs**

    None.
    
