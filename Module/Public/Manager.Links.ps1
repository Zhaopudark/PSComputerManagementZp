function Set-DirSymbolicLinkWithSync{
<#
.DESCRIPTION
    Set a directory symbolic link from the path to the target.
    Then, get a result as $path\rightarrow target$, which means the path is a symbolic link to the target.
    Merge, cover and backup may be performed when needed.
.PARAMETER Path
    The path to be set.
.PARAMETER Target
    The target path.
.PARAMETER BackupDir
    The backup directory path.
.INPUTS
    String.
    String.
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
    Need Administrator privilege.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$BackupDir
    )
    Assert-IsWindowsAndAdminIfOnWindows
    if ($PSCmdlet.ShouldProcess("Set a directory symbolic link from $Path to $Source, as $Path->$Target",'','')){
        Move-Target2Source4SoftLink -Target $Path -Source $Target -BackupDir $BackupDir
        $link = New-Item -ItemType SymbolicLink -Path $Path -Target $Target
        Write-Log ($link | Select-Object LinkType, FullName, Target)
    }
}
function Set-FileSymbolicLinkWithSync{
<#
.DESCRIPTION
    Set a file symbolic link from the path to the target.
    Then, get a result as $path\rightarrow target$, which means the path is a symbolic link to the target.
    Merge, cover and backup may be performed when needed.
.PARAMETER Path
    The path to be set.
.PARAMETER Target
    The target path.
.PARAMETER BackupDir
    The backup directory path.
.INPUTS
    String.
    String.
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
    Need Administrator privilege.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$BackupDir
    )
    Assert-IsWindowsAndAdminIfOnWindows
    if ($PSCmdlet.ShouldProcess("Set a file symbolic link from $Path to $Source, as $Path->$Target",'','')){
        Move-Target2Source4SoftLink -Target $Path -Source $Target -BackupDir $BackupDir
        $link = New-Item -ItemType SymbolicLink -Path $Path -Target $Target
        Write-Log ($link | Select-Object LinkType, FullName, Target)
    }
}

function Set-DirJunctionWithSync{
<#
.DESCRIPTION
    Set a junction point from the path to the target.
    Then, get a result as $path\rightarrow target$, which means the path is a junction point to the target.
    Merge, cover and backup may be performed when needed.
.PARAMETER Path
    The path to be set.
.PARAMETER Target
    The target path.
.PARAMETER BackupDir
    The backup directory path.
.INPUTS
    String.
    String.
    String.
.OUTPUTS
    None.
.NOTES
    Only support Windows.
    Need Administrator privilege.
.LINK
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$BackupDir
    )
    Assert-IsWindowsAndAdmin
    if ($PSCmdlet.ShouldProcess("Set a junction point from $Path to $Source, as $Path->$Target",'','')){
        Move-Target2Source4SoftLink -Target $Path -Source $Target -BackupDir $BackupDir
        $link = New-Item -ItemType Junction -Path $Path -Target $Target
        Write-Log ($link | Select-Object LinkType, FullName, Target)
    }
}