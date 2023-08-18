# Import-Module "${PSScriptRoot}\Logger.psm1" -Scope Local
function Format-Path{
<#
.DESCRIPTION
    Format exited windows path(s) to standard format:
    1. Should be exited.
    2. Resolved to a full path.
    3. Drive letter will be capitalized.
    4. Maintain original case in a case-sensitive way, even though windows is not case-sensitive.
    5. Directory paths will be appended with `\`.

.Example
    Format-Path -Path 'c:\uSeRs'
    -> C:\Users\

.Example
    Format-Path -Path 'c:'
    -> C:\

.Example
    Format-Path -Path 'c:\uSeRs\test.txt'
    -> C:\Users\test.txt

.COMPONENT
    Resolve-Path $some_path
    (Get-Item $some_path).FullName
    (Get-Item $some_path).PSIsContainer
    Join-Path $some_path ''

.NOTES
    To support wildcard characters, we use `Resolve-Path` to realize
        points `1,2,3` in the above description.
    To realize point `4`, we use `Get-Item` to get path-object's `FullName`.
    To realize point `5`, we use `Get-Item` to get path-object's `PSIsContainer` and use `join-Path $item ''` to append `\` to a directory path.

.INPUTS
    String or string with wildcard characters to represent (a) exited path(s).

.OUTPUTS
    String or String[]
#>  param(
        [string]$Path
    )
    if ($Path -match ":$") {
        $Path = $Path + "\"
    }
    $resolvedPath = Resolve-Path -Path $Path
    $output = @()
    foreach ($item in $resolvedPath){
        $item = Get-Item -LiteralPath $item
        if ($item.PSIsContainer){
            $output += (join-Path $item '')
        }
        else{
            $output += $item.FullName
        }
    }
    return $output
}

# *******************************************************************************#
# Tests

function Test-ReparsePoint{
<#
.DESCRIPTION
    Test if a path is a reparse point (SymbolicLink or Junction).
#>
    param(
        [string]$Path
    )
    return [bool]((Get-Item -Path $Path).Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}

# *******************************************************************************#
# Validations (Assertions) 
# Can be used directly or as a validation function in `ValidateScript`.

function Assert-NotReparsePoint{
    param(
        [string]$Path
    )
    if ([bool]((Get-Item -Path $Path).Attributes -band [System.IO.FileAttributes]::ReparsePoint)){
        throw "The $Path should not be a `ReparsePoint`(SymbolicLink or Junction)!"
    }
    else{
        return $true 
    }
}
function Assert-IsDirectory{
    param(
        [string]$Path
    )
    if (Test-Path -Path $Path -PathType Container) {
        return $true 
    }
    else{
        throw "The $Path should be an existed directory!"
    }
}

function Assert-IsFile{
    param(
        [string]$Path
    )
    if (Test-Path -Path $Path) {
        if ((Get-Item -Path $Path).PSIsContainer -eq $false) {
            return $true
        } else {
            throw "The $Path should be a file!"
        }
    } else {
        throw "The $Path should be existing!"
    }
}
function Get-Qualifier{
    param(
        [string]$Path
    )
    return Format-Path (Split-Path $Path -Qualifier)
}

function Test-IsInSystemDisk{
    param(
        [string]$Path
    )
    return ((Get-Qualifier $Path).ToString() -eq (Get-Qualifier ${Home}).ToString())
}
function Test-IsInInHome{
    [CmdletBinding()]
    param(
        [string]$Path
    )
    $home_path = Format-Path ([System.Environment]::GetFolderPath("UserProfile"))
    
    if ((Format-Path $Path).StartsWith($home_path)) {
        Write-Verbose "The test path is within the user's home directory."
        return $true
    } else {
        Write-Verbose "The test path is not within the user's home directory."
        return $false
    }
}

function Get-DriveWithFirstDir{
    param(
        [string]$Path
    )
    $splited_paths = (Format-Path $Path) -split '\\'
    if ($splited_paths.Count -gt 1) { $max_index = 1 } else { $max_index = 0 }
    return Format-Path ($splited_paths[0..$max_index] -join '\\')
}

