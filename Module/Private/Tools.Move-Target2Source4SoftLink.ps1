# function Test-ValidPath4LinkTools{
#     [CmdletBinding()]
#     [OutputType([bool])]
#     param(
#         [FormattedFileSystemPath]$Path,
#         [switch]$File
#     )
#     if($File){
#         if(!$Path.IsFile){
#             throw "The $Path should be a file."
#         }
#     }else{
#         if(!$Path.IsDir){
#             throw "The $Path should be a directory."
#         }
#     }

#     if($Path.IsSymbolicLink -or $Path.IsJunction){
#         throw "The $Path should not be a symbolic link or junction point."
#     }
#     return $true
# }


# function Merge-DirectoryWithBackup{
# <#
# .DESCRIPTION
#     Backup $Source to a path based on $Backuppath
#     Backup $Destination to a path based on $Backuppath
#     Then, merge items from $Source to $Destination
#     Record logs
# #>
#     [CmdletBinding(SupportsShouldProcess)]
#     param(
#         [Parameter(Mandatory)]
#         [ValidateScript({Test-ValidPath4LinkTools $_})]
#         [FormattedFileSystemPath]$Source,
#         [Parameter(Mandatory)]
#         [ValidateScript({Test-ValidPath4LinkTools $_})]
#         [FormattedFileSystemPath]$Destination,
#         [Parameter(Mandatory)]
#         [ValidateScript({Test-ValidPath4LinkTools $_})]
#         [FormattedFileSystemPath]$Backuppath
#     )

#     $guid = [guid]::NewGuid()
#     $source_name = $Source.ToShortName()
#     $backup_source = "$Backuppath/$guid-$source_name"
#     $destination_name = $Destination.ToShortName()
#     $backup_destination = "$Backuppath/$guid-$destination_name"
#     $log_file = Get-LogFileName "Robocopy Merge-DirectoryWithBackup"
#     if($PSCmdlet.ShouldProcess(
#         "Backup $Source to $backup_source"+[Environment]::NewLine+
#         "Backup $Destination to $backup_destination"+[Environment]::NewLine+
#         "Then, merge items from $Source to $Destination"+[Environment]::NewLine+
#         "Record logs to $log_file",'',''))
#     {
#         Assert-AdminRobocopyAvailable
#         Robocopy $Source $backup_source /E /copyall /DCOPY:DATE /LOG:"$log_file"
#         Robocopy $Destination $backup_destination /E /copyall /DCOPY:DATE /LOG:"$log_file"
#         Robocopy $Source $Destination /E /copyall /DCOPY:DATE /LOG:"$log_file"
#     }

# }
# function Move-FileWithBackup{
# <#
# .DESCRIPTION
#     Backup $Source to a path based on $Backuppath
#     Backup $Destination to a path based on $Backuppath
#     Then, move $Source to $Destination
#     Record logs
# #>
#     [CmdletBinding(SupportsShouldProcess)]
#     param(
#         [Parameter(Mandatory)]
#         [ValidateScript({Test-ValidPath4LinkTools $_ -File})]
#         [FormattedFileSystemPath]$Source,
#         [Parameter(Mandatory)]
#         [ValidateScript({Test-ValidPath4LinkTools $_ -File})]
#         [FormattedFileSystemPath]$Destination,
#         [Parameter(Mandatory)]
#         [ValidateScript({Test-ValidPath4LinkTools $_})]
#         [FormattedFileSystemPath]$Backuppath
#     )
#     $guid = [guid]::NewGuid()
#     $source_name = $Source.ToShortName()
#     $backup_source = "$Backuppath/$guid-$source_name"
#     $destination_name = $Destination.ToShortName()
#     $backup_destination = "$Backuppath/$guid-$destination_name"
#     $log_file = Get-LogFileName
#     if($PSCmdlet.ShouldProcess(
#         "Backup $Source to $backup_source"+[Environment]::NewLine+
#         "Backup $Destination to $backup_destination"+[Environment]::NewLine+
#         "Then, move $Source to $Destination"+[Environment]::NewLine+
#         "Record logs to $log_file",'',''))
#     {
#         Write-Logs (Copy-Item $Source $backup_source)
#         Write-Logs (Copy-Item $Destination $backup_destination)
#         Write-Logs (Copy-Item $Source $Destination)
#     }
# }
# function Merge-BeforeSetDirLink{
# <#
# .DESCRIPTION
#     Before setting a directory link (Symbolic Link or Junction)
#     from $Target2 to $Target1, this function should be used to
#     merge the content in $Target1 to $Target2.

