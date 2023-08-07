function local:Assert-FileSystemAuthorized{
    <#
    .Description
    Here we check if have the customized FileSystem Authorization.
    We artificially define some rules and inspect the path to ensure it's a path that can be controlled by the users (include administrators), instead of by system only.
    Authorized Path is:
        Non-system disk root path
        Anything in Non-system disk
        $Home Directory
        Anything in $Home
    #>
    param(
        [string]$Path
    )
    $Qualifier = Get-Qualifier $Path
    if ($Qualifier -notin (Get-PSProvider FileSystem).Drives.Root){
        throw "`$Path: '$Path' $("`n`t")should be contained in FileSystem, such as C:, D:, X:, instead of this or other PSProviders."
    }
    elseif (((Get-Qualifier $Path) -eq (Get-Qualifier $Home)) -and !(Test-IsInInHome $Path)){
        throw "If `$Path: '$Path' is in SystemDisk, it sholuld be or in `$Home: $Home."
    }
}
function local:Reset-PathAttribute{
    <#
    .Description
    In a FileSystem, path’s arrtibuts can help us to distinguish a path's type:
        Is it a File, Directory, SymbolLink or Other type?
    We can use the command `(Get-ItemProperty "$Path").Attributes` to get the attriibuts.
    Consider a drive disk letter `X`.`X` have better not refer to the system disk,
    since modify arrtibuts on system file or system-generated file of system disk is hazardous.
    But in some cases, we can modify some items that belong to user and are established by user.

    We only specify the following 8 path types with standard attriibuts:
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
    If $Path is recognized with one of the above path types, its attriibuts will be reset.
    Other directories' attriibuts will not be reset.
    Other files' attriibuts will not be reset.

    Many (perhaps all) attributes can be find by `[enum]::GetValues([System.IO.FileAttributes])`:
        ReadOnly, Hidden, System, Directory, Archive, Device,
        Normal, Temporary, SparseFile, ReparsePoint, Compressed,
        Offline, NotContentIndexed, Encrypted, IntegrityStream, NoScrubData.
    We can use the command `Set-ItemProperty $Path -Name Attributes -Value $some_attributes`. But
    `$some_attributes` can only support `Archive, Hidden, Normal, ReadOnly, or System` and their permutations.
    So, to reset (normalize, standardize) the attributes to original status, we cannot directly give the target attributes, but use a specific `$some_attributes`.

    Here are the above specified 8 path types with corresponding `$some_attributes`:
        Directory:
            X:\                             Normal
            X:\System Volume Information\   Hidden, System
            X:\$Recycle.Bin\                Hidden, System
            X:\*some_symbolic_link_dir\     Normal
            X:\*some_junction\              Normal
        File:
            X:\*desktop.ini                 Hidden, System, Archive
            X:\*some_symbolic_link_file     Archive
            X:\*some_hardlink               Archive

    How to do? Check if a Directory or File, then deal with it with specifical rules:
        If is a Directory?
            If is `X:\System Volume Information\` or `X:\$Recycle.Bin\`?
                set Attributes with $some_Attributes="Hidden, System"
            ElseIf is `X:\` or `X:\*some_symbolic_link_dir\` or `X:\*some_junction\`:
                set Attributes with $some_Attributes="Normal"
            Else:
                set nothing, modify nothing, do not reset the attributes
        Else, consider as a File：
            If is `X:\*desktop.ini`?
                set Attributes with $some_Attributes="Hidden, System, Archive"
            ElseIf is `X:\*some_symbolic_link_file` or `X:\*some_hardlink`:
                set Attributes with $some_Attributes="Archive"
            Else:
                set nothing, modify nothing, do not reset the attributes

    To check if a path is Directory or File:
        Test-Path -Path $Path -PathType Container, # true->Directory, false->File, https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.2#-pathtype
        or
        Test-Path -Path $Path -PathType Leaf, # true->File, false->Directory, https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.2#-pathtype
        or
        (Get-Item $Path).PSIsContainer, # true->Directory, false->File,https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/foreach-object?view=powershell-7.2#example-2-get-the-length-of-all-the-files-in-a-directory
        or
        [bool]((Get-ItemProperty "$Path").Attributes -band [IO.FileAttributes]::Directory)
            https://learn.microsoft.com/en-us/dotnet/api/system.io.fileAttributes?view=net-6.0
            P.S. [bool]([IO.FileAttributes]::Directory,[IO.FileAttributes]::ReparsePoint -join ",") for Directory link
        We choose the last method since it's only suitable for FileSystem, bringing
        a expected `ineffect` when misuse this function on Non-FileSystem, which means a higher security.
    #>
    param(
        [string]$Path
    )
    try{
        $Qualifier = Get-Qualifier $Path
        $Attributes = (Get-ItemProperty -LiteralPath $Path).Attributes
        $Linktype = (Get-ItemProperty -LiteralPath $Path).LinkType
        $Path = Format-Path $Path
        Assert-FileSystemAuthorized $Path
        if ([bool]($Attributes -band [IO.FileAttributes]::Directory)){
            if (($Path -eq (Format-Path "${Qualifier}\System Volume Information")) -or
                ($Path -eq (Format-Path "${Qualifier}\`$Recycle.Bin"))){
                Set-ItemProperty -LiteralPath $Path -Name Attributes -Value "Hidden, System"
            }elseif ([bool]($Attributes -band [IO.FileAttributes]::ReparsePoint) -and
                     ($Linktype -in @('SymbolicLink','Junction'))){
                Set-ItemProperty -LiteralPath $Path -Name Attributes -Value "Normal"
            }
            else{
                $null
            }
        }
        elseif([bool]($Attributes -band [IO.FileAttributes]::Archive)){
            if ((Split-Path $Path -Leaf) -eq "desktop.ini"){
                Set-ItemProperty -LiteralPath $Path -Name Attributes -Value "Hidden, System, Archive"
            }elseif ([bool]($Attributes -band [IO.FileAttributes]::ReparsePoint) -and
                    ($Linktype -in @('SymbolicLink','HardLink'))){
                Set-ItemProperty -LiteralPath $Path -Name Attributes -Value "Archive"
            }
            else{
                $null
            }
        }
        else{
            throw "`$Path: $Path $("`n`t")has unsupported $("`n`t") path `$Attributes: $Attributes."
        }
    }
    catch{
        Write-Output  "Reset-PathAttribute Exception: $PSItem"
        Write-Output  "Operation has been skipped."
    }
}
function local:Get-PathType{
    <#
    .Description
    Get a customized Path type
    We only define (support) 18 types, mostly basing on `New-Item -ItemType`, see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.2#-itemtype
    Some paths have a hierarchical relationship and can belong to both types as follows, and we return only  the first type recognized in the following order.
    Here are these types and example:
        Directory:
            NonSystemDisk[NTFS/ReFS/FAT32]\Root                         X:\
            Home\Root                                                   $Home\
            NonSystemDisk[NTFS/ReFS/FAT32]\System Volume Information    X:\System Volume Information
            NonSystemDisk[NTFS/ReFS/FAT32]\$Recycle.Bin                 X:\$Recycle.Bin
            Home\Directory                                              $Home\*some_nomrmal_dir\
            Home\SymbolicLinkDirectory                                  $Home\*some_symbolic_link_dir\
            Home\Junction                                               $Home\*some_junction\
            NonSystemDisk[NTFS/ReFS/FAT32]\Directory                    X:\*some_nomrmal_dir\
            NonSystemDisk[NTFS/ReFS/FAT32]\SymbolicLinkDirectory        X:\*some_symbolic_link_dir\
            NonSystemDisk[NTFS/ReFS/FAT32]\Junction                     X:\*some_junction\
        File:
            Home\desktop.ini                                            $Home\*desktop.ini
            Home\SymbolicLinkFile                                       $Home\*some_symbolic_link_file
            Home\File                                                   $Home\*some_normal_file or InHome\*some_sparse_file
            Home\HardLink                                               $Home\*some_hardlink
            NonSystemDisk[NTFS/ReFS/FAT32]\desktop.ini                  X:\*desktop.ini
            NonSystemDisk[NTFS/ReFS/FAT32]\SymbolicLinkFile             X:\*some_symbolic_link_file
            NonSystemDisk[NTFS/ReFS/FAT32]\File                         X:\*some_normal_file or X:\*some_sparse_file
            NonSystemDisk[NTFS/ReFS/FAT32]\HardLink                     X:\*some_hardlink
        Here `NonSystemDisk[NTFS/ReFS/FAT32]` means, `X` is not system disk drive letter and `X:\` is in one of NTFS/ReFS/FAT32 file system.
        When output, a spcific file system will be shown, such as `NonSystemDisk[NTFS]`.
        Here `Home` means be or in `$Home` directory.

    We use `(Get-Volume (Get-Qualifier $Path).TrimEnd(":\")).FileSystemType` to check file system type.
    We use both `(Get-Item "$Path").Linktype` and `(Get-Item $Path).Attributes -band [IO.FileAttributes]::$some_Attributes` to implement type determination.
        Refer to https://cloud.tencent.com/developer/ask/sof/112542
        What is `-band` ? See https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7.2#arithmetic-operators
        But for specific, we use `-eq` instead of `-band`
    #>
    param(
        [string]$Path
    )
    try{
        $Path = Format-Path $Path
        Assert-FileSystemAuthorized $Path
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
            throw "`$Path: $Path $("`n`t")is not in home or has unsupported $("`n`t") file system type: $((Get-Volume (Get-Qualifier $Path).TrimEnd(":\")).FileSystemType)."
        }

        $Qualifier = Get-Qualifier $Path
        $Linktype = (Get-ItemProperty -LiteralPath $Path).LinkType
        $Attributes = (Get-ItemProperty -LiteralPath $Path).Attributes

        if ([bool]($Attributes -band [IO.FileAttributes]::Directory)){
            if (($Path -eq $Qualifier) -or ($Path -eq (Format-Path $Home))){
                return  "$header\Root"
            }
            elseif($Path -eq (Format-Path "${Qualifier}\System Volume Information")){
                return  "$header\System Volume Information"
            }
            elseif($Path -eq (Format-Path "${Qualifier}\`$Recycle.Bin")){
                return "$header\`$Recycle.Bin"
            }
            elseif((Get-DriveWithFirstDir $Path) -eq (Format-Path "${Qualifier}\System Volume Information")){
                throw "`$Path: $Path $("`n`t")has unsupported type $("`n`t")with `$Linktype:$Linktype and `$Attributes:$Attributes."
            }
            elseif((Get-DriveWithFirstDir $Path) -eq (Format-Path "${Qualifier}\`$Recycle.Bin")){
                throw "`$Path: $Path $("`n`t")has unsupported type $("`n`t")with `$Linktype:$Linktype and `$Attributes:$Attributes."
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
            throw "`$Path: $Path $("`n`t")has unsupported type $("`n`t")with `$Linktype:$Linktype and `$Attributes:$Attributes."
        }
    }
    catch{
        Write-Output  "Get-PathType Exception: '$PSItem'"
        Write-Output  "Operation has been skipped on '$Path'."
    }
}

function local:Set-OriginalAcl{
    <#
    .Description
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
    param(
        [string]$Path,
        [switch]$Recurse
    )
    try{
        $Path = Format-Path $Path
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
        if ($NewAcl.Sddl -ne $Sddl){
            try{
                Write-Output  "`$Path is:`n`t $Path"
                Write-Output  "Current Sddl is:`n`t $($NewAcl.Sddl)"
                Write-Output  "Target Sddl is:`n`t $($Sddl)"

                $NewAcl.SetSecurityDescriptorSddlForm($Sddl)
                Write-Output  "After dry-run, the sddl is:`n`t $($NewAcl.Sddl)"

                Set-Acl -LiteralPath $Path -AclObject $NewAcl -ErrorAction Stop
                Write-Output  "After applying ACL modification, the sddl is:`n`t $((Get-Acl -LiteralPath $Path).Sddl)"
            }
            catch [System.ArgumentException]{
                Write-Output  "`$Path is too long: '$Path'"
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
    catch {
        Write-Output  "Set-OriginalAcl Exception: $PSItem"
        Write-Output  "Operation has been skipped on $Path."
    }
}

function local:Get-Sddl{
    param(
        [string]$Path
    )
    Set-Acl -Path $Path (Get-Acl $Path) # normalization
    Write-Output  $Path
    Write-Output  "PathType: $(Get-PathType $Path)"
    Write-Output  (Get-Acl $Path).Sddl
}