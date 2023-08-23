function Assert-ValidatePath{
<#
.SYNOPSIS
    Check if a path is valid as the rule defined in https://little-train.com/posts/7fdde8eb.html.

.DESCRIPTION
    Check if $Path is valid as the rule defined in https://little-train.com/posts/7fdde8eb.html.
    Only the following 4 types of paths are valid:
        1. root path of Non-system disk 
        2. other path in Non-system disk
        3. path of ${Home} 
        4. other path in ${Home}
#>
    param(
        [string]$Path,
        [switch]$SkipFormat
    )
    if (-not $SkipFormat){
        $Path = Format-LiteralPath $Path
    }
    Assert-IsInFileSystem $Path
    Write-Verbose "The $Path is in FileSystem."
    if (Test-IsInSystemDrive $Path){
        if (Test-IsInInHome $Path -SkipFormat){
            return $true
        }
        else{
            throw "If $Path is in SystemDisk, it sholuld be or in `${Home}: ${Home}."
        }
    }else{
        Write-Verbose "The $Path is not in SystemDisk."
        return $true
    }
}
    

function Get-PathType{
<#
.SYNOPSIS
    Get a customized path type of a fileSystem path(disk, directory, file, link, etc.),
    according to the `Types of Items` described in https://little-train.com/posts/7fdde8eb.html.
.DESCRIPTION
    Basing on `New-Item -ItemType`, see 
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.2#-itemtype,
    this function defines 38 types of items, including the 28 types of items that defined in https://little-train.com/posts/7fdde8eb.html.

    Here are these types and example:
        Directory:
            NonSystemDisk[NTFS/ReFS/FAT32]\Root                         X:\
            Home\Root                                                   ${Home}\
            NonSystemDisk[NTFS/ReFS/FAT32]\System Volume Information    X:\System Volume Information
            NonSystemDisk[NTFS/ReFS/FAT32]\$Recycle.Bin                 X:\$Recycle.Bin
            Home\Directory                                              ${Home}\*some_nomrmal_dir\
            Home\SymbolicLinkDirectory                                  ${Home}\*some_symbolic_link_dir\
            Home\Junction                                               ${Home}\*some_junction\
            NonSystemDisk[NTFS/ReFS/FAT32]\Directory                    X:\*some_nomrmal_dir\
            NonSystemDisk[NTFS/ReFS/FAT32]\SymbolicLinkDirectory        X:\*some_symbolic_link_dir\
            NonSystemDisk[NTFS/ReFS/FAT32]\Junction                     X:\*some_junction\
        File:
            Home\desktop.ini                                            ${Home}\*desktop.ini
            Home\SymbolicLinkFile                                       ${Home}\*some_symbolic_link_file
            Home\File                                                   ${Home}\*some_normal_file or InHome\*some_sparse_file
            Home\HardLink                                               ${Home}\*some_hardlink
            NonSystemDisk[NTFS/ReFS/FAT32]\desktop.ini                  X:\*desktop.ini
            NonSystemDisk[NTFS/ReFS/FAT32]\SymbolicLinkFile             X:\*some_symbolic_link_file
            NonSystemDisk[NTFS/ReFS/FAT32]\File                         X:\*some_normal_file or X:\*some_sparse_file
            NonSystemDisk[NTFS/ReFS/FAT32]\HardLink                     X:\*some_hardlink
    Here `NonSystemDisk[NTFS/ReFS/FAT32]` means, `X` is not system disk drive letter and `X:\` is in one of NTFS/ReFS/FAT32 file system.
    When output, a spcific file system will be shown, such as `NonSystemDisk[NTFS]`.
    Here `Home` means be or in `${Home}` directory.

    Actually, some paths have a hierarchical relationship and can belong to both types as follows, and we return only the first type recognized in the above order.
    That is to same, the above shown order is the key to identify all customized path types.

    References:
        Refer to https://cloud.tencent.com/developer/ask/sof/112542 for links
        What is `-band` ? See https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.2#arithmetic-operators

.COMPONENT
    To check file system type:
        (Get-Volume (Get-Qualifier $Path).TrimEnd(":\")).FileSystemType
    To check link type:
        (Get-ItemProperty "$Path").Linktype
        (Get-ItemProperty $Path).Attributes -band [IO.FileAttributes]::$some_Attributes

.PARAMETER Path
    The path to be checked to get its type.

.PARAMETER SkipFormat
    Switch to disable automatic formatting of `$Path` by `Format-LiteralPath` at the beginning.
    If true(given), the `$Path` will not be formatted by `Format-LiteralPath` at the beginning. 

.PARAMETER SkipPlatformCheck
    Switch to disable platform check at the beginning.
    If true(given), the platform will not be checked at the beginning.

.OUTPUTS
    System.String if `$Path` can be recognized as a customized path type.
    $null when error or the`$Path` cannot be recognized as a customized path type.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Assert-ValidatePath $_})]
        [string]$Path,
        [switch]$SkipFormat,
        [switch]$SkipPlatformCheck
    )
    try {
        
        if (-not $SkipFormat){
            $Path = Format-LiteralPath $Path
        }
        if (-not $SkipPlatformCheck){
            Assert-IsWindows
        }
    }
    catch {
        Write-VerboseLog  "Exception caught: $_"
        return $null
    }

    if (Test-IsInInHome $Path){
        $header = "Home"
    }
    elseif ((Get-Volume (Get-Qualifier $Path).TrimEnd(":\")).FileSystemType -eq "NTFS"){
        $header = "NonSystemDisk[NTFS]"
    }
    elseif ((Get-Volume (Get-Qualifier $Path).TrimEnd(":\")).FileSystemType -eq "ReFS"){
        $header = "NonSystemDisk[ReFS]"
    }
    elseif((Get-Volume (Get-Qualifier $Path).TrimEnd(":\")).FileSystemType -eq "FAT32"){
        $header = "NonSystemDisk[FAT32]"
    }
    else {
        Write-VerboseLog "`$Path: $Path $("`n`t")is not in home or has unsupported $("`n`t") file system type: $((Get-Volume (Get-Qualifier $Path).TrimEnd(":\")).FileSystemType)."
        return $null
    }

    $Qualifier = Get-Qualifier $Path
    $Linktype = (Get-ItemProperty $Path).LinkType
    $Attributes = (Get-ItemProperty $Path).Attributes

    if ([bool]($Attributes -band [IO.FileAttributes]::Directory)){
        if (($Path -eq $Qualifier) -or ($Path -eq (Format-LiteralPath ${Home}))){
            return  "$header\Root"
        }
        elseif($Path -eq (Format-LiteralPath "${Qualifier}\System Volume Information")){
            return  "$header\System Volume Information"
        }
        elseif($Path -eq (Format-LiteralPath "${Qualifier}\`$Recycle.Bin")){
            return "$header\`$Recycle.Bin"
        }
        elseif((Get-DriveWithFirstDir $Path) -eq (Format-LiteralPath "${Qualifier}\System Volume Information")){
            Write-VerboseLog "`$Path: $Path $("`n`t")has unsupported type $("`n`t")with `$Linktype:$Linktype and `$Attributes:$Attributes."
            return $null
        }
        elseif((Get-DriveWithFirstDir $Path) -eq (Format-LiteralPath "${Qualifier}\`$Recycle.Bin")){
            Write-VerboseLog "`$Path: $Path $("`n`t")has unsupported type $("`n`t")with `$Linktype:$Linktype and `$Attributes:$Attributes."
            return $null
            
        }
        elseif ([bool]($Attributes -band [IO.FileAttributes]::ReparsePoint) -and ($Linktype -eq "SymbolicLink")) {
            return "$header\SymbolicLinkDirectory"
        }
        elseif ([bool]($Attributes -band [IO.FileAttributes]::ReparsePoint) -and ($Linktype -eq "Junction")) {
            return "$header\Junction"
        }
        else{
            return "$header\Directory"
        }
    }
    elseif([bool]($Attributes -band [IO.FileAttributes]::Archive)){
        if ((Split-Path $Path -Leaf) -eq "desktop.ini"){
            return "$header\desktop.ini"
        }
        elseif ($Linktype -eq "HardLink"){
            return "$header\HardLink"
        }
        elseif ($Linktype -eq "SymbolicLink"){
            return "$header\SymbolicLinkFile"
        }
        else{
            return "$header\File"
        }
    }
    else{
        Write-VerboseLog "`$Path: $Path $("`n`t")has unsupported type $("`n`t")with `$Linktype:$Linktype and `$Attributes:$Attributes."
        return $null
    }
}


function Reset-PathAttribute{
<#
.SYNOPSIS
    Reset the attributes of a path to the original status, when the path is recognized in some
    special path types that are defined in the function `Get-PathType`.

.DESCRIPTION
    Reset the attributes of $Path to the original status, when it is recognized in the following 8 types
    (appended with corresponding standard attriibuts):
    Directory:
        X:\                             Hidden, System, Directory
        X:\System Volume Information\   Hidden, System, Directory
        X:\$Recycle.Bin\                Hidden, System, Directory
        X:\*some_symbolic_link_dir\     Directory, ReparsePoint
        X:\*some_junction\              Directory, ReparsePoint
    File:
        X:\*desktop.ini                 Hidden, System, Archive
        X:\*some_symbolic_link_file     Archive, ReparsePoint
        X:\*some_hardlink               Archive
    Here the `X` represents any drive disk letter.

    Other directories' attriibuts will not be reset.
    Other files' attriibuts will not be reset.

    See https://little-train.com/posts/7fdde8eb.html for more details.

    Many (perhaps all) attributes can be find by `[enum]::GetValues([System.IO.FileAttributes])`:
        ReadOnly, Hidden, System, Directory, Archive, Device,
        Normal, Temporary, SparseFile, ReparsePoint, Compressed,
        Offline, NotContentIndexed, Encrypted, IntegrityStream, NoScrubData.
    We can use the command `Set-ItemProperty $Path -Name Attributes -Value $some_attributes`. But
    `$some_attributes` can only support `Archive, Hidden, Normal, ReadOnly, or System` and their permutations.
    So, to reset the attributes to standard status, we cannot directly give the
    target attributes, but use a specific `$some_attributes`.

    
.COMPONENT
    To get the attriibuts of $Path:
        (Get-ItemProperty $Path).Attributes
    To set the attriibuts of $Path:
        Set-ItemProperty $Path -Name Attributes -Value $some_attributes

.PARAMETER Path
    The path to be checked to reset its attributes.

.PARAMETER SkipFormat
    Switch to disable automatic formatting of `$Path` by `Format-LiteralPath` at the beginning.
    If true(given), the `$Path` will not be formatted by `Format-LiteralPath` at the beginning. 

.PARAMETER SkipPlatformCheck
    Switch to disable platform check at the beginning.
    If true(given), the platform will not be checked at the beginning.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({Assert-IsInFileSystem $_})]
        [string]$Path,
        [switch]$SkipFormat,
        [switch]$SkipPlatformCheck
    )
    try{
        if (-not $SkipFormat){
            $Path = Format-LiteralPath $Path
        }
        if (-not $SkipPlatformCheck){
            Assert-IsWindows
        }
        
        $Attributes = (Get-ItemProperty $Path).Attributes
        $Linktype = (Get-ItemProperty $Path).LinkType
        $Path = Format-LiteralPath $Path -SkipFormat
        if($PSCmdlet.ShouldProcess("$Path",'reset the attributes')){
            if (Test-IsDirectory $Path){
                if ((Test-IsSystemVolumeInfo $Path -SkipFormat) -or (Test-IsRecycleBin $Path -SkipFormat)){
                    Set-ItemProperty $Path -Name Attributes -Value "Hidden, System"
                }elseif (Test-IsSymbolicOrJunction $Path){
                    Set-ItemProperty $Path -Name Attributes -Value "Normal"
                }
                else{
                    # $null
                }
            }
            elseif(Test-IsFile $Path){
                if ((Split-Path $Path -Leaf) -eq "desktop.ini"){
                    Set-ItemProperty $Path -Name Attributes -Value "Hidden, System, Archive"
                }elseif (Test-IsSymbolicOrJunction $Path){
                    Set-ItemProperty $Path -Name Attributes -Value "Archive"
                }
                else{
                    # $null
                }
            }
            else{
                throw "`$Path: $Path $("`n`t")has unsupported $("`n`t") path `$Attributes: $Attributes."
            }
        }
    }
    catch{
        Write-VerboseLog  "Reset-PathAttribute Exception: $PSItem"
        Write-VerboseLog  "Operation has been skipped."
    }
}

