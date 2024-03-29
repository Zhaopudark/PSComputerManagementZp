function Reset-Authorization{
<#
.SYNOPSIS
    Reset the ACL and attributes of a path to its default state if we have already known the default state exactly.
    For more information on the motivations, rationale, logic, limitations and usage of this function, see the [post](https://little-train.com/posts/ebaccba2.html).

.DESCRIPTION
    Reset ACL of `$Path` to its default state by 3 steps:
        1. Get path type by `Get-PathType`
        2. Get default SDDL of `$Path` by `Get-DefaultSddl` according to `$path_type`
        3. Set SDDL of `$Path` to default SDDL by `Set-Acl`

.PARAMETER Path
    The path to be reset.
.PARAMETER Recurse
    A switch parameter to indicate whether to reset the ACL of all files and directories in the path recursively.
.INPUTS
    String or FormattedFileSystemPath.
.OUTPUTS
    None.
.COMPONENT
    ```powershell
        $new_acl = Get-Acl -LiteralPath $Path
        $sddl = ... # Get default SDDL of `$Path`
        $new_acl.SetSecurityDescriptorSddlForm($sddl)
        Set-Acl -LiteralPath $Path -AclObject $new_acl
    ```
.NOTES
    Only support Windows.
.LINK
    [Authorization](https://little-train.com/posts/ebaccba2.html)
    [ShouldProcess](https://learn.microsoft.com/zh-cn/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.3)
#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [FormattedFileSystemPath]$Path,
        [switch]$Recurse
    )
    try {
        Assert-IsWindowsAndAdmin
        Assert-ValidPath4Authorization $Path
        $path_type = Get-PathType $Path -SkipPlatformCheck -SkipPathCheck
        if ($null -eq $path_type){
            throw "The path `{$Path}` is not supported."
        }
        $sddl = Get-DefaultSddl -PathType $path_type
        if ($null -eq $sddl){
            throw "The path `{$Path}` is not supported."
        }
        $new_acl = Get-Acl -LiteralPath $Path

        if($PSCmdlet.ShouldProcess("$Path",'set the original ACL')){
            Reset-PathAttribute $Path -SkipPlatformCheck -SkipPathCheck
            if ($new_acl.Sddl -ne $sddl){
                try {
                    Write-Log  "`$Path is:`n`t $Path"
                    Write-Log  "Current Sddl is:`n`t $($new_acl.Sddl)"
                    Write-Log  "Target Sddl is:`n`t $($sddl)"

                    $new_acl.SetSecurityDescriptorSddlForm($sddl)
                    Write-Log  "After dry-run, the sddl is:`n`t $($new_acl.Sddl)"

                    Set-Acl -LiteralPath $Path -AclObject $new_acl
                    Write-Log  "After applying ACL modification, the sddl is:`n`t $((Get-Acl -LiteralPath $Path).Sddl)"
                }
                catch [System.ArgumentException]{
                    Write-Log  "`$Path is too long: '$Path'"
                }
            }
            if ($Recurse){
                if ($Path.IsFile){
                    throw "Cannot use `-Recurse` on a file: $Path"
                }
                if ($Path.IsSymbolicLink){
                    throw "Cannot use `Recurse` on a symbolic link: $Path"
                }
                if ($Path.IsJunction){
                    throw "Cannot use `-Recurse` on a junction: $Path"
                }
                if ($Path.IsInSystemVolumeInfo){
                    throw "Cannot use `-Recurse` on a path in System Volume Information: $Path"
                }
                if ($Path.IsInRecycleBin){
                    throw "Cannot use `-Recurse` on a path in Recycle Bin: $Path"
                }
                # Recurse bypass: files, symbolic link directories, junctions, System Volume Information, `$Recycle.Bin
                $paths = Get-ChildItem -LiteralPath $Path -Force -Recurse -Attributes !ReparsePoint -ErrorAction Continue
                # The progress bar is refer to Chat-Gpt
                $total = $paths.Count
                $current = 0
                foreach ($item in $paths) {
                    $current++
                    $progressPercentage = ($current / $total) * 100
                    $progressStatus = "Processing file $current of $total"
                    Write-Progress -Activity "Traversing Directory" -Status $progressStatus -PercentComplete $progressPercentage
                    # Do your personal jobs, such as: $file.FullName
                    Reset-Authorization -Path $item.FullName
                }
                Write-Progress -Activity "Traversing Directory" -Completed
            }
        }
    }
    catch {
        Write-Log  "Reset-Authorization Exception: $PSItem"
        Write-Log  "Operation has been skipped on $Path."
    }
}