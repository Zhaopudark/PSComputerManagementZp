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


    Some properties of the path are also provided:
        1. LiteralPath: The formatted path.
        2. OriginalPlatform: The platform of the source path.
        3. Attributes: The attributes of the path.
        4. Linktype: The link type of the path.
        5. LinkTarget: The link target of the path.
        6. Qualifier: The qualifier of the path.
        7. QualifierRoot: The root of the qualifier of the path.
        8. IsContainer: If the path is a container.
        9. IsInFileSystem: If the path is in file system.
        10. DriveFormat: The format of the drive that contain the path.
        11. IsDir: If the path is a directory.
        12. IsFile: If the path is a file.
        13. IsInSystemDrive: If the path is in system drive.
        14. IsDriveRoot: If the path is a drive root.
        15. IsInHome: If the path is in home directory.
        16. IsHome: If the path is home directory.
        Windows-exclusive:
            17. IsDesktopINI: If the path is desktop.ini.
            18. IsSystemVolumeInfo: If the path is System Volume Information.
            19. IsInSystemVolumeInfo: If the path is in System Volume Information.

        20. IsRecycleBin: If the path is Recycle Bin.
        21. IsInRecycleBin: If the path is in Recycle Bin.
        22. IsSymbolicLink: If the path is symbolic link.
        23. IsJunction: If the path is junction.
        24. IsHardLink: If the path is hard link.

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
    [ValidateNotNullOrEmpty()][string] $LiteralPath
    [ValidateNotNullOrEmpty()][string] $OriginalPlatform 
    [ValidateNotNullOrEmpty()][string] $Attributes
    [string] $Linktype
    [string] $LinkTarget
    [ValidateNotNullOrEmpty()][string] $Qualifier
    [ValidateNotNullOrEmpty()][string] $QualifierRoot
    [ValidateNotNullOrEmpty()][bool] $IsContainer = $null
    [ValidateNotNullOrEmpty()][bool] $IsInFileSystem = $null
    [string] $DriveFormat = $null
    [ValidateNotNullOrEmpty()][bool] $IsDir = $null
    [ValidateNotNullOrEmpty()][bool] $IsFile = $null
    [ValidateNotNullOrEmpty()][bool] $IsInSystemDrive = $null
    [ValidateNotNullOrEmpty()][bool] $IsDriveRoot = $null
    [ValidateNotNullOrEmpty()][bool] $IsInHome = $null
    [ValidateNotNullOrEmpty()][bool] $IsHome = $null
    [ValidateNotNullOrEmpty()][bool] $IsDesktopINI = $null
    [ValidateNotNullOrEmpty()][bool] $IsSystemVolumeInfo = $null
    [ValidateNotNullOrEmpty()][bool] $IsInSystemVolumeInfo = $null
    [ValidateNotNullOrEmpty()][bool] $IsRecycleBin = $null
    [ValidateNotNullOrEmpty()][bool] $IsInRecycleBin = $null
    [ValidateNotNullOrEmpty()][bool] $IsSymbolicLink = $null
    [ValidateNotNullOrEmpty()][bool] $IsJunction = $null
    [ValidateNotNullOrEmpty()][bool] $IsHardLink = $null

    FormattedPath([string] $Path) {
        
        if ([System.Environment]::OSVersion.Platform -eq "Win32NT"){
            $this.OriginalPlatform = "Win32NT"
        }elseif ([System.Environment]::OSVersion.Platform -eq "Unix") {
            $this.OriginalPlatform = "Unix"
        }else{
            throw "Only Win32NT and Unix are supported, not $($global:PSVersionTable.Platform)."
        }

        if(Test-Path -LiteralPath $Path){
            $this.LiteralPath = $this.FormatLiteralPath($Path)
        }
        else{
            throw (New-Object System.Management.Automation.ItemNotFoundException "Path '$path' not found.")
        }

        $this.Attributes = (Get-ItemProperty $this.LiteralPath).Attributes
        $this.Linktype = (Get-ItemProperty $this.LiteralPath).Linktype
        $this.LinkTarget = (Get-ItemProperty $this.LiteralPath).LinkTarget
        $this.Qualifier = $this.GetQualifier($this.LiteralPath).Name
        $this.QualifierRoot = $this.GetQualifier($this.LiteralPath).Root



        if (Test-Path -LiteralPath $this.LiteralPath -PathType Container){
            $this.IsContainer = $true
        }
        else {
            $this.IsContainer = $false
        }

        if ($this.LiteralPath -eq $this.QualifierRoot){
            $this.IsDriveRoot = $true
        }
        else {
            $this.IsDriveRoot = $false
        }

        if ($this.GetQualifier($Path).Provider.Name -eq 'FileSystem'){
            $this.IsInFileSystem = $true
            $this.DriveFormat = ([System.IO.DriveInfo]::GetDrives() | Where-Object {$_.RootDirectory.FullName -eq $this.QualifierRoot}).DriveFormat

        }else{
            $this.IsInFileSystem = $false   
        }
         

        if ($this.IsInFileSystem -and $this.IsContainer){
            $this.IsDir = $true
            $this.IsFile = $false
        }else{
            $this.IsDir = $false
            $this.IsFile = $true
        }

        $home_path = $this.FormatLiteralPath([System.Environment]::GetFolderPath("UserProfile"))

        if ($this.Qualifier -eq $this.GetQualifier($home_path).Name){
            $this.IsInSystemDrive = $true
        }
        else {
            $this.IsInSystemDrive = $false
        }
        if ($this.LiteralPath.StartsWith($home_path)){
            if ($this.LiteralPath.EndsWith($home_path)){
                $this.IsHome = $true
                $this.IsInHome = $false
            }else{
                $this.IsHome = $false
                $this.IsInHome = $true
            }
        }else{
            $this.IsHome = $false
            $this.IsInHome = $false
        }
        

        
        if ($this.OriginalPlatform -eq "Win32NT"){
            if ($this.IsFile -and ((Split-Path $this.LiteralPath -Leaf) -eq "desktop.ini")){
                $this.IsDesktopINI = $true
            }
            else {
                $this.IsDesktopINI = $false
            }
            $system_volume_information_path = $this.FormatLiteralPath("$($this.QualifierRoot)System Volume Information")
            if ($this.LiteralPath.StartsWith($system_volume_information_path)){
                if ($this.LiteralPath.EndsWith($system_volume_information_path)){
                    $this.IsSystemVolumeInfo = $true
                    $this.IsInSystemVolumeInfo = $false
                }else{
                    $this.IsSystemVolumeInfo = $false
                    $this.IsInSystemVolumeInfo = $true
                }
            }else{
                $this.IsSystemVolumeInfo = $false
                $this.IsInSystemVolumeInfo = $false
            }
            
            
            $recycle_bin_path = $this.FormatLiteralPath("$($this.QualifierRoot)`$RECYCLE.BIN")
            if ($this.LiteralPath.StartsWith($recycle_bin_path)){
                if ($this.LiteralPath.EndsWith($recycle_bin_path)){
                    $this.IsRecycleBin = $true
                    $this.IsInRecycleBin = $false
                }else{
                    $this.IsRecycleBin = $false
                    $this.IsInRecycleBin = $true
                }
            }else{
                $this.IsRecycleBin = $false
                $this.IsInRecycleBin = $false
            }
        } 
        if ([bool]($this.Attributes -band [System.IO.FileAttributes]::ReparsePoint)){
            if ($this.Linktype -eq 'SymbolicLink'){
                $this.IsSymbolicLink = $true
                $this.IsJunction = $false
                $this.IsHardLink = $false
            }
            elseif ($this.Linktype -eq 'Junction'){
                $this.IsSymbolicLink = $false
                $this.IsJunction = $true
                $this.IsHardLink = $false
            }
            else{
                $this.IsSymbolicLink = $false
                $this.IsJunction = $false
                $this.IsHardLink = $false
            }
        }elseif($this.Linktype -eq 'HardLink'){
            $this.IsSymbolicLink = $false
            $this.IsJunction = $false
            $this.IsHardLink = $true
        }else{
            $this.IsSymbolicLink = $false
            $this.IsJunction = $false
            $this.IsHardLink = $false
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
    # [string] GetQualifierWithFirstDir(){

    #     $splited_paths = $this.LiteralPath -split '\\'
    #     if ($splited_paths.Count -gt 1) { $max_index = 1 } else { $max_index = 0 }
    #     return $this.FormatLiteralPath($splited_paths[0..$max_index] -join '\\')
    # }
    [string] ToString() { # like __repr__ in python
        return $this.LiteralPath
    }
    [string] ToShortName() {

        return ($this.LiteralPath -replace '[\\/:]+', '-').Trim('-')
    }
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