#     Merge form $Target1 to $Target2 by the following rules:
#         $Target1------------------------| $Target2----------------------| Opeartion
#         non-existing                    | non-existing                  | pass(do nothing)
#         non-existing                    | dir-symbolic-or-hardlink      | throw error
#         non-existing                    | dir-not-symbolic-or-hardlink  | pass(do nothing)
#         dir-symbolic-or-hardlink        | non-existing                  | throw error
#         dir-symbolic-or-hardlink        | dir-symbolic-or-hardlink      | throw error
#         dir-symbolic-or-hardlink        | dir-not-symbolic-or-hardlink  | del $Target1
#         dir-not-symbolic-or-hardlink    | non-existing                  | copy $Target1 to $Target2, del $Target1
#         dir-not-symbolic-or-hardlink    | dir-symbolic-or-hardlink      | throw error
#         dir-not-symbolic-or-hardlink    | dir-not-symbolic-or-hardlink  | backup $Target1 and $Target2 to $Backuppath, then merge $Target1 to $Target2, then del $Target1
# #>
#     [CmdletBinding(SupportsShouldProcess)]
#     param(
#         [Parameter(Mandatory)]
#         [string]$Target1,
#         [Parameter(Mandatory)]
#         [string]$Target2,
#         [Parameter(Mandatory)]
#         [ValidateScript({Test-ValidPath4LinkTools $_})]
#         [FormattedFileSystemPath]$Backuppath
#     )
#     try {
#         $_target1 = [FormattedFileSystemPath]::new($Target1)
#         $_target1_exist = $true
#     }
#     catch [System.Management.Automation.ItemNotFoundException]{
#         $_target1_exist = $false
#     }
#     catch {
#         Write-Logs  "Exception caught: $_"
#     }
#     if ($_target1_exist){
#         if (!$_target1.IsDir){
#             throw "The $_target1 should be a directory"
#         }
#     }

#     try {
#         $_target2 = [FormattedFileSystemPath]::new($Target2)
#         $_target2_exist = $true
#     }
#     catch [System.Management.Automation.ItemNotFoundException]{
#         $_target2_exist = $false
#     }
#     catch {
#         Write-Logs  "Exception caught: $_"
#     }
#     if ($_target2_exist){
#         if (!$_target2.IsDir){
#             throw "The $_target2 should be a directory."
#         }
#     }

#     if($PSCmdlet.ShouldProcess("Merge the content in $_target1 to $_target2, and backup essential items in $Backuppath",'','')){
#         if ($_target1_exist){
#             if ($_target1.IsSymbolicLink -or $_target1.IsJunction){
#                 if ($_target2_exist){
#                     if ($_target2.IsSymbolicLink -or $_target2.IsJunction){
#                         # dir-symbolic-or-hardlink        | dir-symbolic-or-hardlink      | throw error
#                         throw "Cannot merge $_target1 to $_target2, because $_target1 and $_target2 are both symbolic link or junction point."
#                     }else{
#                         # dir-symbolic-or-hardlink        | dir-not-symbolic-or-hardlink  | del $Target1
#                         Write-Logs  "Remove-Item $_target1 -Force -Recurse"
#                         Remove-Item $_target1 -Force -Recurse
#                     }
#                 }else{
#                     # dir-symbolic-or-hardlink        | non-existing          | throw error
#                     throw "Cannot merge $_target1 to $_target2, because $_target2 does not exist."
#                 }
#             }else{
#                 if ($_target2_exist){
#                     if ($_target2.IsSymbolicLink -or $_target2.IsJunction){
#                         # dir-not-symbolic-or-hardlink    | dir-symbolic-or-hardlink      | throw error
#                         throw "Cannot merge $_target1 to $_target2, because $_target1 is not symbolic link or junction point, but $_target2 is."
#                     }else{
#                         #dir-not-symbolic-or-hardlink    | dir-not-symbolic-or-hardlink  | backup $Target1 and $Target2 to $Backuppath, then merge $Target1 to $Target2, then del $Target1
#                         Merge-DirectoryWithBackup -Source $_target1 -Destination $_target2 -Backuppath $Backuppath
#                         Write-Logs  "Remove-Item $_target1 -Force -Recurse"
#                         Remove-Item $_target1 -Force -Recurse
#                     }
#                 }else{
#                     Assert-AdminRobocopyAvailable
#                     # dir-not-symbolic-or-hardlink    | non-existing          | copy $Target1 to $Target2, del $Target1
#                     Write-Logs  "Robocopy $_target1 $_target2"
#                     $log_file = Get-LogFileName "Robocopy Merge-BeforeSetDirLink"
#                     Robocopy $_target1 $_target2  /E /copyall /DCOPY:DATE /LOG:"$log_file"
#                     Write-Logs  "Remove-Item $_target1 -Force -Recurse"
#                     Remove-Item $_target1 -Force -Recurse
#                 }
#             }
#         }else{
#             if ($_target2_exist){
#                 if ($_target2.IsSymbolicLink -or $_target2.IsJunction){
#                     # non-existing            | dir-symbolic-or-hardlink      | throw error
#                     throw "Cannot merge $_target1 to $_target2, because $_target1 does not exist and $_target2 is symbolic link or junction point."
#                 }else{
#                     # non-existing            | dir-not-symbolic-or-hardlink  | pass(do nothing)
#                     Write-Logs  "Do nothing."
#                 }
#             }else{
#                 # non-existing            | non-existing          | pass(do nothing)
#                 Write-Logs  "Do nothing."
#             }
#         }
#     }
# }
# function Move-BeforeSetFileLink{
# <#
# .DESCRIPTION
#     Before setting a file link (Symbolic Link or HardLink)
#     from $Target2 to $Target1, this function should be used to
#     move the file $Target1 to $Target2.

