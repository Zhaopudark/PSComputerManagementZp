Import-Module "${PSScriptRoot}\Logger.psm1" -Scope local
function local:Merge-DirectoryWithBackup{
<#
.Description
    Backup $Source to a path based on $Backuppath
    Backup $Destination to a path based on $Backuppath
    Then, merge items from $Source to $Destination
    Record logs
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination,
        [Parameter(Mandatory)]
        [string]$Backuppath
    )
    Import-Module "${PSScriptRoot}\PathTools.psm1" -Scope local
    Assert-IsDirectory $Source
    Assert-IsDirectory $Destination
    Assert-IsDirectory $Backuppath
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
        Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
        Assert-AdminRobocopyAvailable
        Robocopy $Source $backup_source /E /copyall /DCOPY:DATE /LOG:"$log_file"
        Robocopy $Destination $backup_destination /E /copyall /DCOPY:DATE /LOG:"$log_file"
        Robocopy $Source $Destination /E /copyall /DCOPY:DATE /LOG:"$log_file"
    }

}
function local:Move-FileWithBackup{
<#
.Description
    Backup $Source to a path based on $Backuppath
    Backup $Destination to a path based on $Backuppath
    Then, move $Source to $Destination
    Record logs
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination,
        [Parameter(Mandatory)]
        [string]$Backuppath
    )
    Assert-IsFile $Source
    Assert-IsFile $Destination
    Assert-IsDirectory $Backuppath
    $guid = [guid]::NewGuid()
    $source_name = $Source -replace ':', '-' -replace '\\', '-' -replace '/', '-' -replace '--','-' -replace '--','-'
    $backup_source = "$Backuppath/$guid-$source_name"
    $destination_name = $Destination -replace ':', '-' -replace '\\', '-' -replace '/', '-' -replace '--','-' -replace '--','-'
    $backup_destination = "$Backuppath/$guid-$destination_name"
    $log_file = Get-LogFileName "Robocopy Move-FileWithBackup"
    if($PSCmdlet.ShouldProcess(
        "Backup $Source to $backup_source"+[Environment]::NewLine+
        "Backup $Destination to $backup_destination"+[Environment]::NewLine+
        "Then, move $Source to $Destination"+[Environment]::NewLine+
        "Record logs to $log_file",'',''))
    {
        Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
        Assert-AdminRobocopyAvailable
        Robocopy $Source $backup_source /E /copyall /DCOPY:DATE /LOG:"$log_file"
        Robocopy $Destination $backup_destination /E /copyall /DCOPY:DATE /LOG:"$log_file"
        Robocopy $Source $Destination /E /copyall /DCOPY:DATE /LOG:"$log_file"
    }
}
function local:Merge-BeforeSetDirLink{
<#
.DESCRIPTION
    Before setting a directory link (Symbolic Link or Junction)
    from $Target2 to $Target1, this function should be used to
    merge the content in $Target1 to $Target2.

    Merge form $Target1 to $Target2 by the following rules:
        $Target1----------------| $Target2--------------| Opeartion
        non-existent            | non-existent          | New-item $Target2 -Itemtype Directory
        non-existent            | dir-ReparsePoint      | throw error
        non-existent            | dir-non-ReparsePoint  | pass(do nothing)
        dir-ReparsePoint        | non-existent          | throw error
        dir-ReparsePoint        | dir-ReparsePoint      | throw error
        dir-ReparsePoint        | dir-non-ReparsePoint  | del $Target1
        dir-non-ReparsePoint    | non-existent          | copy $Target1 to $Target2, del $Target1
        dir-non-ReparsePoint    | dir-ReparsePoint      | throw error
        dir-non-ReparsePoint    | dir-non-ReparsePoint  | backup $Target1 and $Target2 to $Backuppath, then merge $Target1 to $Target2, then del $Target1
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
        Import-Module "${PSScriptRoot}\PathTools.psm1" -Scope local
        if (Test-Path $Target1){
            if (Test-ReparsePoint $Target1){
                if (Test-Path $Target2){
                    if (Test-ReparsePoint $Target2){
                        # dir-ReparsePoint        | dir-ReparsePoint      | throw error
                        throw "Cannot merge $Target1 to $Target2, because $Target1 and $Target2 are both ReparsePoint."
                    }else{
                        # dir-ReparsePoint        | dir-non-ReparsePoint  | del $Target1
                        Write-VerboseLog  "Remove-Item $Target1 -Force"
                        Remove-Item $Target1 -Force # $Target1 is a ReparsePoint, so need not `-Recurse`
                    }
                }else{
                    # dir-ReparsePoint        | non-existent          | throw error
                    throw "Cannot merge $Target1 to $Target2, because $Target2 does not exist."
                }
            }else{
                if (Test-Path $Target2){
                    if (Test-ReparsePoint $Target2){
                        # dir-non-ReparsePoint    | dir-ReparsePoint      | throw error
                        throw "Cannot merge $Target1 to $Target2, because $Target1 is not ReparsePoint, but $Target2 is."
                    }else{
                        #dir-non-ReparsePoint    | dir-non-ReparsePoint  | backup $Target1 and $Target2 to $Backuppath, then merge $Target1 to $Target2, then del $Target1
                        Merge-DirectoryWithBackup -Source $Target1 -Destination $Target2 -Backuppath $Backuppath
                        Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                        Remove-Item $Target1 -Force -Recurse
                    }
                }else{
                    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
                    Assert-AdminRobocopyAvailable
                    # dir-non-ReparsePoint    | non-existent          | copy $Target1 to $Target2, del $Target1
                    Write-VerboseLog  "Robocopy $Target1 $Target2"
                    $log_file = Get-LogFileName "Robocopy Merge-BeforeSetDirLink"
                    Robocopy $Target1 $Target2  /E /copyall /DCOPY:DATE /LOG:"$log_file"
                    Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                    Remove-Item $Target1 -Force -Recurse
                }
            }
        }else{
            if (Test-Path $Target2){
                if (Test-ReparsePoint $Target2){
                    # non-existent            | dir-ReparsePoint      | throw error
                    throw "Cannot merge $Target1 to $Target2, because $Target1 does not exist and $Target2 is ReparsePoint."
                }else{
                    # non-existent            | dir-non-ReparsePoint  | pass(do nothing)
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
function local:Move-BeforeSetFileLink{
<#
.DESCRIPTION
    Before setting a file link (Symbolic Link or HardLink)
    from $Target2 to $Target1, this function should be used to
    move the file $Target1 to $Target2.

    Move the file $Target1 to $Target2 by the following rules:
        $Target1----------------| $Target2--------------| Opeartion
        non-existent            | non-existent          | New-item $Target2 -Itemtype File
        non-existent            | file-ReparsePoint     | throw error
        non-existent            | file-non-ReparsePoint | pass(do nothing)
        file-ReparsePoint       | non-existent          | throw error
        file-ReparsePoint       | file-ReparsePoint     | throw error
        file-ReparsePoint       | file-non-ReparsePoint | del $Target1
        file-non-ReparsePoint   | non-existent          | copy $Target1 to $Target2, del $Target1
        file-non-ReparsePoint   | file-ReparsePoint     | throw error
        file-non-ReparsePoint   | file-non-ReparsePoint | backup $Target1 and $Target2 to $Backuppath, then del $Target1
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
        Import-Module "${PSScriptRoot}\PathTools.psm1" -Scope local
        if (Test-Path $Target1){
            if (Test-ReparsePoint $Target1){
                if (Test-Path $Target2){
                    if (Test-ReparsePoint $Target2){
                        # file-ReparsePoint       | file-ReparsePoint     | throw error
                        throw "Cannot move $Target1 to $Target2, because $Target1 and $Target2 are both ReparsePoint."
                    }else{
                        # file-ReparsePoint       | file-non-ReparsePoint | del $Target1
                        Write-VerboseLog  "Remove-Item $Target1 -Force"
                        Remove-Item $Target1 -Force # $Target1 is a ReparsePoint, so need not `-Recurse`
                    }
                }else{
                    # file-ReparsePoint       | non-existent          | throw error
                    throw "Cannot move $Target1 to $Target2, because $Target1 is ReparsePoint while $Target2 does not exist."
                }
            }else{
                if (Test-Path $Target2){
                    if (Test-ReparsePoint $Target2){
                        # file-non-ReparsePoint   | file-ReparsePoint     | throw error
                        throw "Cannot move $Target1 to $Target2, because $Target1 is not ReparsePoint while $Target2 is."
                    }else{
                        # file-non-ReparsePoint   | file-non-ReparsePoint | backup $Target1 and $Target2 to $Backuppath, then del $Target1
                        Move-FileWithBackup -Source $Target1 -Destination $Target2 -Backuppath $Backuppath
                        Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                        Remove-Item $Target1 -Force -Recurse
                    }
                }else{
                    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
                    Assert-AdminRobocopyAvailable
                    # file-non-ReparsePoint   | non-existent          | copy $Target1 to $Target2, del $Target1
                    Write-VerboseLog  "Robocopy $Target1 $Target2"
                    Robocopy $Target1 $Target2  /copyall /DCOPY:DATE /LOG:"${Home}\Move-BeforeSetFileLink.log"
                    Write-VerboseLog  "Remove-Item $Target1 -Force -Recurse"
                    Remove-Item $Target1 -Force -Recurse
                }
            }
        }else{
            if (Test-Path $Target2){
                if (Test-ReparsePoint $Target2){
                    # non-existent            | file-ReparsePoint     | throw error
                    throw "Cannot move $Target1 to $Target2, because $Target1 does not exist and $Target2 is ReparsePoint."
                }else{
                    # non-existent            | file-non-ReparsePoint | pass(do nothing)
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

function Set-DirSymbolicLinkWithSync{
<#
.DESCRIPTION
    Set a directory symbolic link from $Path to $Source
    Then, we will get a result as $Path->$Target, which means $Path is a symbolic link to $Target
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Backuppath
    )
    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
    Assert-IsWindowsAndAdmin

    if ($PSCmdlet.ShouldProcess("Set a directory symbolic link from $Path to $Source, as $Path->$Target",'','')){
        Merge-BeforeSetDirLink $Path $Target $Backuppath
        $link = New-Item -ItemType SymbolicLink -Path $Path -Target $Target -ErrorAction Stop
        $link | Select-Object LinkType, FullName, Target
    }
}
function Set-FileSymbolicLinkWithSync{
<#
.DESCRIPTION
    Set a file symbolic link from $Path to $Source.
    Then, we will get a result as $Path->$Target,
    which means $Path is a symbolic link to $Target.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Backuppath
    )
    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
    Assert-IsWindowsAndAdmin
    if ($PSCmdlet.ShouldProcess("Set a file symbolic link from $Path to $Source, as $Path->$Target",'','')){
        Move-BeforeSetFileLink $Path $Target $Backuppath
        $link = New-Item -ItemType SymbolicLink -Path $Path -Target $Target -ErrorAction Stop
        $link | Select-Object LinkType, FullName, Target
    }
}

function Set-DirJunctionWithSync{
<#
.DESCRIPTION
    Set a directory junction from $Path to $Source.
    Then, we will get a result as $Path->$Target,
    which means $Path is a junction to $Target.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Backuppath
    )
    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
    Assert-IsWindowsAndAdmin
    if ($PSCmdlet.ShouldProcess("Set a directory junction from $Path to $Source, as $Path->$Target",'','')){
        Merge-BeforeSetDirLink $Path $Target $Backuppath
        $link = New-Item -ItemType Junction -Path $Path -Target $Target -ErrorAction Stop
        $link | Select-Object LinkType, FullName, Target
    }
}

function Set-FileHardLinkWithSync{
<#
.DESCRIPTION
    Set a file hard link from $Path to $Source.
    Then, we will get a result as $Path->$Target,
    which means $Path is a hard link to $Target.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Backuppath
    )
    Import-Module "${PSScriptRoot}\PlatformTools.psm1" -Scope local
    Assert-IsWindowsAndAdmin
    if ($PSCmdlet.ShouldProcess("Set a file hard link from $Path to $Source, as $Path->$Target",'','')){
        Move-BeforeSetFileLink $Path $Target $Backuppath
        $link = New-Item -ItemType HardLink -Path $Path -Target $Target -ErrorAction Stop
        $link | Select-Object LinkType, FullName, Target
    }
}