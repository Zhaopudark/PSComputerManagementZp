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
function Assert-IsDirectory{
    param(
        [string]$Path
    )    
    # 判断路径是否存在且是一个目录
    if (Test-Path -Path $Path -PathType Container) {
        # 判断路径是否是软链接或交接点
        if (-not (Test-ReparsePoint $Path)) {
            return 
        }
        else {
            throw "The `Path` $Path should be an existed directory and should not be a `ReparsePoint`(SymbolicLink or Junction)!"
        }
    }
    else {
        throw "The `Path` $Path should be an existed directory!"
    }
}
function Assert-IsFile{
    param(
        [string]$Path
    )   
    # 判断路径是否存在
    if (Test-Path -Path $Path) {
        # 判断路径是否指向一个文件
        if ((Get-Item -Path $Path).PSIsContainer -eq $false) {
            return
        } else {
            throw "The `Path` $Path should be existing and be a file!"
        }
    } else {
        throw "The `Path` $Path should be existing!"
    }
}
function local:Get-Qualifier{
    param(
        [string]$Path
    )
    return Format-Path (Split-Path $Path -Qualifier)
}

function local:Test-IsInSystemDisk{
    param(
        [string]$Path
    )
    return ((Get-Qualifier $Path).ToString() -eq (Get-Qualifier $global:Home).ToString())
}
function local:Test-IsInInHome{
    param(
        [string]$Path
    )
    if ($Path -ne ''){
        $Path = Format-Path $Path
        if ($Path -eq (Format-Path $global:Home)){
            return $true
        }
        else{
            return (Test-IsInInHome (Split-Path $Path -Parent))
        }
    }
    else{
        return $false
    }
}

function local:Get-DriveWithFirstDir{
    param(
        [string]$Path
    )
    $splited_paths = (Format-Path $Path) -split '\\'
    if ($splited_paths.Count -gt 1) { $max_index = 1 } else { $max_index = 0 }
    return Format-Path ($splited_paths[0..$max_index] -join '\\')
}

