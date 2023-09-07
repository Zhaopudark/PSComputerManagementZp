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
    Assert-IsWindowsAndAdmin

    if ($PSCmdlet.ShouldProcess("Set a directory symbolic link from $Path to $Source, as $Path->$Target",'','')){
        Merge-BeforeSetDirLink -Target1 $Path -Target2 $Target -Backuppath $Backuppath
        $link = New-Item -ItemType SymbolicLink -Path $Path -Target $Target
        Write-Logs ($link | Select-Object LinkType, FullName, Target)
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
    Assert-IsWindowsAndAdmin
    if ($PSCmdlet.ShouldProcess("Set a file symbolic link from $Path to $Source, as $Path->$Target",'','')){
        Move-BeforeSetFileLink -Target1 $Path -Target2 $Target -Backuppath $Backuppath
        $link = New-Item -ItemType SymbolicLink -Path $Path -Target $Target
        Write-Logs ($link | Select-Object LinkType, FullName, Target)
    }
}

function Set-DirJunctionWithSync{
<#
.DESCRIPTION
    Set a junction point from $Path to $Source.
    Then, we will get a result as $Path->$Target,
    which means $Path is a junction point to $Target.
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
    Assert-IsWindowsAndAdmin
    if ($PSCmdlet.ShouldProcess("Set a junction point from $Path to $Source, as $Path->$Target",'','')){
        Merge-BeforeSetDirLink -Target1 $Path -Target2 $Target -Backuppath $Backuppath
        $link = New-Item -ItemType Junction -Path $Path -Target $Target
        Write-Logs ($link | Select-Object LinkType, FullName, Target)
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
    Assert-IsWindowsAndAdmin
    if ($PSCmdlet.ShouldProcess("Set a file hard link from $Path to $Source, as $Path->$Target",'','')){
        Move-BeforeSetFileLink -Target1 $Path -Target2 $Target -Backuppath $Backuppath
        $link = New-Item -ItemType HardLink -Path $Path -Target $Target
        Write-Logs ($link | Select-Object LinkType, FullName, Target)
    }
}