function Test-EnvPathLevelArg{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [string]$Level
    )
    if ($Level -notin @('User','Process','Machine')){
        throw "The arg `$Level should be one of 'User','Process','Machine', not $Level."
    }elseif (($Level -eq 'Machine') -and (Test-Platform 'Windows')){
        return Assert-AdminPermission
    }else{
        if (((Test-Platform 'Wsl2') -or (Test-Platform 'Linux'))`
            -and (($Level -eq 'User') -or ($Level -eq 'Machine'))){
            Write-VerboseLog  "The 'User' or 'Machine' level `$Env:PATH in current platform, $($PSVersionTable.Platform), are not supported. They can be get or set but this means nothing."
        }
        return $true
    }
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
        [ValidateScript({Assert-IsDirectory $_ -and Assert-NotSymbolicOrJunction $_})]
        [string]$Source,
        [Parameter(Mandatory)]
        [ValidateScript({Assert-IsDirectory $_ -and Assert-NotSymbolicOrJunction $_})]
        [string]$Destination,
        [Parameter(Mandatory)]
        [ValidateScript({Assert-IsDirectory $_ -and Assert-NotSymbolicOrJunction $_})]
        [string]$Backuppath
    )
    $guid = [guid]::NewGuid()
    $source_name = $Source -replace ':', '-' -replace '\\', '-' -replace '/', '-' -replace '--','-' -replace '--','-'
    $backup_source = "$Backuppath/$guid-$source_name"
    $destination_name = $Destination -replace ':', '-' -replace '\\', '-' -replace '/', '-' -replace '--','-' -replace '--','-'
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
        [ValidateScript({Assert-IsFile $_ -and Assert-NotSymbolicOrJunction $_})]
        [string]$Source,
        [Parameter(Mandatory)]
        [ValidateScript({Assert-IsFile $_ -and Assert-NotSymbolicOrJunction $_})]
        [string]$Destination,
        [Parameter(Mandatory)]
        [ValidateScript({Assert-IsDirectory $_ -and Assert-NotSymbolicOrJunction $_})]
        [string]$Backuppath
    )
    $guid = [guid]::NewGuid()
    $source_name = $Source -replace ':', '-' -replace '\\', '-' -replace '/', '-' -replace '--','-' -replace '--','-'
    $backup_source = "$Backuppath/$guid-$source_name"
    $destination_name = $Destination -replace ':', '-' -replace '\\', '-' -replace '/', '-' -replace '--','-' -replace '--','-'
    $backup_destination = "$Backuppath/$guid-$destination_name"
    $log_file = Get-LogFileName
    if($PSCmdlet.ShouldProcess(
        "Backup $Source to $backup_source"+[Environment]::NewLine+
        "Backup $Destination to $backup_destination"+[Environment]::NewLine+
        "Then, move $Source to $Destination"+[Environment]::NewLine+
        "Record logs to $log_file",'',''))
    {
        Write-VerboseLog (Copy-Item $Source $backup_source)
        Write-VerboseLog (Copy-Item $Destination $backup_destination)
        Write-VerboseLog (Copy-Item $Source $Destination)
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
        non-existent                    | non-existent                  | New-item $Target2 -Itemtype Directory
        non-existent                    | dir-symbolic-or-junction      | throw error
        non-existent                    | dir-not-symbolic-or-junction  | pass(do nothing)
        dir-symbolic-or-junction        | non-existent                  | throw error
        dir-symbolic-or-junction        | dir-symbolic-or-junction      | throw error
        dir-symbolic-or-junction        | dir-not-symbolic-or-junction  | del $Target1
        dir-not-symbolic-or-junction    | non-existent                  | copy $Target1 to $Target2, del $Target1
        dir-not-symbolic-or-junction    | dir-symbolic-or-junction      | throw error
        dir-not-symbolic-or-junction    | dir-not-symbolic-or-junction  | backup $Target1 and $Target2 to $Backuppath, then merge $Target1 to $Target2, then del $Target1
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Target1,
        [Parameter(Mandatory)]
        [string]$Target2,
        [Parameter(Mandatory)]
        [string]$Backuppath
    )
    if($PSCmdlet.ShouldProcess("Merge the content in $Target1 to $Target2, and backup essential items in $Backuppath",'','')){
        if (Test-Path -LiteralPath $Target1){
            if (Test-IsSymbolicOrJunction $Target1){
                if (Test-Path -LiteralPath $Target2){
                    if (Test-IsSymbolicOrJunction $Target2){
                        # dir-symbolic-or-junction        | dir-symbolic-or-junction      | throw error
                        throw "Cannot merge $Target1 to $Target2, because $Target1 and $Target2 are both symbolic link or junction point."
                    }else{
                        # dir-symbolic-or-junction        | dir-not-symbolic-or-junction  | del $Target1
                        Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                        Remove-Item $Target1 -Force -Recurse
                    }
                }else{
                    # dir-symbolic-or-junction        | non-existent          | throw error
                    throw "Cannot merge $Target1 to $Target2, because $Target2 does not exist."
                }
            }else{
                if (Test-Path -LiteralPath $Target2){
                    if (Test-IsSymbolicOrJunction $Target2){
                        # dir-not-symbolic-or-junction    | dir-symbolic-or-junction      | throw error
                        throw "Cannot merge $Target1 to $Target2, because $Target1 is not symbolic link or junction point, but $Target2 is."
                    }else{
                        #dir-not-symbolic-or-junction    | dir-not-symbolic-or-junction  | backup $Target1 and $Target2 to $Backuppath, then merge $Target1 to $Target2, then del $Target1
                        Merge-DirectoryWithBackup -Source $Target1 -Destination $Target2 -Backuppath $Backuppath
                        Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                        Remove-Item $Target1 -Force -Recurse
                    }
                }else{
                    Assert-AdminRobocopyAvailable
                    # dir-not-symbolic-or-junction    | non-existent          | copy $Target1 to $Target2, del $Target1
                    Write-VerboseLog  "Robocopy $Target1 $Target2"
                    $log_file = Get-LogFileName "Robocopy Merge-BeforeSetDirLink"
                    Robocopy $Target1 $Target2  /E /copyall /DCOPY:DATE /LOG:"$log_file"
                    Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                    Remove-Item $Target1 -Force -Recurse
                }
            }
        }else{
            if (Test-Path -LiteralPath $Target2){
                if (Test-IsSymbolicOrJunction $Target2){
                    # non-existent            | dir-symbolic-or-junction      | throw error
                    throw "Cannot merge $Target1 to $Target2, because $Target1 does not exist and $Target2 is symbolic link or junction point."
                }else{
                    # non-existent            | dir-not-symbolic-or-junction  | pass(do nothing)
                    Write-VerboseLog  "Do nothing."
                }
            }else{
                # non-existent            | non-existent          | New-item $Target2 -Itemtype Directory
                Write-VerboseLog  "New-Item $Target2 -ItemType Directory"
                New-Item $Target2 -ItemType Directory
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
        non-existent                    | non-existent                  | New-item $Target2 -Itemtype File
        non-existent                    | file-symbolic-or-junction     | throw error
        non-existent                    | file-non-symbolic-or-junction | pass(do nothing)
        file-symbolic-or-junction       | non-existent                  | throw error
        file-symbolic-or-junction       | file-symbolic-or-junction     | throw error
        file-symbolic-or-junction       | file-non-symbolic-or-junction | del $Target1
        file-non-symbolic-or-junction   | non-existent                  | copy $Target1 to $Target2, del $Target1
        file-non-symbolic-or-junction   | file-symbolic-or-junction     | throw error
        file-non-symbolic-or-junction   | file-non-symbolic-or-junction | backup $Target1 and $Target2 to $Backuppath, then del $Target1
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Target1,
        [Parameter(Mandatory)]
        [string]$Target2,
        [Parameter(Mandatory)]
        [string]$Backuppath
    )
    if($PSCmdlet.ShouldProcess("Move the content in $Target1 to $Target2, and backup essential items in $Backuppath",'','')){
        if (Test-Path -LiteralPath $Target1){
            if (Test-IsSymbolicOrJunction $Target1){
                if (Test-Path -LiteralPath $Target2){
                    if (Test-IsSymbolicOrJunction $Target2){
                        # file-symbolic-or-junction       | file-symbolic-or-junction     | throw error
                        throw "Cannot move $Target1 to $Target2, because $Target1 and $Target2 are both symbolic link or junction point."
                    }else{
                        # file-symbolic-or-junction       | file-non-symbolic-or-junction | del $Target1
                        Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                        Remove-Item $Target1 -Force -Recurse
                    }
                }else{
                    # file-symbolic-or-junction       | non-existent          | throw error
                    throw "Cannot move $Target1 to $Target2, because $Target1 is symbolic link or junction point while $Target2 does not exist."
                }
            }else{
                if (Test-Path -LiteralPath $Target2){
                    if (Test-IsSymbolicOrJunction $Target2){
                        # file-non-symbolic-or-junction   | file-symbolic-or-junction     | throw error
                        throw "Cannot move $Target1 to $Target2, because $Target1 is not symbolic link or junction point while $Target2 is."
                    }else{
                        # file-non-symbolic-or-junction   | file-non-symbolic-or-junction | backup $Target1 and $Target2 to $Backuppath, then del $Target1
                        Move-FileWithBackup -Source $Target1 -Destination $Target2 -Backuppath $Backuppath
                        Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                        Remove-Item $Target1 -Force -Recurse
                    }
                }else{
                    Assert-AdminRobocopyAvailable
                    # file-non-symbolic-or-junction   | non-existent          | copy $Target1 to $Target2, del $Target1
                    Write-VerboseLog  "Robocopy $Target1 $Target2"
                    $log_file = Get-LogFileName "Robocopy Move-BeforeSetFileLink"
                    Robocopy $Target1 $Target2  /copyall /DCOPY:DATE /LOG:"$log_file"
                    Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                    Remove-Item $Target1 -Force -Recurse
                }
            }
        }else{
            if (Test-Path -LiteralPath $Target2){
                if (Test-IsSymbolicOrJunction $Target2){
                    # non-existent            | file-symbolic-or-junction     | throw error
                    throw "Cannot move $Target1 to $Target2, because $Target1 does not exist and $Target2 is symbolic link or junction point."
                }else{
                    # non-existent            | file-non-symbolic-or-junction | pass(do nothing)
                    Write-VerboseLog  "Do nothing."
                }
            }else{
                # non-existent            | non-existent          | New-item $Target2 -ItemType File
                Write-VerboseLog  "New-Item $Target2 -ItemType File"
                New-Item $Target2 -ItemType File
            }
        }
    }
}