#     Move the file $Target1 to $Target2 by the following rules:
#         $Target1------------------------| $Target2----------------------| Opeartion
#         non-existing                    | non-existing                  | pass(do nothing)
#         non-existing                    | file-symbolic-or-hardlink     | throw error
#         non-existing                    | file-non-symbolic-or-hardlink | pass(do nothing)
#         file-symbolic-or-hardlink       | non-existing                  | throw error
#         file-symbolic-or-hardlink       | file-symbolic-or-hardlink     | throw error
#         file-symbolic-or-hardlink       | file-non-symbolic-or-hardlink | del $Target1
#         file-non-symbolic-or-hardlink   | non-existing                  | copy $Target1 to $Target2, del $Target1
#         file-non-symbolic-or-hardlink   | file-symbolic-or-hardlink     | throw error
#         file-non-symbolic-or-hardlink   | file-non-symbolic-or-hardlink | backup $Target1 and $Target2 to $Backuppath, then del $Target1
# #>
#     [CmdletBinding(SupportsShouldProcess)]
#     param(
#         [Parameter(Mandatory)]
#         [string]$Target1,
#         [Parameter(Mandatory)]
#         [string]$Target2,
#         [Parameter(Mandatory)]
#         [ValidateScript({Test-ValidPath4LinkTools $_})]
#         [FormattedFileSystemPath]$Backuppath
#     )

#     try {
#         $_target1 = [FormattedFileSystemPath]::new($Target1)
#         $_target1_exist = $true
#     }
#     catch [System.Management.Automation.ItemNotFoundException]{
#         $_target1_exist = $false
#     }
#     catch {
#         Write-Logs  "Exception caught: $_"
#     }
#     if ($_target1_exist){
#         if (!$_target1.IsFile){
#             throw "The $_target1 should be a file."
#         }
#     }

#     try {
#         $_target2 = [FormattedFileSystemPath]::new($Target2)
#         $_target2_exist = $true
#     }
#     catch [System.Management.Automation.ItemNotFoundException]{
#         $_target2_exist = $false
#     }
#     catch {
#         Write-Logs  "Exception caught: $_"
#     }
#     if ($_target2_exist){
#         if (!$_target2.IsFile){
#             throw "The $_target2 should be a file."
#         }
#     }