function Get-DefaultSddl{
<#
.SYNOPSIS
    Get default SDDL for a specific path.
.DESCRIPTION
    Get `$PathType` of `$Path` by `Get-PathType` and then get the default SDDL of the `$Path` according to the `$PathType`. 
    The relationship between the `$PathType` and its default SDDL are the following mappings:
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

.PARAMETER Path
    The path to be checked. 
    For stability, ny default, this function will automatically format the path by `Format-LiteralPath` at the beginning.
    For better performance in cascading calls, it is recommended to be formatted by `Format-LiteralPath` before input and
    call this function by `Get-DefaultSddl -Path $Path -SkipFormat`.

.PARAMETER SkipFormat
    Switch to disable automatic formatting of `$Path` by `Format-LiteralPath` at the beginning.
    If true(given), the `$Path` will not be formatted by `Format-LiteralPath` at the beginning. 

.OUTPUTS
    System.String if the `$PathType` from `$Path` is involved in the above mappings between `$PathType` and default SDDLs.
    $null if the `$PathType` from `$Path` is not involved in mappings.
#>
    [CmdletBinding()]
    param(
        [string]$Path,
        [switch]$SkipFormat
    )
    if (-not $SkipFormat){
        $Path = Format-LiteralPath $Path
    }
    $PathType = Get-PathType -Path $Path -SkipFormat
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
            Write-VerboseLog "`$Path: $Path has unsupported `$PathType: $PathType"
            $Sddl = $null
        }
    }
    return $Sddl
}




