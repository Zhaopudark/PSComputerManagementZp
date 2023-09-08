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
        # see https://stackoverflow.com/a/77062276/17357963
        [psobject] $target = [FormattedFileSystemPath]::new($Target)
        $target_exist = $true
        $target_simple_file = $target.IsFile -and !($target.IsSymbolicLink -or $target.IsHardLink)
        $target_simple_directory = $target.IsDir -and !($target.IsSymbolicLink -or $target.IsJunction)
        $target_symbolic_link_file = $target.IsFile -and $target.IsSymbolicLink
        $target_symbolic_link_directory = $target.IsDir -and $target.IsSymbolicLink
        $target_junction_point_directory = $target.IsDir -and $target.IsJunction
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        $target_exist = $false
    }
    catch {
        Write-Logs  "Exception caught: $_"
    }
    try {
        # see https://stackoverflow.com/a/77062276/17357963
        [psobject] $source = [FormattedFileSystemPath]::new($Source)
        $source_exist = $true
        $source_simple_file = $source.IsFile -and !($source.IsSymbolicLink -or $source.IsHardLink)
        $source_simple_directory = $source.IsDir -and !($source.IsSymbolicLink -or $source.IsJunction)
        $source_symbolic_link_file = $source.IsFile -and $source.IsSymbolicLink
        $source_symbolic_link_directory = $source.IsDir -and $source.IsSymbolicLink
        $source_junction_point_directory = $source.IsDir -and $source.IsJunction
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        $source_exist = $false
    }
    catch {
        Write-Logs  "Exception caught: $_"
    }
    $supprted_set_message = "@('non-existing', 'existing-simple-file', 'existing-simple-directory', 'existing-file-symbolic-link', 'existing-directory-symbolic-link', 'existing-directory-junction-point')"
    $indicator = [guid]::NewGuid()
    if (!$target_exist){
        if(!$source_exist){
            # 1           | non-existing                      | non-existing              | throw error
            throw "[Non-supported conditions] The $Target and $Source are both non-existing."
        }elseif($source_simple_file){
            # 1           | non-existing                      | existing-simple-file      | pass(do nothing)
            Write-Logs  "[Do nothing] The $Target is non-existing and the $Source is a simple file already."
        }elseif($source_simple_directory){
            # 1           | non-existing                      | existing-simple-directory | pass(do nothing)
            Write-Logs  "[Do nothing] The $Target is non-existing and the $Source is a simple directory already."
        }elseif($source_symbolic_link_file -or $source_symbolic_link_directory -or $source_junction_point_directory){
            # 3           | non-existing                      | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is non-existing but the $Source a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is non-existing but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($target_simple_file){
        if(!$source_exist){
            # 1           | existing-simple-file              | non-existing              | copy target to source, del target
            Copy-FileWithBackup -Path $Target -Destination $Source -BackupDir $BackupDir -Indicator $indicator
            Write-Logs "Remove-Item -Path $Target -Force"
            Remove-Item -Path $Target -Force
        }elseif($source_simple_file){
            # 1           | existing-simple-file              | existing-simple-file      | backup source, copy target to cover source, del target
            Copy-FileWithBackup -Path $Target -Destination $Source -BackupDir $BackupDir -Indicator $indicator
            Write-Logs "Remove-Item -Path $Target -Force"
            Remove-Item -Path $Target -Force
        }elseif($source_simple_directory){
            # 1           | existing-simple-file              | existing-simple-directory | throw error
            throw "[Non-supported conditions] The $Target is a simple file but the $Source is a simple directory."
        }elseif($source_symbolic_link_file -or $source_symbolic_link_directory -or $source_junction_point_directory){
            # 3           | existing-simple-file              | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a simple file but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a simple file but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($target_simple_directory){
        if(!$source_exist){
            # 1           | existing-simple-directory         | non-existing              | copy target to source, del target
            Copy-DirWithBackup -Path $Target -Destination $Source -BackupDir $BackupDir -Indicator $indicator
            Write-Logs "Remove-Item -Path $Target -Recurse -Force"
            Remove-Item -Path $Target -Recurse -Force
        }elseif($source_simple_file){
            # 1           | existing-simple-directory         | existing-simple-file      | throw error
            throw "[Non-supported conditions] The $Target is a simple directory but the $Source is a simple file."
        }elseif($source_simple_directory){
            # 1           | existing-simple-directory         | existing-simple-directory | backup source, backup target, merge target to source (items within target will cover), del target
            Copy-DirWithBackup -Path $Target -Destination $Source -BackupDir $BackupDir -Indicator $indicator
            Write-Logs "Remove-Item -Path $Target -Recurse -Force"
            Remove-Item -Path $Target -Recurse -Force
        }elseif($source_symbolic_link_file -or $source_symbolic_link_directory -or $source_junction_point_directory){
            # 3           | existing-simple-directory         | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a simple directory but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a simple directory but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($target_symbolic_link_file){
        if(!$source_exist){
            # 1           | existing-file-symbolic-link       | non-existing              | throw error
            throw "[Non-supported conditions] The $Target is a file symbolic link but the $Source is non-existing."
        }elseif($source_simple_file){
            # 1           | existing-file-symbolic-link       | existing-simple-file      | del target
            Write-Logs  "Remove-Item $Target -Force"
            Remove-Item $Target -Force
        }elseif($source_simple_directory){
            # 1           | existing-file-symbolic-link       | existing-simple-directory | throw error
            throw "[Non-supported conditions] The $Target is a file symbolic link but the $Source is a simple directory."
        }elseif($source_symbolic_link_file -or $source_symbolic_link_directory -or $source_junction_point_directory){
            # 3           | existing-file-symbolic-link       | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a file symbolic link but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a file symbolic link but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($target_symbolic_link_directory){
        if(!$source_exist){
            # 1           | existing-directory-symbolic-link  | non-existing              | throw error
            throw "[Non-supported conditions] The $Target is a directory symbolic link but the $Source is non-existing."
        }elseif($source_simple_file){
            # 1           | existing-directory-symbolic-link  | existing-simple-file      | throw error
            throw "[Non-supported conditions] The $Target is a directory symbolic link but the $Source is a simple file."
        }elseif($source_simple_directory){
            # 1           | existing-directory-symbolic-link  | existing-simple-directory | del target
            Write-Logs  "Remove-Item $Target -Force"
            Remove-Item $Target -Force
        }elseif($source_symbolic_link_file -or $source_symbolic_link_directory -or $source_junction_point_directory){
            # 3           | existing-directory-symbolic-link  | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a directory symbolic link but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a directory symbolic link but the $Source is not in the set of: $supprted_set_message."
        }
    }elseif($target_junction_point_directory){
        if(!$source_exist){
            # 1           | existing-directory-junction-point | non-existing              | throw error
            throw "[Non-supported conditions] The $Target is a junction point but the $Source is non-existing."
        }elseif($source_simple_file){
            # 1           | existing-directory-junction-point | existing-simple-file      | throw error
            throw "[Non-supported conditions] The $Target is a junction point but the $Source is a simple file."
        }elseif($source_simple_directory){
            # 1           | existing-directory-junction-point | existing-simple-directory | del target
            Write-Logs  "Remove-Item $Target -Force"
            Remove-Item $Target -Force
        }elseif($source_symbolic_link_file -or $source_symbolic_link_directory -or $source_junction_point_directory){
            # 3           | existing-directory-junction-point | one of the 3 link types   | throw error
            throw "[Non-supported conditions] The $Target is a junction point but the $Source is a soft link."
        }else{
            throw "[Non-supported conditions] The $Target is a junction point but the $Source is not in the set of: $supprted_set_message."
        }
    }else{
        throw "The $Target is not in the set of: $supprted_set_message."
    }
}