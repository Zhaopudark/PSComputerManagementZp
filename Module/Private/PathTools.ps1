class FormattedPath {
<#
.SYNOPSIS
    A class that automatically formats a path and hold it in the whole life cycle.
    Some properties of the path are also provided.    

.DESCRIPTION
    Automatically format a path to standard format by the following rules:
        1. Should be existed.
        2. Resolved to a full path.
        3. Drive letter will be capitalized.
        4. Maintain original case in a case-sensitive way, even though windows is not case-sensitive.
        5. Directory paths will be appended with `\` on windows or `/` on unix dynamically.
    Only for literal path, not support wildcard characters. 
    It means a path (an instance of this class) represents only a path, not a group of paths.
    Here are some examples:
        (Windows)
        c:\uSeRs            ->will be formatted as->    C:\Users\
        c:                  ->will be formatted as->    C:\
        c:\uSeRs\test.txt   ->will be formatted as->    C:\Users\test.txt
        (Unix)
        /home/uSer          ->will be formatted as->    /home/uSer/

    #TODO
        Cross-platform support.
        Currently, this class is only adapative on each single platform, but not cross-platform. 
        But for preliminary process, the source's platform will be detected and recorded in the property `OriginalPlatform`.


    .Example
        Format-LiteralPath -Path 'c:\uSeRs\test.txt'
        -> C:\Users\test.txt

    Some properties of the path are also provided:
        1. BasePath: the path after formatting.
        2. IsContainer: whether the path is a directory.
        3. IsFile: whether the path is a file.
        4. IsInSystemDrive: whether the path is in system drive.
        5. IsInHome: whether the path is in home directory.
        Windows-exclusive:
            6. IsDesktopINI: whether the path is a desktop.ini file.
            7. IsSystemVolumeInfo: whether the path is a System Volume Information directory.
            8. IsRecycleBin: whether the path is a Recycle Bin directory.



.COMPONENT
    Resolve-Path $some_path
    (Get-ItemProperty $some_path).FullName
    Test-Path -LiteralPath $Path -PathType Container
    Join-Path $some_path ''

.NOTES
    To support wildcard characters, we use `Resolve-Path` to realize
        points `1,2,3` in the above description.
    To realize point `4`, we use `Get-ItemProperty` to get path-object's `FullName`.
    To realize point `5`, we use `Test-Path -LiteralPath $Path -PathType Container` to check if it is a directory, and use `join-Path $item ''` to append `\` to a directory path.

.INPUTS
    String. This function is only for literal path, and it does not support wildcard characters.

.OUTPUTS
    String
#>  
    [ValidateNotNullOrEmpty()][string] $BasePath
    [ValidateNotNullOrEmpty()][string] $OriginalPlatform 
    [ValidateNotNullOrEmpty()][bool] $IsContainer = $false
    [ValidateNotNullOrEmpty()][bool] $IsFile = $false
    [ValidateNotNullOrEmpty()][bool] $IsInSystemDrive = $false
    [ValidateNotNullOrEmpty()][bool] $IsInInHome = $false
    [ValidateNotNullOrEmpty()][bool] $IsDesktopINI = $false
    [ValidateNotNullOrEmpty()][bool] $IsSystemVolumeInfo = $false
    [ValidateNotNullOrEmpty()][bool] $IsRecycleBin = $false

    FormattedPath([string] $Path) {
        
        if ([System.Environment]::OSVersion.Platform -eq "Win32NT"){
            $this.OriginalPlatform = "Win32NT"
        }elseif ([System.Environment]::OSVersion.Platform -eq "Unix") {
            $this.OriginalPlatform = "Unix"
        }else{
            throw "Only Win32NT and Unix are supported, not $($global:PSVersionTable.Platform)."
        }

        if(Test-Path -LiteralPath $Path){
            $this.BasePath = $this.FormatLiteralPath($Path)
        }
        else{
            throw "Path does not exist: $Path"
        }
        if (Test-Path -LiteralPath $this.BasePath -PathType Container){
            $this.IsContainer = $true
            $this.IsFile = $false
        }
        else {
            $this.IsContainer = $false
            $this.IsFile = $true
        }


        $home_path = $this.FormatLiteralPath([System.Environment]::GetFolderPath("UserProfile"))

        if (($this.GetQualifier($this.BasePath)).Name -eq ($this.GetQualifier($home_path)).Name){
            $this.IsInSystemDrive = $true
        }
        else {
            $this.IsInSystemDrive = $false
        }
        if ($this.BasePath.StartsWith($home_path)){
            $this.IsInInHome = $true
        }else{
            $this.IsInInHome = $false
        }

        
        if ($this.OriginalPlatform -eq "Win32NT"){
            if ($this.IsFile -and ((Split-Path $this.BasePath -Leaf) -eq "desktop.ini")){
                $this.IsDesktopINI = $true
            }
            else {
                $this.IsDesktopINI = $false
            }
            if ($this.BasePath -eq $this.FormatLiteralPath("$($this.GetQualifier($this.BasePath).Root)System Volume Information")){
                $this.IsSystemVolumeInfo = $true
            }
            else {
                $this.IsSystemVolumeInfo = $false
            }
    
            if ($this.BasePath -eq $this.FormatLiteralPath("$($this.GetQualifier($this.BasePath).Root)`$RECYCLE.BIN")){
                $this.IsSystemVolumeInfo = $true
            }
            else {
                $this.IsSystemVolumeInfo = $false
            }
        }  
        
    }

    [string] FormatLiteralPath([string] $Path){
        
        if ($Path -match ":$") {
            if ($this.OriginalPlatform -eq "Win32NT"){
                $Path = $Path + "\"
            }else{
                $Path = $Path + "/"
            }
        }
        $resolvedPath = Resolve-Path -LiteralPath $Path
        $item = Get-ItemProperty -LiteralPath $resolvedPath
        if (Test-Path -LiteralPath $item -PathType Container){
            $output += (join-Path $item '')
        }
        else{
            $output += $item.FullName
        }
        return $output
    }
    [System.Management.Automation.PSDriveInfo] GetQualifier([string]$LiteralPath){
        return (Get-ItemProperty -LiteralPath $LiteralPath -ErrorAction Stop).PSDrive
    }
    [string] GetDriveWithFirstDir(){

        $splited_paths = $this.BasePath -split '\\'
        if ($splited_paths.Count -gt 1) { $max_index = 1 } else { $max_index = 0 }
        return $this.FormatLiteralPath($splited_paths[0..$max_index] -join '\\')
    }
    [string] ToString() { # like __repr__ in python
        return $this.BasePath
    }

}