function Reset-Acl{
<#
.SYNOPSIS
Reset the ACL of a path to its default state.
For more information on the motivation, rationale, logic, and use of this function, see https://little-train.com/posts/7fdde8eb.html

.DESCRIPTION
    Reset ACL of `$Path` to its default state by 3 steps:
        1. Get path type by `Get-PathType`
        2. Get default SDDL of `$Path` by `Get-DefaultSddl`

.COMPONENT
    $NewAcl = Get-Acl -LiteralPath $Path
    $Sddl = ... # Get default SDDL of `$Path`
    $NewAcl.SetSecurityDescriptorSddlForm($Sddl)
    Set-Acl -LiteralPath $Path -AclObject $NewAcl

Only for window system
Only for single user account on window system, i.e. totoally Personal Computer
Need function Get-PathType
Need function Reset-PathAttribute

There are at least 2 methods to modify ACL(SDDL) of `$Path`
1. Using `Acl` data sturcture's built-in incremental methods: SetOwner, SetGroup, RemoveAccessRule, SetAccessRule and so on.
    We have tested numerous times to ensure generated ACL is as clean and as close to the original state as possible.
    Provided we get a $temp_acl by `$temp_acl = Get-Acl -Path $Path`,
    there are many build-in method for us to control or midify the $temp_acl:
        see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-acl?view=powershell-7.2
            https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule?view=net-6.0#constructors
            https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule.-ctor?view=net-6.0#system-security-accesscontrol-filesystemaccessrule-ctor(system-security-principal-identityreference-system-security-accesscontrol-filesystemrights-system-security-accesscontrol-accesscontroltype)
            https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule.-ctor?view=net-6.0#system-security-accesscontrol-filesystemaccessrule-ctor(system-security-principal-identityreference-system-security-accesscontrol-filesystemrights-system-security-accesscontrol-inheritanceflags-system-security-accesscontrol-propagationflags-system-security-accesscontrol-accesscontroltype)
            https://theitbros.com/get-acl-and-set-acl-cmdlets/
        $temp_acl.SetOwner((new-object System.Security.Principal.NTAccount("BUILTIN\Administrators")))
        $temp_acl.SetGroup((new-object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")))
        $temp_acl.RemoveAccessRule(
            (New-Object System.Security.AccessControl.FileSystemAccessRule(
                $identity,$fileSystemRights,$InheritanceFlags,$PropagationFlags,$type)))
        $temp_acl.RemoveAccessRuleAll
        $temp_acl.RemoveAccessRuleSpecific
        $temp_acl.AddAccessRule
        $temp_acl.SetAccessRule
        $temp_acl.SetAccessRuleProtection
2. Using Acl` data sturcture's built-in direct methods: SetSecurityDescriptorSddlForm
    $temp_acl.SetSecurityDescriptorSddlForm($some_sddl)

    What is `Sddl`? See https://learn.microsoft.com/en-us/windows/win32/secauthz/security-descriptor-definition-language
    Here annotates values that occur frequently in practice:
        O:owner_sid
            A SID string that identifies the object's owner.
            What is `SID string`? See https://learn.microsoft.com/en-us/windows/win32/secauthz/sid-strings.
                AU means SDDL_AUTHENTICATED_USERS, i.e. `NT AUTHORITY\Authenticated Users`
                SY means SDDL_LOCAL_SYSTEM, i.e. `NT AUTHORITY\SYSTEM`
                BA means SDDL_BUILTIN_ADMINISTRATORS,i.e. `BUILTIN\Administrators`
                BU means SDDL_BUILTIN_USERS, i.e. `BUILTIN\Users`
                or
                    (Get-LocalUser -Name ([Environment]::UserName)).SID.Value, i.e. `[Environment]::MachineName+"\"+[Environment]::UserName`
        G:group_sid
            A SID string that identifies the object's primary group.
            The same definition as owner_sid.
        D:dacl_flags(string_ace1)(string_ace2)... (string_acen)
            dacl_flags, see https://learn.microsoft.com/en-us/windows/win32/secauthz/security-descriptor-string-format#:~:text=object%27s%20primary%20group.-,dacl_flags,-Security%20descriptor%20control
                Some common samples in practice:
                    P means SDDL_PROTECTED
                    AI means SDDL_AUTO_INHERITED
            string_ace, see https://learn.microsoft.com/en-us/windows/win32/secauthz/ace-strings
                (ace_type;ace_flags;rights;object_guid;inherit_object_guid;account_sid;(resource_attribute))
                Some common samples in practice:
                    ace_type
                        A means SDDL_ACCESS_ALLOWED
                    ace_flags
                        OICI   means SDDL_OBJECT_INHERIT, SDDL_CONTAINER_INHERIT
                        OICIID means SDDL_OBJECT_INHERIT, SDDL_CONTAINER_INHERIT, SDDL_INHERITED
                        ID     means, SDDL_INHERITED
                    rights
                        0x1301bf  represents `Modify, Synchronize`
                        FA        means SDDL_FILE_ALL
                        0x1200a9  represents `ReadAndExecute, Synchronize`
                    object_guid
                    inherit_object_guid
                    account_sid
                        SID string that identifies the trustee of the ACE.
                        The meaning is same to the SID string on owner_sid or group_sid
        S:sacl_flags(string_ace1)(string_ace2)... (string_acen)
            The same definition as dacl_flags.
Using builtin incremental methods relies too much on PowerShell's cmdlet, which is suitable for fine-tuning after inheriting an ACL,
but when making bulk ACL changes or modifying a lot of ACL content, it is not as convenient as modifying Sddl directly.
So, we just use $temp_acl.SetSecurityDescriptorSddlForm($some_sddl) to change ACL.

This function is used to reset the ACL(SDDL) of a $Path to the original/correct/target one.
The mapping from $PathType to  original/correct/target ACL(SDDL) has been defined(writen) in this function.

Specifically, according to $PathType output by function `Get-PathType`, generate a original/correct/target ACL(SDDL),
then cover $Path's ACL(SDDL).



All `SDDLs`s are from a origin installed native system, so we can ensure it is in the original/correct/target state.
#>
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [string]$Path,
            [switch]$SkipFormat,
            [switch]$Recurse
        )
        try{
            Assert-IsWindows
            if (-not $SkipFormat){
                $Path = Format-LiteralPath $Path
            }
            Reset-PathAttribute $Path
            
            $NewAcl = Get-Acl -LiteralPath $Path
            if($PSCmdlet.ShouldProcess("$Path",'set the original ACL')){
                if ($NewAcl.Sddl -ne $Sddl){
                    try{
                        Write-VerboseLog  "`$Path is:`n`t $Path"
                        Write-VerboseLog  "Current Sddl is:`n`t $($NewAcl.Sddl)"
                        Write-VerboseLog  "Target Sddl is:`n`t $($Sddl)"
        
                        $NewAcl.SetSecurityDescriptorSddlForm($Sddl)
                        Write-VerboseLog  "After dry-run, the sddl is:`n`t $($NewAcl.Sddl)"
        
                        Set-Acl -LiteralPath $Path -AclObject $NewAcl -ErrorAction Stop
                        Write-VerboseLog  "After applying ACL modification, the sddl is:`n`t $((Get-Acl -LiteralPath $Path).Sddl)"
                    }
                    catch [System.ArgumentException]{
                        Write-VerboseLog  "`$Path is too long: '$Path'"
                    }
                }
                if (($Recurse) -and
                    ($PathType -notin @(
                        "NonSystemDisk[NTFS]\System Volume Information",
                        "NonSystemDisk[NTFS]\`$Recycle.Bin",
                        "NonSystemDisk[ReFS]\System Volume Information",
                        "NonSystemDisk[ReFS]\`$Recycle.Bin"))){
                    # Recurse bypass: files, symbolic link directories, junctions, System Volume Information, `$Recycle.Bin
                    $Paths = Get-ChildItem -LiteralPath $Path -Force -Recurse -Attributes !ReparsePoint
                    # The progress bar is refer to Chat-Gpt
                    $total = $Paths.Count
                    $current = 0
                    foreach ($item in $Paths) {
                        $current++
                        $progressPercentage = ($current / $total) * 100
                        $progressStatus = "Processing file $current of $total"
        
                        Write-Progress -Activity "Traversing Directory" -Status $progressStatus -PercentComplete $progressPercentage
        
                        # Do your personal jobs, such as: $file.FullName
                        Set-OriginalAcl -Path $item.FullName
        
                    }
        
                    Write-Progress -Activity "Traversing Directory" -Completed
                }
    
            }
            
        }
        catch {
            Write-VerboseLog  "Set-OriginalAcl Exception: $PSItem"
            Write-VerboseLog  "Operation has been skipped on $Path."
        }
    }


function Set-OriginalAcl{
<#
.DESCRIPTION
Only for window system
Only for single user account on window system, i.e. totoally Personal Computer
Need function Get-PathType
Need function Reset-PathAttribute

There are at least 2 methods to modify ACL(SDDL) of `$Path`
1. Using `Acl` data sturcture's built-in incremental methods: SetOwner, SetGroup, RemoveAccessRule, SetAccessRule and so on.
    We have tested numerous times to ensure generated ACL is as clean and as close to the original state as possible.
    Provided we get a $temp_acl by `$temp_acl = Get-Acl -Path $Path`,
    there are many build-in method for us to control or midify the $temp_acl:
        see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-acl?view=powershell-7.2
            https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule?view=net-6.0#constructors
            https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule.-ctor?view=net-6.0#system-security-accesscontrol-filesystemaccessrule-ctor(system-security-principal-identityreference-system-security-accesscontrol-filesystemrights-system-security-accesscontrol-accesscontroltype)
            https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule.-ctor?view=net-6.0#system-security-accesscontrol-filesystemaccessrule-ctor(system-security-principal-identityreference-system-security-accesscontrol-filesystemrights-system-security-accesscontrol-inheritanceflags-system-security-accesscontrol-propagationflags-system-security-accesscontrol-accesscontroltype)
            https://theitbros.com/get-acl-and-set-acl-cmdlets/
        $temp_acl.SetOwner((new-object System.Security.Principal.NTAccount("BUILTIN\Administrators")))
        $temp_acl.SetGroup((new-object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")))
        $temp_acl.RemoveAccessRule(
            (New-Object System.Security.AccessControl.FileSystemAccessRule(
                $identity,$fileSystemRights,$InheritanceFlags,$PropagationFlags,$type)))
        $temp_acl.RemoveAccessRuleAll
        $temp_acl.RemoveAccessRuleSpecific
        $temp_acl.AddAccessRule
        $temp_acl.SetAccessRule
        $temp_acl.SetAccessRuleProtection
2. Using Acl` data sturcture's built-in direct methods: SetSecurityDescriptorSddlForm
    $temp_acl.SetSecurityDescriptorSddlForm($some_sddl)

    What is `Sddl`? See https://learn.microsoft.com/en-us/windows/win32/secauthz/security-descriptor-definition-language
    Here annotates values that occur frequently in practice:
        O:owner_sid
            A SID string that identifies the object's owner.
            What is `SID string`? See https://learn.microsoft.com/en-us/windows/win32/secauthz/sid-strings.
                AU means SDDL_AUTHENTICATED_USERS, i.e. `NT AUTHORITY\Authenticated Users`
                SY means SDDL_LOCAL_SYSTEM, i.e. `NT AUTHORITY\SYSTEM`
                BA means SDDL_BUILTIN_ADMINISTRATORS,i.e. `BUILTIN\Administrators`
                BU means SDDL_BUILTIN_USERS, i.e. `BUILTIN\Users`
                or
                    (Get-LocalUser -Name ([Environment]::UserName)).SID.Value, i.e. `[Environment]::MachineName+"\"+[Environment]::UserName`
        G:group_sid
            A SID string that identifies the object's primary group.
            The same definition as owner_sid.
        D:dacl_flags(string_ace1)(string_ace2)... (string_acen)
            dacl_flags, see https://learn.microsoft.com/en-us/windows/win32/secauthz/security-descriptor-string-format#:~:text=object%27s%20primary%20group.-,dacl_flags,-Security%20descriptor%20control
                Some common samples in practice:
                    P means SDDL_PROTECTED
                    AI means SDDL_AUTO_INHERITED
            string_ace, see https://learn.microsoft.com/en-us/windows/win32/secauthz/ace-strings
                (ace_type;ace_flags;rights;object_guid;inherit_object_guid;account_sid;(resource_attribute))
                Some common samples in practice:
                    ace_type
                        A means SDDL_ACCESS_ALLOWED
                    ace_flags
                        OICI   means SDDL_OBJECT_INHERIT, SDDL_CONTAINER_INHERIT
                        OICIID means SDDL_OBJECT_INHERIT, SDDL_CONTAINER_INHERIT, SDDL_INHERITED
                        ID     means, SDDL_INHERITED
                    rights
                        0x1301bf  represents `Modify, Synchronize`
                        FA        means SDDL_FILE_ALL
                        0x1200a9  represents `ReadAndExecute, Synchronize`
                    object_guid
                    inherit_object_guid
                    account_sid
                        SID string that identifies the trustee of the ACE.
                        The meaning is same to the SID string on owner_sid or group_sid
        S:sacl_flags(string_ace1)(string_ace2)... (string_acen)
            The same definition as dacl_flags.
Using builtin incremental methods relies too much on PowerShell's cmdlet, which is suitable for fine-tuning after inheriting an ACL,
but when making bulk ACL changes or modifying a lot of ACL content, it is not as convenient as modifying Sddl directly.
So, we just use $temp_acl.SetSecurityDescriptorSddlForm($some_sddl) to change ACL.

This function is used to reset the ACL(SDDL) of a $Path to the original/correct/target one.
The mapping from $PathType to  original/correct/target ACL(SDDL) has been defined(writen) in this function.

Specifically, according to $PathType output by function `Get-PathType`, generate a original/correct/target ACL(SDDL),
then cover $Path's ACL(SDDL).

The supported $PathType and corresponding ACL(SDDL) mappings are:
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

All `SDDLs`s are from a origin installed native system, so we can ensure it is in the original/correct/target state.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path,
        [switch]$Recurse
    )
    try{
        Assert-IsWindows
        $Path = Format-LiteralPath $Path
        Reset-PathAttribute $Path
        $PathType = Get-PathType $Path
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
                throw "`$Path: $Path has unsupported `$PathType: $PathType"
            }
        }
        $NewAcl = Get-Acl -LiteralPath $Path
        if($PSCmdlet.ShouldProcess("$Path",'set the original ACL')){
            if ($NewAcl.Sddl -ne $Sddl){
                try{
                    Write-VerboseLog  "`$Path is:`n`t $Path"
                    Write-VerboseLog  "Current Sddl is:`n`t $($NewAcl.Sddl)"
                    Write-VerboseLog  "Target Sddl is:`n`t $($Sddl)"
    
                    $NewAcl.SetSecurityDescriptorSddlForm($Sddl)
                    Write-VerboseLog  "After dry-run, the sddl is:`n`t $($NewAcl.Sddl)"
    
                    Set-Acl -LiteralPath $Path -AclObject $NewAcl -ErrorAction Stop
                    Write-VerboseLog  "After applying ACL modification, the sddl is:`n`t $((Get-Acl -LiteralPath $Path).Sddl)"
                }
                catch [System.ArgumentException]{
                    Write-VerboseLog  "`$Path is too long: '$Path'"
                }
            }
            if (($Recurse) -and
                ($PathType -notin @(
                    "NonSystemDisk[NTFS]\System Volume Information",
                    "NonSystemDisk[NTFS]\`$Recycle.Bin",
                    "NonSystemDisk[ReFS]\System Volume Information",
                    "NonSystemDisk[ReFS]\`$Recycle.Bin"))){
                # Recurse bypass: files, symbolic link directories, junctions, System Volume Information, `$Recycle.Bin
                $Paths = Get-ChildItem -LiteralPath $Path -Force -Recurse -Attributes !ReparsePoint
                # The progress bar is refer to Chat-Gpt
                $total = $Paths.Count
                $current = 0
                foreach ($item in $Paths) {
                    $current++
                    $progressPercentage = ($current / $total) * 100
                    $progressStatus = "Processing file $current of $total"
    
                    Write-Progress -Activity "Traversing Directory" -Status $progressStatus -PercentComplete $progressPercentage
    
                    # Do your personal jobs, such as: $file.FullName
                    Set-OriginalAcl -Path $item.FullName
    
                }
    
                Write-Progress -Activity "Traversing Directory" -Completed
            }

        }
        
    }
    catch {
        Write-VerboseLog  "Set-OriginalAcl Exception: $PSItem"
        Write-VerboseLog  "Operation has been skipped on $Path."
    }
}

