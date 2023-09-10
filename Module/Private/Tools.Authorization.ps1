function Assert-ValidPath4AuthorizationTools{
<#
.SYNOPSIS
    Check if a path is valid as the rule defined in the [post](https://little-train.com/posts/7fdde8eb.html).

.DESCRIPTION
    Check if $Path is valid as the rule defined in the [post](https://little-train.com/posts/7fdde8eb.html).
    Only the following 4 types of paths are valid:
        1. root path of Non-system disk
        2. other path in Non-system disk
        3. path of ${Home}
        4. other path in ${Home}
.LINK
    Refer to the [post](https://little-train.com/posts/7fdde8eb.html) for more details.
#>
    param(
        [FormattedFileSystemPath]$Path
    )
    if ($Path.IsInSystemVolumeInfo){
        throw "[Unsupported path] The $Path should not in System Volume Information."
    }
    if ($Path.IsInRecycleBin){
        throw "[Unsupported path] The $Path should not in `$Recycle.Bin."
    }
    if (($Path.IsBeOrInSystemDrive)-and !($Path.IsInHome) -and !($Path.IsHome)) {
        throw "[Unsupported path] If $Path is in SystemDisk, it should be or in `${Home}: ${Home}."
    }
    Write-Log "[Supported path] $Path"
}

function Reset-PathAttribute{
<#
.SYNOPSIS
    Reset the attributes of a path to the original status, when the path matches one of
    the special path types that are defined in this function.

.DESCRIPTION
    Reset the attributes of $Path to the original status, when it matches one of the following 8 types
    (appended with corresponding standard attriibuts):

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
    Other directories' attributes will not be reset. And other files' attributes will not be reset.

    See the [post](https://little-train.com/posts/7fdde8eb.html) for more details.

    Many (perhaps all) attributes can be find by `[enum]::GetValues([System.IO.FileAttributes])`:
    ```powershell
    ReadOnly, Hidden, System, Directory, Archive, Device,
    Normal, Temporary, SparseFile, ReparsePoint, Compressed,
    Offline, NotContentIndexed, Encrypted, IntegrityStream, NoScrubData.
    ```

    We can use the command `Set-ItemProperty $Path -Name Attributes -Value $some_attributes`. But `$some_attributes` can only support `Archive, Hidden, Normal, ReadOnly, or System` and their permutations.
    So, to reset the attributes to standard status, we cannot directly give the target attributes, but use a specific `$some_attributes`.

.PARAMETER Path
    The path to be checked to reset its attributes.

.PARAMETER SkipPlatformCheck
    Switch to disable platform check at the beginning.
    If true(given), the platform will not be checked at the beginning.

.PARAMETER SkipPathCheck
    Switch to disable path check at the beginning.
    If true(given), the path will not be checked at the beginning.
.OUTPUTS
    None.

.COMPONENT
    To set the attributes of `$Path`:

    ```powershell
    Set-ItemProperty $Path -Name Attributes -Value $some_attributes
    ```
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [FormattedFileSystemPath]$Path,
        [switch]$SkipPlatformCheck,
        [switch]$SkipPathCheck
    )

    if (-not $SkipPlatformCheck){
        Assert-IsWindows
    }
    if (-not $SkipPathCheck){
        Assert-ValidPath4AuthorizationTools $Path
    }

    if($PSCmdlet.ShouldProcess("$Path",'reset the attributes')){
        if($Path.IsDir){
            if($Path.IsDriveRoot -or $Path.IsSystemVolumeInfo -or $Path.IsRecycleBin){
                Set-ItemProperty $Path -Name Attributes -Value "Hidden, System" -ErrorAction Continue # becasuse there usually some strange original privileges
            }elseif($Path.IsSymbolicLink -or $Path.IsJunction){
                Set-ItemProperty $Path -Name Attributes -Value "Normal"
            }else{
                # $null
            }
        }elseif ($Path.IsFile) {
            if($Path.IsDesktopINI){
                Set-ItemProperty $Path -Name Attributes -Value "Hidden, System, Archive"
            }elseif($Path.IsSymbolicLink -or $Path.IsHardLink){
                Set-ItemProperty $Path -Name Attributes -Value "Archive"
            }else{
                # $null
            }
        }else{
            throw "The $Path is not supported."
        }
    }
}


function Get-PathType{
<#
.SYNOPSIS
    Get a customized path type of a fileSystem path(disk, directory, file, link, etc.), according to the `Types of Items` described in the [post](https://little-train.com/posts/7fdde8eb.html).
.DESCRIPTION
    Basing on [`New-Item -ItemType`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.2#-itemtype),
    this function defines 38 types of items, including the 28 types of items that defined in the [post](https://little-train.com/posts/7fdde8eb.html).

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
    
    Here `NonSystemDisk[NTFS/ReFS/FAT32]` means, `X` is not system disk drive letter and `X:\` is in one of NTFS/ReFS/FAT32 file system.
    When output, a spcific file system will be shown, such as `NonSystemDisk[NTFS]`.
    Here `Home` means be or in `${Home}` directory.

    Actually, some paths have a hierarchical relationship and can belong to both types as the above, and we return only the first type recognized in the above order.
    That is to say, the above shown order is the key to identify all customized path types.

.PARAMETER Path
    The path to be checked to get its type.

.PARAMETER SkipPlatformCheck
    Switch to disable platform check at the beginning.
    If true(given), the platform will not be checked at the beginning.

.PARAMETER SkipPathCheck
    Switch to disable path check at the beginning.
    If true(given), the path will not be checked at the beginning.

.OUTPUTS
    `[System.String]` if `$Path` can be recognized as a customized path type.
    `$null` when error or the`$Path` cannot be recognized as a customized path type.
#>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [FormattedFileSystemPath]$Path,
        [switch]$SkipPlatformCheck,
        [switch]$SkipPathCheck
    )
    if (-not $SkipPlatformCheck){
        Assert-IsWindows
    }
    if (-not $SkipPathCheck){
        Assert-ValidPath4AuthorizationTools $Path
    }
    if ($Path.IsInHome -or $Path.IsHome){
        $header = "Home"
    }
    elseif ($Path.DriveFormat -eq "NTFS"){
        $header = "NonSystemDisk[NTFS]"
    }
    elseif ($Path.DriveFormat -eq "ReFS"){
        $header = "NonSystemDisk[ReFS]"
    }
    elseif($Path.DriveFormat -eq "FAT32"){
        $header = "NonSystemDisk[FAT32]"
    }
    else {
        Write-Log "The $Path is not in home or has unsupported file system type: $($Path.DriveFormat)."
        return $null
    }

    if ($Path.IsDir){
        if (($Path.IsHome) -or ($Path.IsDriveRoot)){
            return  "$header\Root"
        }
        elseif($Path.IsSystemVolumeInfo){
            return  "$header\System Volume Information"
        }
        elseif($Path.IsRecycleBin){
            return "$header\`$Recycle.Bin"
        }
        elseif($Path.IsInSystemVolumeInfo){
            Write-Log "The $Path should not be in System Volume Information."
            return $null
        }
        elseif($Path.IsInRecycleBin){
            Write-Log "The $Path should not be in `$Recycle.Bin."
            return $null
        }
        elseif ($Path.IsSymbolicLink) {
            return "$header\SymbolicLinkDirectory"
        }
        elseif ($Path.IsJunction) {
            return "$header\Junction"
        }
        else{
            return "$header\Directory"
        }
    }
    elseif($Path.IsFile){
        if ($Path.IsDesktopINI){
            return "$header\desktop.ini"
        }
        elseif ($Path.IsHardLink){
            return "$header\HardLink"
        }
        elseif ($Path.IsSymbolicLink){
            return "$header\SymbolicLinkFile"
        }
        else{
            return "$header\File"
        }
    }
    else{
        Write-Log "The $Path is not supported."
        return $null
    }
}

function Get-DefaultSddl{
<#
.SYNOPSIS
    Get the default SDDL of a specific path type that defined in `Get-PathType`.
.DESCRIPTION
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

.PARAMETER PathType
    The path type to be checked.

.OUTPUTS
    `[System.String]` to represtent a SDDL if the `$PathType` is involved in above mappings.
    `$null` if the `$PathType` is not involved in above mappings.
#>
    [CmdletBinding()]
    param(
        [string]$PathType
    )
    # $PathType = Get-PathType -Path $Path
    $UserSid = (Get-LocalUser -Name ([Environment]::UserName)).SID.Value
    switch ($PathType) {
        "NonSystemDisk[NTFS]\Root"{
            $Sddl = "O:SYG:SYD:AI(A;OICIIO;SDGXGWGR;;;AU)(A;;0x1301bf;;;AU)(A;;FA;;;SY)(A;OICIIO;GA;;;SY)(A;OICIIO;GA;;;BA)(A;;FA;;;BA)(A;;0x1200a9;;;BU)(A;OICIIO;GXGR;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\Root"{
            $Sddl = "O:BAG:SYD:AI(A;OICIIO;SDGXGWGR;;;AU)(A;;0x1301bf;;;AU)(A;OICIIO;GA;;;SY)(A;;FA;;;SY)(A;OICI;FA;;;BA)(A;;0x1200a9;;;BU)(A;OICIIO;GXGR;;;BU)"
            break
        }
        "Home\Root"{
            $Sddl = "O:BAG:SYD:PAI(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;FA;;;${UserSid})"
            break
        }
        "NonSystemDisk[NTFS]\System Volume Information"{
            $Sddl = "O:BAG:SYD:PAI(A;OICI;FA;;;SY)"
            break
        }
        "NonSystemDisk[NTFS]\`$Recycle.Bin"{
            $Sddl = "O:${UserSid}G:${UserSid}D:PAI(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;;0x1201ad;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\System Volume Information"{
            $Sddl = "O:BAG:SYD:PAI(A;OICI;FA;;;SY)"
            break
        }
        "NonSystemDisk[ReFS]\`$Recycle.Bin"{
            $Sddl = "O:${UserSid}G:${UserSid}D:PAI(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;;0x1201ad;;;BU)"
            break
        }
        "Home\Directory"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;FA;;;${UserSid})"
            break
        }
        "Home\SymbolicLinkDirectory"{
            $Sddl = "O:BAG:${UserSid}D:AI(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;FA;;;${UserSid})"
            break
        }
        "Home\Junction"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;OICIID;FA;;;SY)(A;OICIID;FA;;;BA)(A;OICIID;FA;;;${UserSid})"
            break
        }
        "NonSystemDisk[NTFS]\Directory"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;ID;FA;;;BA)(A;OICIIOID;GA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)"
            break
        }
        "NonSystemDisk[NTFS]\SymbolicLinkDirectory"{
            $Sddl = "O:BAG:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;ID;FA;;;BA)(A;OICIIOID;GA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)"
            break
        }
        "NonSystemDisk[NTFS]\Junction"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;ID;FA;;;BA)(A;OICIIOID;GA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\Directory"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;OICIID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\SymbolicLinkDirectory"{
            $Sddl = "O:BAG:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;OICIID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\Junction"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;OICIIOID;SDGXGWGR;;;AU)(A;ID;FA;;;SY)(A;OICIIOID;GA;;;SY)(A;OICIID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;OICIIOID;GXGR;;;BU)"
            break
        }
        "Home\desktop.ini"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;FA;;;${UserSid})"
            break
        }
        "Home\SymbolicLinkFile"{
            $Sddl = "O:BAG:${UserSid}D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;FA;;;${UserSid})"
            break
        }
        "Home\File"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;FA;;;${UserSid})"
            break
        }
        "Home\HardLink"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;FA;;;${UserSid})"
            break
        }
        "NonSystemDisk[NTFS]\desktop.ini"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)"
            break
        }
        "NonSystemDisk[NTFS]\SymbolicLinkFile"{
            $Sddl = "O:BAG:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)"
            break
        }
        "NonSystemDisk[NTFS]\File"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)"
            break
        }
        "NonSystemDisk[NTFS]\HardLink"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\desktop.ini"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\SymbolicLinkFile"{
            $Sddl = "O:BAG:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\File"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)"
            break
        }
        "NonSystemDisk[ReFS]\HardLink"{
            $Sddl = "O:${UserSid}G:${UserSid}D:AI(A;ID;0x1301bf;;;AU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;U)"
            break
        }
        Default {
            Write-Log "The $Path has unsupported `$PathType: $PathType"
            $Sddl = $null
        }
    }
    return $Sddl
}