#     if($PSCmdlet.ShouldProcess("Move the content in $_target1 to $_target2, and backup essential items in $Backuppath",'','')){
#         if ($_target1_exist){
#             if ($_target1.IsSymbolicLink -or $_target1.IsHardLink){
#                 if ($_target2_exist){
#                     if ($_target2.IsSymbolicLink -or $_target2.IsHardLink){
#                         # file-symbolic-or-hardlink       | file-symbolic-or-hardlink     | throw error
#                         throw "Cannot move $_target1 to $_target2, because $_target1 and $_target2 are both symbolic link or hard link."
#                     }else{
#                         # file-symbolic-or-hardlink       | file-non-symbolic-or-hardlink | del $Target1
#                         Write-Logs  "Remove-Item $_target1 -Force -Recurse"
#                         Remove-Item $_target1 -Force -Recurse
#                     }
#                 }else{
#                     # file-symbolic-or-hardlink       | non-existing          | throw error
#                     throw "Cannot move $_target1 to $_target2, because $_target1 is symbolic link or hard link while $_target2 does not exist."
#                 }
#             }else{
#                 if ($_target2_exist){
#                     if ($_target2.IsSymbolicLink -or $_target2.IsHardLink){
#                         # file-non-symbolic-or-hardlink   | file-symbolic-or-hardlink     | throw error
#                         throw "Cannot move $_target1 to $_target2, because $_target1 is not symbolic link or hard link while $_target2 is."
#                     }else{
#                         # file-non-symbolic-or-hardlink   | file-non-symbolic-or-hardlink | backup $Target1 and $Target2 to $Backuppath, then del $Target1
#                         Move-FileWithBackup -Source $_target1 -Destination $_target2 -Backuppath $Backuppath
#                         Write-Logs  "Remove-Item $_target1 -Force -Recurse"
#                         Remove-Item $_target1 -Force -Recurse
#                     }
#                 }else{
#                     Assert-AdminRobocopyAvailable
#                     # file-non-symbolic-or-hardlink   | non-existing          | copy $Target1 to $Target2, del $Target1
#                     Write-Logs  "Robocopy $_target1 $_target2"
#                     $log_file = Get-LogFileName "Robocopy Move-BeforeSetFileLink"
#                     Robocopy $_target1 $_target2  /copyall /DCOPY:DATE /LOG:"$log_file"
#                     Write-Logs  "Remove-Item $_target1 -Force -Recurse"
#                     Remove-Item $_target1 -Force -Recurse
#                 }
#             }
#         }else{
#             if ($_target2_exist){
#                 if ($_target2.IsSymbolicLink -or $_target2.IsHardLink){
#                     # non-existing            | file-symbolic-or-hardlink     | throw error
#                     throw "Cannot move $_target1 to $_target2, because $_target1 does not exist and $_target2 is symbolic link or hard link."
#                 }else{
#                     # non-existing            | file-non-symbolic-or-hardlink | pass(do nothing)
#                     Write-Logs  "Do nothing."
#                 }
#             }else{
#                 # non-existing            | non-existing          | pass(do nothing)
#                 Write-Logs  "Do nothing."
#             }
#         }
#     }
# }