function Get-Sddl{
    [CmdletBinding()]
    param(
        [string]$Path
    )
    Set-Acl -Path $Path (Get-Acl $Path) # normalization
    Write-VerboseLog  $Path
    Write-VerboseLog  "PathType: $(Get-PathType $Path)"
    Write-VerboseLog  (Get-Acl $Path).Sddl
}

function Test-LinkAclBeahvior([string]$Link,[string]$Source){
<#
.DESCRIPTION
Test link's ACL beahvior, i.e., check the ACL info whether be syncronized
between Link and Source  on `SymbolicLink` `Junction` or `HardLink`

We use `Owner` info to test.
#>
    $LinkAcl =  Get-Acl -Path $Link
    $LinkAcl_bak =  Get-Acl -Path $Link
    $SourceAcl =  Get-Acl -Path $Source
    $SourceAcl_bak =  Get-Acl -Path $Source

    # unify Owner
    $LinkAcl.SetOwner((new-object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")))
    $SourceAcl.SetOwner((new-object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")))
    Set-Acl $Link -AclObject $LinkAcl
    Set-Acl $Source -AclObject $SourceAcl

    # make Owner different
    $LinkAcl =  Get-Acl -Path $Link
    $SourceAcl =  Get-Acl -Path $Source
    $LinkAcl.SetOwner((new-object System.Security.Principal.NTAccount("BUILTIN\Administrators")))
    $SourceAcl.SetOwner((new-object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")))
    Set-Acl $Link -AclObject $LinkAcl
    Set-Acl $Source -AclObject $SourceAcl

    # test sync
    $LinkAcl =  Get-Acl -Path $Link
    $SourceAcl =  Get-Acl -Path $Source
    # Write-Output $LinkAcl.Owner
    # Write-Output $SourceAcl.Owner
    $output = ($LinkAcl.Owner -eq $SourceAcl.Owner)

    # restore
    Set-Acl $Link -AclObject $LinkAcl_bak
    Set-Acl $Source -AclObject $SourceAcl_bak

    return $output
}