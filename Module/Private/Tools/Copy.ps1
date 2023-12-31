function Copy-FileWithBackup{
<#
.DESCRIPTION
    Copy a simple file to a destination. If the destination exists, the source file will cover the destination file. Before the covering, the destination file will be backup to a directory.
.PARAMETER Path
    The source file path.
.PARAMETER Destination
    The destination file path.
.PARAMETER BackupDir
    The backup directory path.
.PARAMETER Indicator
    The indicator string to indicate the backup file.
.INPUTS
    String or FormattedFileSystemPath.
    String.
    String or FormattedFileSystemPath.
    String.
.OUTPUTS
    None.
.NOTES
    Only support a simple file.
    Do not support a directory, a file symbolic link, or a hard link.
.LINK
    [Type assignment/converting](https://stackoverflow.com/a/77062276/17357963).
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [FormattedFileSystemPath]$Path,
        [Parameter(Mandatory)]
        [string]$Destination,
        [Parameter(Mandatory)]
        [FormattedFileSystemPath]$BackupDir,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Indicator
    )
    if(!$Path.IsFile){
        throw "The $Path should be a file."
    }
    if($Path.IsSymbolicLink -or $Path.IsHardLink){
        throw "The $Path should not be a symbolic link or a hard link."
    }
    $source = $Path
    $destination = $Destination
    if ($PSCmdlet.ShouldProcess("Then copy $source to $destination. Backup $destination if it exists already.",'','')){
        if(Test-Path $destination){
            [psobject] $destination = [FormattedFileSystemPath]::new($destination)
            if(!$destination.IsFile){
                throw "The $destination should be a file."
            }
            if($destination.IsSymbolicLink -or $destination.IsHardLink){
                throw "The $destination should not be a symbolic link or a hard link."
            }
            $destination_backup = "$BackupDir/$Indicator-$($destination.ToShortName())"
            Write-Log "Copy-Item -Path $destination -Destination $destination_backup -Force"
            Copy-Item -Path $destination -Destination $destination_backup -Force
        }else{
            Write-Log "Copy-Item -Path $source -Destination $destination -Force"
            Copy-Item -Path $source -Destination $destination -Force
        }
    }
}

function Copy-DirWithBackup{
<#
.DESCRIPTION
    Copy a simple directory to a destination.
    If the destination exists, the source directory will be merged to the destination directory.
    Before the merging, both the source and destination will be backup to a directory.
.PARAMETER Path
    The source directory path.
.PARAMETER Destination
    The destination directory path.
.PARAMETER BackupDir
    The backup directory path.
.PARAMETER Indicator
    The indicator string to indicate the backup directory.
.INPUTS
    String or FormattedFileSystemPath.
    String.
    String or FormattedFileSystemPath.
    String.
.OUTPUTS
    None.
.NOTES
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
.LINK
    [Type assignment/converting](https://stackoverflow.com/a/77062276/17357963).
    [Robocopy](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy).
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [FormattedFileSystemPath]$Path,
        [Parameter(Mandatory)]
        [string]$Destination,
        [Parameter(Mandatory)]
        [FormattedFileSystemPath]$BackupDir,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Indicator
    )
    if(!$Path.IsDir){
        throw "The $Path should be a directory."
    }
    if($Path.IsSymbolicLink -or $Path.IsJunction){
        throw "The $Path should not be a symbolic link or a junction point."
    }
    $source = $Path
    $destination = $Destination
    if ($PSCmdlet.ShouldProcess("Then copy $source to $destination. Backup $source and $destination if the latter exists already.",'','')){
        if(Test-Path $destination){
            $source_backup = "$BackupDir/$Indicator-$($source.ToShortName())"
            [psobject] $destination = [FormattedFileSystemPath]::new($destination)
            if(!$destination.IsDir){
                throw "The $destination should be a directory."
            }
            if($destination.IsSymbolicLink -or $destination.IsJunction){
               throw "The $destination should not be a symbolic link or a junction point."
            }
            $destination_backup = "$BackupDir/$Indicator-$($destination.ToShortName())"
            try {
                Assert-AdminRobocopyAvailable
                $log_file = Get-LogFileNameWithKeyInfo "Robocopy Copy-DirWithBackup"
                Robocopy $source $source_backup /e /copyall /dcopy:DATE /log+:"$log_file"
                Robocopy $destination $destination_backup /e /copyall /dcopy:DATE /log+:"$log_file"
                Robocopy $source $destination /e /copyall /dcopy:DATE /log+:"$log_file"
            }
            catch {
                Write-Log "[Try Robocopy Failed] Use Copy-Item instead. But Copy-Item will loss the metadata of directories in the source."

                New-Item -Path $source_backup -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                Write-Log " Copy-Item -Path `"$source\*`" -Destination $source_backup -Recurse -Force"
                Copy-Item -Path "$source\*" -Destination $source_backup -Recurse -Force

                New-Item -Path $destination_backup -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                Write-Log "Copy-Item -Path `"$destination\*`" -Destination $destination_backup -Recurse -Force"
                Copy-Item -Path "$destination\*" -Destination $destination_backup -Recurse -Force

                Write-Log "Copy-Item -Path `"$source\*`" -Destination $destination -Recurse -Force"
                Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force
            }
        }else{
            Write-Log "Copy-Item -Path $source -Destination $destination -Recurse -Force"
            Copy-Item -Path $source -Destination $destination -Recurse -Force
        }
    }
}