function Move-Target2Source4SoftLink{
<#
.SYNOPSIS
    Fro some purposes about setting a soft link (symbolic link or junction point), move the target item to the source, if the target and the source meet some conditions.
    Backup can be conducted when needed.
    Then the target item will be removed, along with some post-processing procedures.
.DESCRIPTION
    When we want to set a soft link (symbolic link or junction point) from `A` to `B`, as `A->B`, we may find that `A` is non-existing while `B` is existing.
    That is not our expectation. We may need to move `B` to `A` at first, then go back to set the link `A->B`.
    Worsely, if we find `A` and `B` are both existing at first, we may need to consider merging or backuping procedures.

    This function can help users to do the above things easily, i.e., it can move the target item to the source automatically, with essential backup.
    It can be used before setting a soft link from the source to the target.
    
.NOTES
    This function is not generic and is more of an integration for a class of business.
    The following are the main rules of this function:
        1. Check the target and source path if they are both in the following conditions:
            non-existing
            existing-simple-file
            existing-simple-directory
            existing-file-symbolic-link
            existing-directory-symbolic-link
            existing-directory-junction-point
        2. There are 6*6=36 combinations of the target and source path. For each combination, we have a specific operation:

            Conditions--|Target-----------------------------| Source--------------------| Opeartion
            1           | non-existing                      | non-existing              | throw error
            1           | non-existing                      | existing-simple-file      | pass(do nothing)
            1           | non-existing                      | existing-simple-directory | pass(do nothing)
            3           | non-existing                      | one of the 3 link types   | throw error
            1           | existing-simple-file              | non-existing              | copy target to source, del target
            1           | existing-simple-file              | existing-simple-file      | backup source, copy target to cover source, del target
            1           | existing-simple-file              | existing-simple-directory | throw error
            3           | existing-simple-file              | one of the 3 link types   | throw error
            1           | existing-simple-directory         | non-existing              | copy target to source, del target
            1           | existing-simple-directory         | existing-simple-file      | throw error
            1           | existing-simple-directory         | existing-simple-directory | backup source, backup target, merge target to source (items within target will cover), del target
            3           | existing-simple-directory         | one of the 3 link types   | throw error
            1           | existing-file-symbolic-link       | non-existing              | throw error
            1           | existing-file-symbolic-link       | existing-simple-file      | del target 
            1           | existing-file-symbolic-link       | existing-simple-directory | throw error
            3           | existing-file-symbolic-link       | one of the 3 link types   | throw error
            1           | existing-directory-symbolic-link  | non-existing              | throw error
            1           | existing-directory-symbolic-link  | existing-simple-file      | throw error
            1           | existing-directory-symbolic-link  | existing-simple-directory | del target
            3           | existing-directory-symbolic-link  | one of the 3 link types   | throw error
            1           | existing-directory-junction-point | non-existing              | throw error
            1           | existing-directory-junction-point | existing-simple-file      | throw error
            1           | existing-directory-junction-point | existing-simple-directory | del target
            3           | existing-directory-junction-point | one of the 3 link types   | throw error
            other conditions out of the above 36 conditions will throw error as well.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [FormattedFileSystemPath]$BackupDir
    )

    try {
        $_target = [FormattedFileSystemPath]::new($Target)
        $_target_exist = $true
        $_target_simple_file = $_target.IsFile -and !($_target.IsSymbolicLink -or $_target.IsHardLink)
        $_target_simple_directory = $_target.IsDir -and !($_target.IsSymbolicLink -or $_target.IsJunction)
        $_target_symbolic_link_file = $_target.IsFile -and $_target.IsSymbolicLink
        $_target_symbolic_link_directory = $_target.IsDir -and $_target.IsSymbolicLink
        $_target_junction_point_directory = $_target.IsDir -and $_target.IsJunction
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        $_target_exist = $false
    }
    catch {
        Write-Logs  "Exception caught: $_"
    }
    try {
        $_source = [FormattedFileSystemPath]::new($Source)
        $_source_exist = $true
        $_source_simple_file = $_source.IsFile -and !($_source.IsSymbolicLink -or $_source.IsHardLink)
        $_source_simple_directory = $_source.IsDir -and !($_source.IsSymbolicLink -or $_source.IsJunction)
        $_source_symbolic_link_file = $_source.IsFile -and $_source.IsSymbolicLink
        $_source_symbolic_link_directory = $_source.IsDir -and $_source.IsSymbolicLink
        $_source_junction_point_directory = $_source.IsDir -and $_source.IsJunction
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        $_source_exist = $false
    }
    catch {
        Write-Logs  "Exception caught: $_"
    }
    $supprted_set_message = "@('non-existing', 'existing-simple-file', 'existing-simple-directory', 'existing-file-symbolic-link', 'existing-directory-symbolic-link', 'existing-directory-junction-point')"
    $indicator = [guid]::NewGuid()
    if (!$_target_exist){
        if(!$_source_exist){
            # 1           | non-existing                      | non-existing              | throw error
            throw "[Non-supported conditions] The $Target and $Source are both non-existing."
        }elseif($_source_simple_file){
            # 1           | non-existing                      | existing-simple-file      | pass(do nothing)
            Write-Logs  "[Do nothing] The $Target is non-existing and the $Source is a simple file already."
        }elseif($_source_simple_directory){
            # 1           | non-existing                      | existing-simple-directory | pass(do nothing)
            Write-Logs  "[Do nothing] The $Target is non-existing and the $Source is a simple directory already."
        }elseif($_source_symbolic_link_file -or $_source_symbolic_link_directory -or $_source_junction_point_directory){
            # 3           | non-existing                      | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is non-existing but the $Source a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is non-existing but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($_target_simple_file){
        if(!$_source_exist){
            # 1           | existing-simple-file              | non-existing              | copy target to source, del target
            Copy-FileWithBackup -Path $Target -Destination $Source -BackupDir $BackupDir -Indicator $indicator
            Write-Logs "Remove-Item -Path $Target -Force"
            Remove-Item -Path $Target -Force
        }elseif($_source_simple_file){
            # 1           | existing-simple-file              | existing-simple-file      | backup source, copy target to cover source, del target
            Copy-FileWithBackup -Path $Target -Destination $Source -BackupDir $BackupDir -Indicator $indicator
            Write-Logs "Remove-Item -Path $Target -Force"
            Remove-Item -Path $Target -Force
        }elseif($_source_simple_directory){
            # 1           | existing-simple-file              | existing-simple-directory | throw error
            throw "[Non-supported conditions] The $Target is a simple file but the $Source is a simple directory."
        }elseif($_source_symbolic_link_file -or $_source_symbolic_link_directory -or $_source_junction_point_directory){
            # 3           | existing-simple-file              | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a simple file but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a simple file but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($_target_simple_directory){
        if(!$_source_exist){
            # 1           | existing-simple-directory         | non-existing              | copy target to source, del target
            Copy-DirWithBackup -Path $Target -Destination $Source -BackupDir $BackupDir -Indicator $indicator
            Write-Logs "Remove-Item -Path $Target -Recurse -Force"
            Remove-Item -Path $Target -Recurse -Force
        }elseif($_source_simple_file){
            # 1           | existing-simple-directory         | existing-simple-file      | throw error
            throw "[Non-supported conditions] The $Target is a simple directory but the $Source is a simple file."
        }elseif($_source_simple_directory){
            # 1           | existing-simple-directory         | existing-simple-directory | backup source, backup target, merge target to source (items within target will cover), del target
            Copy-DirWithBackup -Path $Target -Destination $Source -BackupDir $BackupDir -Indicator $indicator
            Write-Logs "Remove-Item -Path $Target -Recurse -Force"
            Remove-Item -Path $Target -Recurse -Force
        }elseif($_source_symbolic_link_file -or $_source_symbolic_link_directory -or $_source_junction_point_directory){
            # 3           | existing-simple-directory         | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a simple directory but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a simple directory but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($_target_symbolic_link_file){
        if(!$_source_exist){
            # 1           | existing-file-symbolic-link       | non-existing              | throw error
            throw "[Non-supported conditions] The $Target is a file symbolic link but the $Source is non-existing."
        }elseif($_source_simple_file){
            # 1           | existing-file-symbolic-link       | existing-simple-file      | del target
            Write-Logs  "Remove-Item $Target -Force"
            Remove-Item $Target -Force
        }elseif($_source_simple_directory){
            # 1           | existing-file-symbolic-link       | existing-simple-directory | throw error
            throw "[Non-supported conditions] The $Target is a file symbolic link but the $Source is a simple directory."
        }elseif($_source_symbolic_link_file -or $_source_symbolic_link_directory -or $_source_junction_point_directory){
            # 3           | existing-file-symbolic-link       | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a file symbolic link but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a file symbolic link but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($_target_symbolic_link_directory){
        if(!$_source_exist){
            # 1           | existing-directory-symbolic-link  | non-existing              | throw error
            throw "[Non-supported conditions] The $Target is a directory symbolic link but the $Source is non-existing."
        }elseif($_source_simple_file){
            # 1           | existing-directory-symbolic-link  | existing-simple-file      | throw error
            throw "[Non-supported conditions] The $Target is a directory symbolic link but the $Source is a simple file."
        }elseif($_source_simple_directory){
            # 1           | existing-directory-symbolic-link  | existing-simple-directory | del target
            Write-Logs  "Remove-Item $Target -Force"
            Remove-Item $Target -Force
        }elseif($_source_symbolic_link_file -or $_source_symbolic_link_directory -or $_source_junction_point_directory){
            # 3           | existing-directory-symbolic-link  | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a directory symbolic link but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a directory symbolic link but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($_target_junction_point_directory){
        if(!$_source_exist){
            # 1           | existing-directory-junction-point | non-existing              | throw error
            throw "[Non-supported conditions] The $Target is a junction point but the $Source is non-existing."
        }elseif($_source_simple_file){
            # 1           | existing-directory-junction-point | existing-simple-file      | throw error
            throw "[Non-supported conditions] The $Target is a junction point but the $Source is a simple file."
        }elseif($_source_simple_directory){
            # 1           | existing-directory-junction-point | existing-simple-directory | del target
            Write-Logs  "Remove-Item $Target -Force"
            Remove-Item $Target -Force
        }elseif($_source_symbolic_link_file -or $_source_symbolic_link_directory -or $_source_junction_point_directory){
            # 3           | existing-directory-junction-point | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a junction point but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a junction point but the $Source is not in the set of: $supprted_set_message."
        }
    }else{
        throw "The $Target is not in the set of: $supprted_set_message."
    }
}