function Get-FormattedPath{
    param()
    return [FormattedPath]
}


function Format-LiteralPath{
<#
.DESCRIPTION
    Format an existed path to standard format:
        1. Should be existed.
        2. Resolved to a full path.
        3. Drive letter will be capitalized.
        4. Maintain original case in a case-sensitive way, even though windows is not case-sensitive.
        5. Directory paths will be appended with `\`.
    Only for literal path, not support wildcard characters.

.Example
    Format-LiteralPath -Path 'c:\uSeRs'
    -> C:\Users\

.Example
    Format-LiteralPath -Path 'c:'
    -> C:\

.Example
    Format-LiteralPath -Path 'c:\uSeRs\test.txt'
    -> C:\Users\test.txt

.COMPONENT
    Resolve-Path $some_path
    (Get-ItemProperty $some_path).FullName
    Test-Path -LiteralPath $Path -PathType Container
    Join-Path $some_path ''

.NOTES
    To support wildcard characters, we use `Resolve-Path` to realize
        points `1,2,3` in the above description.
    To realize point `4`, we use `Get-ItemProperty` to get path-object's `FullName`.
    To realize point `5`, we use `Test-Path -LiteralPath $Path -PathType Container` to check if it is a directory, and use `join-Path $item ''` to append `\` to a directory path.

.INPUTS
    String. This function is only for literal path, and it does not support wildcard characters.

.OUTPUTS
    String
#>  
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    if ($Path -match ":$") {
        $Path = $Path + "\"
    }
    $resolvedPath = Resolve-Path -LiteralPath $Path
    $item = Get-ItemProperty -LiteralPath $resolvedPath
    if (Test-Path -LiteralPath $item -PathType Container){
        $output += (join-Path $item '')
    }
    else{
        $output += $item.FullName
    }
    return $output
}







function Format-Path{
<#
.DESCRIPTION
    Format existed windows path(s) to standard format:
        1. Should be existed.
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
    (Get-ItemProperty $some_path).FullName
    Test-Path -LiteralPath $Path -PathType Container
    Join-Path $some_path ''

.NOTES
    To support wildcard characters, we use `Resolve-Path` to realize
        points `1,2,3` in the above description.
    To realize point `4`, we use `Get-ItemProperty` to get path-object's `FullName`.
    To realize point `5`, we use `Test-Path -LiteralPath $Path -PathType Container` to check if it is a directory, and use `join-Path $item ''` to append `\` to a directory path.

.INPUTS
    String or string with wildcard characters to represent (a) exited path(s).

.OUTPUTS
    String or String[]
#>  param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    if ($Path -match ":$") {
        $Path = $Path + "\"
    }
    $resolvedPath = Resolve-Path -Path $Path
    $output = @()
    foreach ($item in $resolvedPath){

        $item = Get-ItemProperty -LiteralPath $item

        if (Test-Path -LiteralPath $item -PathType Container){
            $output += (join-Path $item '')
        }
        else{
            $output += $item.FullName
        }
    }
    return $output
}


function Get-Qualifier{
    [OutputType([System.Management.Automation.PSDriveInfo])]
    param(
        [string]$LiteralPath
    )
    return (Get-ItemProperty -LiteralPath $LiteralPath -ErrorAction Stop).PSDrive
}

# *******************************************************************************#
# Tests

function Test-IsSymbolicOrJunction{
    <#
    .DESCRIPTION
        Test if a path is a Symbolic link Junction point.
    
        There are more than 2 types of reparse points, and if one care about symbolic link and junction point,
        the following commands can be used:
            [bool]((Get-ItemProperty -LiteralPath $LiteralPath).Attributes -band [System.IO.FileAttributes]::ReparsePoint) -and
            ((Get-ItemProperty -LiteralPath $LiteralPath).LinkType -in @('SymbolicLink','Junction'))
    #>
    param(
        [string]$LiteralPath
    )
    return [bool]((Get-ItemProperty -LiteralPath $LiteralPath).Attributes -band [System.IO.FileAttributes]::ReparsePoint) -and
            ((Get-ItemProperty -LiteralPath $LiteralPath).LinkType -in @('SymbolicLink','Junction'))              
}




function Test-IsDirectory{
    param(
        [string]$Path
    )
    if (Test-Path -LiteralPath $Path) {
        if (Test-Path -LiteralPath $Path -PathType Container) {
            return $true
        } else {
            return $false
        }
    } else {
        throw "The $Path should be existing!"
    }
}

function Test-IsFile{
    param(
        [string]$Path
    )
    if (Test-Path -LiteralPath $Path) {
        if (Test-Path -LiteralPath $Path -PathType Leaf){
            return $true
        } else {
            return $false
        }
    } else {
        throw "The $Path should be existing!"
    }
}

function Test-IsDesktopINI{
    param(
        [string]$Path
    )
    if (Test-Path -LiteralPath $Path) {
        if (Test-Path -LiteralPath $Path -PathType Leaf){
            return (Split-Path $Path -Leaf) -eq "desktop.ini"
            # return $true
        } else {
            return $false
        }
    } else {
        throw "The $Path should be existing!"
    }
}



function Test-IsInSystemDrive{
    param(
        [string]$Path
    )

    if ((Get-Qualifier $Path).Name -eq (Get-Qualifier ${Home}).Name){
        return $true
    }
    else{
        Write-Verbose "The $Path in not System FileSystem as ${Home}."
        return $false
    }
}

function Test-IsInInHome{
    [CmdletBinding()]
    param(
        [string]$Path,
        [switch]$SkipFormat
    )
    if (-not $SkipFormat) {
        $Path = Format-LiteralPath $Path
    }
    $home_path = Format-LiteralPath ([System.Environment]::GetFolderPath("UserProfile"))
    
    if ($Path.StartsWith($home_path)) {
        Write-Verbose "The test path is in the user's home directory."
        return $true
    } else {
        Write-Verbose "The test path is not in the user's home directory."
        return $false
    }
}

function Test-IsSystemVolumeInfo{
    [CmdletBinding()]
    param(
        [string]$Path,
        [switch]$SkipFormat
    )
    if (-not $SkipFormat) {
        $Path = Format-LiteralPath $Path
    }
    return ($Path -eq (Format-LiteralPath "$((Get-Qualifier $Path).Root)System Volume Information"))
}
function Test-IsRecycleBin{
    [CmdletBinding()]
    param(
        [string]$Path,
        [switch]$SkipFormat
    )
    if (-not $SkipFormat) {
        $Path = Format-LiteralPath $Path
    }
    return ($Path -eq (Format-LiteralPath "$((Get-Qualifier $Path).Root)`$RECYCLE.BIN"))
}



