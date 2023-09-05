function Test-ValidPath4LinkTools{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [FormattedFileSystemPath]$Path,
        [switch]$File
    )
    if($File){
        if(!$Path.IsFile){
            throw "The $Path should be a file."
        }
    }else{
        if(!$Path.IsDir){
            throw "The $Path should be a directory."
        }
    }

    if($Path.IsSymbolicLink -or $Path.IsJunction){
        throw "The $Path should not be a symbolic link or junction point."
    }
    return $true
}


function Merge-DirectoryWithBackup{
<#
.DESCRIPTION
    Backup $Source to a path based on $Backuppath
    Backup $Destination to a path based on $Backuppath
    Then, merge items from $Source to $Destination
    Record logs
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-ValidPath4LinkTools $_})]
        [FormattedFileSystemPath]$Source,
        [Parameter(Mandatory)]
        [ValidateScript({Test-ValidPath4LinkTools $_})]
        [FormattedFileSystemPath]$Destination,
        [Parameter(Mandatory)]
        [ValidateScript({Test-ValidPath4LinkTools $_})]
        [FormattedFileSystemPath]$Backuppath
    )

    $guid = [guid]::NewGuid()
    $source_name = $Source.ToShortName()
    $backup_source = "$Backuppath/$guid-$source_name"
    $destination_name = $Destination.ToShortName()
    $backup_destination = "$Backuppath/$guid-$destination_name"
    $log_file = Get-LogFileName "Robocopy Merge-DirectoryWithBackup"
    if($PSCmdlet.ShouldProcess(
        "Backup $Source to $backup_source"+[Environment]::NewLine+
        "Backup $Destination to $backup_destination"+[Environment]::NewLine+
        "Then, merge items from $Source to $Destination"+[Environment]::NewLine+
        "Record logs to $log_file",'',''))
    {
        Assert-AdminRobocopyAvailable
        Robocopy $Source $backup_source /E /copyall /DCOPY:DATE /LOG:"$log_file"
        Robocopy $Destination $backup_destination /E /copyall /DCOPY:DATE /LOG:"$log_file"
        Robocopy $Source $Destination /E /copyall /DCOPY:DATE /LOG:"$log_file"
    }

}
function Move-FileWithBackup{
<#
.DESCRIPTION
    Backup $Source to a path based on $Backuppath
    Backup $Destination to a path based on $Backuppath
    Then, move $Source to $Destination
    Record logs
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-ValidPath4LinkTools $_ -File})]
        [FormattedFileSystemPath]$Source,
        [Parameter(Mandatory)]
        [ValidateScript({Test-ValidPath4LinkTools $_ -File})]
        [FormattedFileSystemPath]$Destination,
        [Parameter(Mandatory)]
        [ValidateScript({Test-ValidPath4LinkTools $_})]
        [FormattedFileSystemPath]$Backuppath
    )
    $guid = [guid]::NewGuid()
    $source_name = $Source.ToShortName()
    $backup_source = "$Backuppath/$guid-$source_name"
    $destination_name = $Destination.ToShortName()
    $backup_destination = "$Backuppath/$guid-$destination_name"
    $log_file = Get-LogFileName
    if($PSCmdlet.ShouldProcess(
        "Backup $Source to $backup_source"+[Environment]::NewLine+
        "Backup $Destination to $backup_destination"+[Environment]::NewLine+
        "Then, move $Source to $Destination"+[Environment]::NewLine+
        "Record logs to $log_file",'',''))
    {
        Write-Logs (Copy-Item $Source $backup_source)
        Write-Logs (Copy-Item $Destination $backup_destination)
        Write-Logs (Copy-Item $Source $Destination)
    }
}
function Merge-BeforeSetDirLink{
<#
.DESCRIPTION
    Before setting a directory link (Symbolic Link or Junction)
    from $Target2 to $Target1, this function should be used to
    merge the content in $Target1 to $Target2.

    Merge form $Target1 to $Target2 by the following rules:
        $Target1------------------------| $Target2----------------------| Opeartion
        non-existent                    | non-existent                  | pass(do nothing)
        non-existent                    | dir-symbolic-or-hardlink      | throw error
        non-existent                    | dir-not-symbolic-or-hardlink  | pass(do nothing)
        dir-symbolic-or-hardlink        | non-existent                  | throw error
        dir-symbolic-or-hardlink        | dir-symbolic-or-hardlink      | throw error
        dir-symbolic-or-hardlink        | dir-not-symbolic-or-hardlink  | del $Target1
        dir-not-symbolic-or-hardlink    | non-existent                  | copy $Target1 to $Target2, del $Target1
        dir-not-symbolic-or-hardlink    | dir-symbolic-or-hardlink      | throw error
        dir-not-symbolic-or-hardlink    | dir-not-symbolic-or-hardlink  | backup $Target1 and $Target2 to $Backuppath, then merge $Target1 to $Target2, then del $Target1
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Target1,
        [Parameter(Mandatory)]
        [string]$Target2,
        [Parameter(Mandatory)]
        [ValidateScript({Test-ValidPath4LinkTools $_})]
        [FormattedFileSystemPath]$Backuppath
    )
    try {
        $_target1 = [FormattedFileSystemPath]::new($Target1)
        $_target1_exist = $true
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        $_target1_exist = $false
    }
    catch {
        Write-Logs  "Exception caught: $_"
    }
    if ($_target1_exist){
        if (!$_target1.IsDir){
            throw "The $_target1 should be a directory"
        }
    }

    try {
        $_target2 = [FormattedFileSystemPath]::new($Target2)
        $_target2_exist = $true
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        $_target2_exist = $false
    }
    catch {
        Write-Logs  "Exception caught: $_"
    }
    if ($_target2_exist){
        if (!$_target2.IsDir){
            throw "The $_target2 should be a directory."
        }
    }

    if($PSCmdlet.ShouldProcess("Merge the content in $_target1 to $_target2, and backup essential items in $Backuppath",'','')){
        if ($_target1_exist){
            if ($_target1.IsSymbolicLink -or $_target1.IsJunction){
                if ($_target2_exist){
                    if ($_target2.IsSymbolicLink -or $_target2.IsJunction){
                        # dir-symbolic-or-hardlink        | dir-symbolic-or-hardlink      | throw error
                        throw "Cannot merge $_target1 to $_target2, because $_target1 and $_target2 are both symbolic link or junction point."
                    }else{
                        # dir-symbolic-or-hardlink        | dir-not-symbolic-or-hardlink  | del $Target1
                        Write-Logs  "Remove-Item $_target1 -Force -Recurse"
                        Remove-Item $_target1 -Force -Recurse
                    }
                }else{
                    # dir-symbolic-or-hardlink        | non-existent          | throw error
                    throw "Cannot merge $_target1 to $_target2, because $_target2 does not exist."
                }
            }else{
                if ($_target2_exist){
                    if ($_target2.IsSymbolicLink -or $_target2.IsJunction){
                        # dir-not-symbolic-or-hardlink    | dir-symbolic-or-hardlink      | throw error
                        throw "Cannot merge $_target1 to $_target2, because $_target1 is not symbolic link or junction point, but $_target2 is."
                    }else{
                        #dir-not-symbolic-or-hardlink    | dir-not-symbolic-or-hardlink  | backup $Target1 and $Target2 to $Backuppath, then merge $Target1 to $Target2, then del $Target1
                        Merge-DirectoryWithBackup -Source $_target1 -Destination $_target2 -Backuppath $Backuppath
                        Write-Logs  "Remove-Item $_target1 -Force -Recurse"
                        Remove-Item $_target1 -Force -Recurse
                    }
                }else{
                    Assert-AdminRobocopyAvailable
                    # dir-not-symbolic-or-hardlink    | non-existent          | copy $Target1 to $Target2, del $Target1
                    Write-Logs  "Robocopy $_target1 $_target2"
                    $log_file = Get-LogFileName "Robocopy Merge-BeforeSetDirLink"
                    Robocopy $_target1 $_target2  /E /copyall /DCOPY:DATE /LOG:"$log_file"
                    Write-Logs  "Remove-Item $_target1 -Force -Recurse"
                    Remove-Item $_target1 -Force -Recurse
                }
            }
        }else{
            if ($_target2_exist){
                if ($_target2.IsSymbolicLink -or $_target2.IsJunction){
                    # non-existent            | dir-symbolic-or-hardlink      | throw error
                    throw "Cannot merge $_target1 to $_target2, because $_target1 does not exist and $_target2 is symbolic link or junction point."
                }else{
                    # non-existent            | dir-not-symbolic-or-hardlink  | pass(do nothing)
                    Write-Logs  "Do nothing."
                }
            }else{
                # non-existent            | non-existent          | pass(do nothing)
                Write-Logs  "Do nothing."
            }
        }
    }
}
function Move-BeforeSetFileLink{
<#
.DESCRIPTION
    Before setting a file link (Symbolic Link or HardLink)
    from $Target2 to $Target1, this function should be used to
    move the file $Target1 to $Target2.

    Move the file $Target1 to $Target2 by the following rules:
        $Target1------------------------| $Target2----------------------| Opeartion
        non-existent                    | non-existent                  | pass(do nothing)
        non-existent                    | file-symbolic-or-hardlink     | throw error
        non-existent                    | file-non-symbolic-or-hardlink | pass(do nothing)
        file-symbolic-or-hardlink       | non-existent                  | throw error
        file-symbolic-or-hardlink       | file-symbolic-or-hardlink     | throw error
        file-symbolic-or-hardlink       | file-non-symbolic-or-hardlink | del $Target1
        file-non-symbolic-or-hardlink   | non-existent                  | copy $Target1 to $Target2, del $Target1
        file-non-symbolic-or-hardlink   | file-symbolic-or-hardlink     | throw error
        file-non-symbolic-or-hardlink   | file-non-symbolic-or-hardlink | backup $Target1 and $Target2 to $Backuppath, then del $Target1
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Target1,
        [Parameter(Mandatory)]
        [string]$Target2,
        [Parameter(Mandatory)]
        [ValidateScript({Test-ValidPath4LinkTools $_})]
        [FormattedFileSystemPath]$Backuppath
    )

    try {
        $_target1 = [FormattedFileSystemPath]::new($Target1)
        $_target1_exist = $true
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        $_target1_exist = $false
    }
    catch {
        Write-Logs  "Exception caught: $_"
    }
    if ($_target1_exist){
        if (!$_target1.IsFile){
            throw "The $_target1 should be a file."
        }
    }

    try {
        $_target2 = [FormattedFileSystemPath]::new($Target2)
        $_target2_exist = $true
    }
    catch [System.Management.Automation.ItemNotFoundException]{
        $_target2_exist = $false
    }
    catch {
        Write-Logs  "Exception caught: $_"
    }
    if ($_target2_exist){
        if (!$_target2.IsFile){
            throw "The $_target2 should be a file."
        }
    }

    if($PSCmdlet.ShouldProcess("Move the content in $_target1 to $_target2, and backup essential items in $Backuppath",'','')){
        if ($_target1_exist){
            if ($_target1.IsSymbolicLink -or $_target1.IsHardLink){
                if ($_target2_exist){
                    if ($_target2.IsSymbolicLink -or $_target2.IsHardLink){
                        # file-symbolic-or-hardlink       | file-symbolic-or-hardlink     | throw error
                        throw "Cannot move $_target1 to $_target2, because $_target1 and $_target2 are both symbolic link or hard link."
                    }else{
                        # file-symbolic-or-hardlink       | file-non-symbolic-or-hardlink | del $Target1
                        Write-Logs  "Remove-Item $_target1 -Force -Recurse"
                        Remove-Item $_target1 -Force -Recurse
                    }
                }else{
                    # file-symbolic-or-hardlink       | non-existent          | throw error
                    throw "Cannot move $_target1 to $_target2, because $_target1 is symbolic link or hard link while $_target2 does not exist."
                }
            }else{
                if ($_target2_exist){
                    if ($_target2.IsSymbolicLink -or $_target2.IsHardLink){
                        # file-non-symbolic-or-hardlink   | file-symbolic-or-hardlink     | throw error
                        throw "Cannot move $_target1 to $_target2, because $_target1 is not symbolic link or hard link while $_target2 is."
                    }else{
                        # file-non-symbolic-or-hardlink   | file-non-symbolic-or-hardlink | backup $Target1 and $Target2 to $Backuppath, then del $Target1
                        Move-FileWithBackup -Source $_target1 -Destination $_target2 -Backuppath $Backuppath
                        Write-Logs  "Remove-Item $_target1 -Force -Recurse"
                        Remove-Item $_target1 -Force -Recurse
                    }
                }else{
                    Assert-AdminRobocopyAvailable
                    # file-non-symbolic-or-hardlink   | non-existent          | copy $Target1 to $Target2, del $Target1
                    Write-Logs  "Robocopy $_target1 $_target2"
                    $log_file = Get-LogFileName "Robocopy Move-BeforeSetFileLink"
                    Robocopy $_target1 $_target2  /copyall /DCOPY:DATE /LOG:"$log_file"
                    Write-Logs  "Remove-Item $_target1 -Force -Recurse"
                    Remove-Item $_target1 -Force -Recurse
                }
            }
        }else{
            if ($_target2_exist){
                if ($_target2.IsSymbolicLink -or $_target2.IsHardLink){
                    # non-existent            | file-symbolic-or-hardlink     | throw error
                    throw "Cannot move $_target1 to $_target2, because $_target1 does not exist and $_target2 is symbolic link or hard link."
                }else{
                    # non-existent            | file-non-symbolic-or-hardlink | pass(do nothing)
                    Write-Logs  "Do nothing."
                }
            }else{
                # non-existent            | non-existent          | pass(do nothing)
                Write-Logs  "Do nothing."
            }
        }
    }
}