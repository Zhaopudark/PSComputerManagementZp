function Copy-FileWithBackup{
<#
.DESCRIPTION
    Copy a simple file to a destination.
    If the destination exists, the source file will cover the destination file.
    Before the covering, the destination file will be backup to a directory.
.NOTES
    Only support a simple file.
    Do not support a directory, a file symbolic link, or a hard link.
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
    $_source = $Path
    $_destination = $Destination
    if ($PSCmdlet.ShouldProcess("Then copy $_source to $_destination. Backup $_destination if it exists already.",'','')){
        if(Test-Path $_destination){
            $_destination = Get-FormattedFileSystemPath -Path $_destination
            if(!$_destination.IsFile){
                throw "The $_destination should be a file."
            }
            if($_destination.IsSymbolicLink -or $_destination.IsHardLink){
                throw "The $_destination should not be a symbolic link or a hard link."
            }
            $_destination_backup = "$BackupDir/$Indicator-$($_destination.ToShortName())"
            Write-Logs "Copy-Item -Path $_destination -Destination $_destination_backup -Force"
            Copy-Item -Path $_destination -Destination $_destination_backup -Force
        }else{
            Write-Logs "Copy-Item -Path $_source -Destination $_destination -Force"
            Copy-Item -Path $_source -Destination $_destination -Force
        }
    }
}

function Copy-DirWithBackup{
<#
.DESCRIPTION
    Copy a simple directory to a destination.
    If the destination exists, the source directory will be merged to the destination directory.
    Before the merging, both the source and destination will be backup to a directory.
.NOTES
    Only support a simple directory.
    Do not support a file, a directory symbolic link, or a junction point.
    Try Robocopy first, if failed, use Copy-Item instead. But Copy-Item will loss the metadata of directories in the source.
    Patched to avoid Copy-Item's ambiguity:
        If the destination is existing, Copy-Item will merge the source to the destination. (Items within the source will be copied and to the destination, covering the existing items with the same name.)
        If the destination is non-existing, Copy-Item will create a new directory with the source's name.
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
    $_source = $Path
    $_destination = $Destination
    if ($PSCmdlet.ShouldProcess("Then copy $_source to $_destination. Backup $_source and $_destination if the latter exists already.",'','')){
        if(Test-Path $_destination){
            $_source_backup = "$BackupDir/$Indicator-$($_source.ToShortName())"

            $_destination = Get-FormattedFileSystemPath -Path $_destination
            if(!$_destination.IsDir){
                throw "The $_destination should be a directory."
            }
            if($_destination.IsSymbolicLink -or $_destination.IsJunction){
               throw "The $_destination should not be a symbolic link or a junction point."
            }
            $_destination_backup = "$BackupDir/$Indicator-$($_destination.ToShortName())"
            try {
                Assert-AdminRobocopyAvailable
                $log_file = Get-LogFileName "Robocopy Copy-DirWithBackup"
                Robocopy $_source $_source_backup /e /copyall /dcopy:DATE /log+:"$log_file"
                Robocopy $_destination $_destination_backup /e /copyall /dcopy:DATE /log+:"$log_file"
                Robocopy $_source $_destination /e /copyall /dcopy:DATE /log+:"$log_file"
                # https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy
                # /e	            Copies subdirectories. This option automatically includes empty directories.
                # /copyall	        Copies all file information (equivalent to /copy:DATSOU).
                # /dcopy:DATE       Specifies what to copy in directories. D-Data A-Attributes T-Time stamps E-Extended attribute
                # /log+:<logfile>	Writes the status output to the log file (appends the output to the existing log file).
            }
            catch {
                Write-Logs "[Try Robocopy Failed] Use Copy-Item instead. But Copy-Item will loss the metadata of directories in the source."
                
                New-Item -Path $_source_backup -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                Write-Logs " Copy-Item -Path `"$_source\*`" -Destination $_source_backup -Recurse -Force"
                Copy-Item -Path "$_source\*" -Destination $_source_backup -Recurse -Force

                New-Item -Path $_destination_backup -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                Write-Logs "Copy-Item -Path `"$_destination\*`" -Destination $_destination_backup -Recurse -Force"
                Copy-Item -Path "$_destination\*" -Destination $_destination_backup -Recurse -Force

                Write-Logs "Copy-Item -Path `"$_source\*`" -Destination $_destination -Recurse -Force"
                Copy-Item -Path "$_source\*" -Destination $_destination -Recurse -Force
            }
        }else{
            Write-Logs "Copy-Item -Path $_source -Destination $_destination -Recurse -Force"
            Copy-Item -Path $_source -Destination $_destination -Recurse -Force
        }
    }
}