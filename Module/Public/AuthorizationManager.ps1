 function Reset-Authorization{
<#
.SYNOPSIS
Reset the ACL and attributes of a path to its default state if we have already known the default state exactly.
For more information on the motivation, rationale, logic, and usage of this function, see https://little-train.com/posts/7fdde8eb.html

.DESCRIPTION
    Reset ACL of `$Path` to its default state by 3 steps:
        1. Get path type by `Get-PathType`
        2. Get default SDDL of `$Path` by `Get-DefaultSddl` according to `$PathType`
        3. Set SDDL of `$Path` to default SDDL by `Set-Acl`
    
    Only for window system
    Only for single user account on window system, i.e. totoally Personal Computer

.COMPONENT
    $NewAcl = Get-Acl -LiteralPath $Path
    $Sddl = ... # Get default SDDL of `$Path`
    $NewAcl.SetSecurityDescriptorSddlForm($Sddl)
    Set-Acl -LiteralPath $Path -AclObject $NewAcl

#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({Assert-ValidPath4AuthorizationTools $_})]
        [FormattedFileSystemPath]$Path,
        [switch]$Recurse
    )
    try {
        Assert-IsWindows
        $PathType = Get-PathType $Path -SkipPlatformCheck
        $Sddl = Get-DefaultSddl -PathType $PathType
        $NewAcl = Get-Acl -LiteralPath $Path

        if($PSCmdlet.ShouldProcess("$Path",'set the original ACL')){
            Reset-PathAttribute $Path -SkipPlatformCheck
            if ($NewAcl.Sddl -ne $Sddl){
                try {
                    Write-VerboseLog  "`$Path is:`n`t $Path"
                    Write-VerboseLog  "Current Sddl is:`n`t $($NewAcl.Sddl)"
                    Write-VerboseLog  "Target Sddl is:`n`t $($Sddl)"
    
                    $NewAcl.SetSecurityDescriptorSddlForm($Sddl)
                    Write-VerboseLog  "After dry-run, the sddl is:`n`t $($NewAcl.Sddl)"
    
                    Set-Acl -LiteralPath $Path -AclObject $NewAcl
                    Write-VerboseLog  "After applying ACL modification, the sddl is:`n`t $((Get-Acl -LiteralPath $Path).Sddl)"
                }
                catch [System.ArgumentException]{
                    Write-VerboseLog  "`$Path is too long: '$Path'"
                }
            }
            if ($Recurse -and !$Path.IsFile -and !$Path.IsInSystemVolumeInfo -and !$Path.IsInRecycleBin -and !$Path.IsSymbolicLink -and !$Path.IsJunction){

                # Recurse bypass: files, symbolic link directories, junctions, System Volume Information, `$Recycle.Bin

                $Paths = Get-ChildItem -LiteralPath $Path -Force -Recurse -Attributes !ReparsePoint
                # The progress bar is refer to Chat-Gpt
                $total = $Paths.Count
                $current = 0
                foreach ($item in $Paths) {
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
        Write-VerboseLog  "Reset-Authorization Exception: $PSItem"
        Write-VerboseLog  "Operation has been skipped on $Path."
    }
}
    
    
    