# *******************************************************************************#
# Validations (Assertions) 
# Can be used directly or as a validation function in `ValidateScript`.

function Assert-NotSymbolicOrJunction{
    param(
        [string]$Path
    )
    if (Test-IsSymbolicOrJunction $Path){
        throw "The $Path should not be a Symbolic link or Junction point!"
    }
    else{
        return $true 
    }
}

function Assert-IsDirectory{
    param(
        [string]$Path
    )
    if (Test-Path -LiteralPath $Path) {
        if (Test-Path -LiteralPath $Path -PathType Container) {
            return $true
        } else {
            return "The $Path should be a directory!"
        }
    } else {
        throw "The $Path should be existing!"
    }
}

function Assert-IsFile{
    param(
        [string]$Path
    )
    if (Test-Path -LiteralPath $Path) {
        if (Test-Path -LiteralPath $Path -PathType Leaf){
            return $true
        } else {
            throw "The $Path should be a file!"
        }
    } else {
        throw "The $Path should be existing!"
    }
}

function Assert-IsInFileSystem{
    param(
        [string]$Path
    )
   
    if ((Get-Qualifier $Path).Provider.Name -eq 'FileSystem'){
        return $true
    }
    else{
        throw "The $Path should be in FileSystem, such as C:, D:, X:, instead of this or other PSProviders."
    }
}



function Get-DriveWithFirstDir{
    param(
        [string]$Path,
        [switch]$SkipFormat
    )
    if (-not $SkipFormat) {
        $Path = Format-LiteralPath $Path
    }
    $splited_paths = $Path -split '\\'
    if ($splited_paths.Count -gt 1) { $max_index = 1 } else { $max_index = 0 }
    return Format-LiteralPath ($splited_paths[0..$max_index] -join '\\')
}