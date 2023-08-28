class FormattedFileSystemPathX {
<#
.SYNOPSIS
    A class that receive a file system path, 
        automatically formatted the path, 
        hold the formatted path, 
        provides some useful attributes(properties) simultaneously for quick check.
    #NOTE Support file system paths only!
.DESCRIPTION
    Automatically format a path to standard format by the following procedures and rules:
    1. Preprocess a received path with some literal check (string level, without accessing it by file system):
        - Check if it contains wildcard characters `*`, `?` or `[]`. If so, throw an error.
        - Check if it contains more than 1 group of consecutive colons. If so, throw an error.
        - Reduce any consecutive colons to a single `:`
        - Strip any trailing slashs. 
        - According to the platform, append a single '\' or '/' if the path ends with a colon.
        - Reduce any consecutive slashes to a single one, and convert them to '\' or '/', according to the platform.
        - Convert the drive name to initial capital letter.
    2. Test the preprocessed path with file system access:
        - Check if the path exists in file system. If not, throw an error.
        - Check if the path is with wildcard characters by file system. If so, throw an error.
            -  It means a path (an instance of this class) represents only a path, not a group of paths.
    3. Format the path with file system access:
        - Convert it to an absolute one.
        - Convert it to an original-case one.
            - Even though, by default(https://learn.microsoft.com/zh-cn/windows/wsl/case-sensitivity), 
                items in NTFS of Windows is not case-sensitive, but actually it has the ability to be case-sensitive.
            - And, in NTFS of Windows, two paths with only case differences can represent the same item, i.g., `c:\uSeRs\usER\TesT.tXt` and `C:\Users\User\test.txt`.
            - Furthermore, by `explorer.exe`, we can see that the original case of a path. If we change its case, the original case will be changed too.
            - So, NTFS does save and maintain the original case of a path. It just be intentionally case-insensitive rather than incapable of being case-sensitive.
            - This class use the methods [here](https://stackoverflow.com/q/76982195/17357963) to get the original case of a path, then maintian it.
        # - Append a slash `\` on Windows or `/` on Unix dynamically to a directory path, if it is not ended with a slash. We hold the view that:
        #     - Let as much information as possible be included in the path string.
        #     - It is a decoupling and simplification that is good for whatever computational tasks ensue.
    
.EXAMPLE
    (Not usage examples, but a demonstration about the path formatting)

    (Windows)
    Given:
    c:\uSeRs            ->will be formatted as->    C:\Users\
    c:                  ->will be formatted as->    C:\
    If ` C:\Users\test.txt` exits 

    c:\uSeRs\test.txt   ->will be formatted as->    C:\Users\test.txt
    (Unix)
    /home/uSer          ->will be formatted as->    /home/uSer/

    | (Windows) Existent Path   | Given(Input) Path         | Formatted Path    |
    | ------------------------- | ------------------------- | ----------------- |
    | C:\Users                  | c:\uSeRs                  | C:\Users\         |
    | C:\Users                  | C:\uSers                  | C:\Users\         |
    | C:\Users\test.txt         | c:\uSeRs\usER\TesT.tXt    | C:\Users\test.txt |
    | C:\Users\test.txt         | C:\uSeRs\user\TEST.TxT    | C:\Users\test.txt |

    | (Unix) Existent Path      | Given(Input) Path         | Formatted Path    |
    | ------------------------- | ------------------------- | ----------------- |
    | /home/uSer                | /home/uSer                | /home/uSer/       |

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
        13. IsBeOrInSystemDrive: If the path is in system drive.
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
    [ValidateSet('\','/')][string] $Slash
    [AllowNull()][string] $Attributes
    [AllowNull()][string] $Linktype = $null
    [AllowNull()][string] $LinkTarget = $null
    [ValidateNotNullOrEmpty()][string] $Qualifier
    [ValidateNotNullOrEmpty()][string] $QualifierRoot
    [ValidateNotNullOrEmpty()][string] $DriveFormat
    [ValidateNotNullOrEmpty()][bool] $IsDir
    [ValidateNotNullOrEmpty()][bool] $IsFile
    [ValidateNotNullOrEmpty()][bool] $IsDriveRoot
    [ValidateNotNullOrEmpty()][bool] $IsBeOrInSystemDrive
    [ValidateNotNullOrEmpty()][bool] $IsInHome
    [ValidateNotNullOrEmpty()][bool] $IsHome 
    [Nullable[bool]] $IsDesktopINI = $null
    [Nullable[bool]] $IsSystemVolumeInfo = $null
    [Nullable[bool]] $IsInSystemVolumeInfo = $null
    [Nullable[bool]] $IsRecycleBin = $null
    [Nullable[bool]] $IsInRecycleBin = $null
    [ValidateNotNullOrEmpty()][bool] $IsSymbolicLink
    [ValidateNotNullOrEmpty()][bool] $IsJunction
    [ValidateNotNullOrEmpty()][bool] $IsHardLink

    FormattedFileSystemPathX([string] $Path) {
        if ([System.Environment]::OSVersion.Platform -eq "Win32NT"){
            $this.OriginalPlatform = "Win32NT"
            $this.Slash = '\'
        }elseif ([System.Environment]::OSVersion.Platform -eq "Unix") {
            $this.OriginalPlatform = "Unix"
            $this.Slash = '/'
        }else{
            throw "Only Win32NT and Unix are supported, not $($global:PSVersionTable.Platform)."
        }
        
        $Path = $this.PreProcess($Path)
        
        if(!(Test-Path -LiteralPath $Path)){
            throw (New-Object System.Management.Automation.ItemNotFoundException "Path '$Path' not found.")
        }
        if ($this.GetQualifier($Path).Provider.Name -ne 'FileSystem'){
            # Write-Verbose $Path -Verbose 
            # Write-Verbose $this.GetQualifier($Path).Provider.Name -Verbose 
            throw "Only FileSystem provider is supported, not $($this.GetQualifier($Path).Provider.Name)."
        } 
        $this.LiteralPath = $this.FormatPath($Path) 
        $this.Attributes = (Get-ItemProperty $this.LiteralPath).Attributes
        $this.Linktype = (Get-ItemProperty $this.LiteralPath).Linktype

        $link_target = (Get-ItemProperty $this.LiteralPath).LinkTarget
        if ($link_target){
            $link_target = $this.PreProcess($link_target)
            $this.LinkTarget = $this.FormatPath($link_target)
        }else{
            $this.LinkTarget = $link_target
        }
        $this.Qualifier = $this.GetQualifier($this.LiteralPath).Name
        $this.QualifierRoot = $this.GetQualifier($this.LiteralPath).Root
        $this.DriveFormat = ([System.IO.DriveInfo]::GetDrives() | Where-Object {$_.RootDirectory.FullName -eq $this.QualifierRoot}).DriveFormat

        if (Test-Path -LiteralPath $this.LiteralPath -PathType Container){
            $this.IsDir = $true
            $this.IsFile = $false
        }
        else {
            $this.IsDir = $false
            $this.IsFile = $true
        }

        if ($this.LiteralPath -eq $this.QualifierRoot){
            $this.IsDriveRoot = $true
        }
        else {
            $this.IsDriveRoot = $false
        }

        $home_path = $this.FormatPath([System.Environment]::GetFolderPath("UserProfile"))
        if ($this.Qualifier -eq $this.GetQualifier($home_path).Name){
            $this.IsBeOrInSystemDrive = $true
        }
        else {
            $this.IsBeOrInSystemDrive = $false
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
            $system_volume_information_path = $this.FormatPath("$($this.QualifierRoot)System Volume Information")
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
            
            
            $recycle_bin_path = $this.FormatPath("$($this.QualifierRoot)`$RECYCLE.BIN")
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
    [string] PreProcess([string] $Path){
        return [FormattedFileSystemPathX]::FormatLiteralPath($Path,$this.Slash)
    }
    static [string] FormatLiteralPath([string] $Path, [string] $Slash){
        # format $Path on Literal level, without any check or validation through file system
        # can be used as pre-procession of a path before it is passed to $this.FormatPath()
        if ($Path -match '[\*\?\[\]]'){
            throw "Only literal path is supported, not $($Path) with wildcard characters `*`, `?` or `[]`."
        }

        if ($Path -match '(:+)([^:]+)(:+)'){
            throw "The $($Path) should not contain more than 1 group of consecutive colons."
        }

        $Path = $Path -replace '[:]+', ':'
        
        if ($Path -match ":$") {
            $Path = $Path + $Slash
        }

        $Path = $Path -replace '[/\\]+', $Slash
        $Path = $Path -replace '^([A-Za-z])([A-Za-z]*)(:)', { $_.Groups[1].Value.ToUpper() + $_.Groups[2].Value.ToLower() + $_.Groups[3].Value}

        if (($Path -notmatch ':') -and ($Path -match '^[A-Za-z]')){
            $Path = $Slash + $Path
        }

        return $Path
    }
    [string] FormatPath([string] $Path){
        try {
            $parent = Split-Path $Path -Parent
        }
        catch {
            $parent = ''
        }
        try {
            $leaf = Split-Path $Path -Leaf
        }
        catch {
            $leaf = ''
        }
        if ($parent -and $leaf){
            $item = (Get-ChildItem $parent | Where-Object Name -eq $leaf)
        }else{
            $item = $null
        }
        
        if ($item){
            # if (Test-Path -LiteralPath $item -PathType Container){
            #     return (join-Path $item.FullName '')
            # }
            # else{
            return $item.FullName
            # }
            
        }else{
            return $Path
        }
        
        # Get-ChildItem (Split-Path $known) | Where-Object Name -eq (Split-Path $known -leaf)).FullName
        # $resolvedPath = Resolve-Path -LiteralPath $Path
        # # $item = Get-ItemProperty -LiteralPath $resolvedPath
        # if (Test-Path -LiteralPath $resolvedPath -PathType Container){
        #     $output += (join-Path $resolvedPath '')
        # }
        # else{
        #     $output += $resolvedPath.FullName
        # }
        # return $output
    }
    [System.Management.Automation.PSDriveInfo] GetQualifier([string]$LiteralPath){
        return (Get-ItemProperty -LiteralPath $LiteralPath -ErrorAction Stop).PSDrive
    }
    # [string] GetQualifierWithFirstDir(){

    #     $splited_paths = $this.LiteralPath -split '\\'
    #     if ($splited_paths.Count -gt 1) { $max_index = 1 } else { $max_index = 0 }
    #     return $this.FormatPath($splited_paths[0..$max_index] -join '\\')
    # }
    [string] ToString() { # like __repr__ in python
        return $this.LiteralPath
    }
    [string] ToShortName() {

        return ($this.LiteralPath -replace '[/\\:]+', '-').Trim('-')
    }
}