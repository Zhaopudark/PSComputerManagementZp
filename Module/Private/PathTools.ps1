class FormattedFileSystemPath {
<#
.SYNOPSIS
    A class that receives a file system path,
        formats the path automatically when initialized,
        holds the formatted path,
        and provides some useful attributes(properties) simultaneously for a quick check.
.NOTES
    Support file system paths only!
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
        - If there are no colons in the path, or there is no slash at the beginning, it will be treated as a relative path. Then a slash '\' or '/',
            according to the platform will be added at the head.
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
    #TODO
        Cross-platform support.
        Currently, this class is only adapative on each single platform, but not cross-platform.
        But for preliminary process, the source's platform will be detected and recorded in the property `OriginalPlatform`.

    Some properties of the path are also provided:
        1. LiteralPath: The formatted path.
        2. OriginalPlatform: The platform of the source path.
        3. Slash: The slash of the path.
        4. Attributes: The attributes of the path.
        5. Linktype: The link type of the path.
        6. LinkTarget: The link target of the path.
        7. Qualifier: The qualifier of the path.
        8. QualifierRoot: The root of the qualifier of the path.
        9. DriveFormat: The format of the drive of the path.
        10. IsDir: If the path is a directory.
        11. IsFile: If the path is a file.
        12. IsDriveRoot: If the path is the root of a drive.
        13. IsBeOrInSystemDrive: If the path is in the system drive.
        14. IsInHome: If the path is in the home directory.
        15. IsHome: If the path is the home directory.
        16. IsDesktopINI: If the path is a desktop.ini file.
        (Windows only):
            17. IsSystemVolumeInfo: If the path is the System Volume Information directory.
            18. IsInSystemVolumeInfo: If the path is in the System Volume Information directory.
            19. IsRecycleBin: If the path is the Recycle Bin directory.
        20. IsInRecycleBin: If the path is in the Recycle Bin directory.
        21. IsSymbolicLink: If the path is a symbolic link.
        22. IsJunction: If the path is a junction.
        23. IsHardLink: If the path is a hard link.

.EXAMPLE
    Not usage examples, but a demonstration about the path formatting:

    | (Windows) Existent Path   | Given(Input) Path         | Formatted Path    |
    | ------------------------- | ------------------------- | ----------------- |
    | C:\Users                  | c:\uSeRs                  | C:\Users\         |
    | C:\Users                  | C:\uSers                  | C:\Users\         |
    | C:\Users\test.txt         | c:\uSeRs\usER\TesT.tXt    | C:\Users\test.txt |
    | C:\Users\test.txt         | C:\uSeRs\user\TEST.TxT    | C:\Users\test.txt |

    | (Unix) Existent Path      | Given(Input) Path         | Formatted Path    |
    | ------------------------- | ------------------------- | ----------------- |
    | /home/uSer                | /home/uSer                | /home/uSer/       |
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

    FormattedFileSystemPath([string] $Path) {
        if ([Environment]::OSVersion.Platform -eq "Win32NT"){
            $this.OriginalPlatform = "Win32NT"
            $this.Slash = '\'
        }elseif ([Environment]::OSVersion.Platform -eq "Unix") {
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

        $home_path = $this.FormatPath([Environment]::GetFolderPath("UserProfile"))
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
        return [FormattedFileSystemPath]::FormatLiteralPath($Path,$this.Slash)
    }
    static [string] FormatLiteralPath([string] $Path, [string] $Slash){
        # Format $Path on Literal level, without any check or validation through file system.
        # See .DESCRIPTION-1 of this class for the details of the formatting rules.
        # It can be used as pre-procession of a path before it is passed to $this.FormatPath().
        if ($Path -match '[\*\?\[\]]'){
            throw "Only literal path is supported, not $($Path) with wildcard characters `*`, `?` or `[]`."
        }

        if ($Path -match '(:+)([^:]+)(:+)'){
            throw "The $($Path) should not contain more than 1 group of consecutive colons."
        }

        $Path = $Path -replace '[:]+', ':'

        $Path = $Path -replace '([^\\\/])([\\\/])+$', { $_.Groups[1].Value.ToUpper()} # Trim the end '\/' but remain the former characters.

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
            $item = (Get-ChildItem $parent -Force| Where-Object Name -eq $leaf)
        }else{
            $item = $null
        }

        if ($item){
            return $item.FullName
        }else{
            return $Path
        }
    }
    [System.Management.Automation.PSDriveInfo] GetQualifier([string]$LiteralPath){
        return (Get-ItemProperty -LiteralPath $LiteralPath).PSDrive
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

function Format-FileSystemPath{
<#
.DESCRIPTION
    A function to apply the class FormattedFileSystemPath on a path.
    Return the formatted liiteral path.
#>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    return ([FormattedFileSystemPath]::new($Path)).LiteralPath
}
class EnvPaths{
<#
.SYNOPSIS
    A class that maintains the process, user, and machine level env paths,
        holds the de-duplicated paths,
        and provides some useful methods for some scenarios that need to modify the env paths.
.NOTES
    Do not check any path's existence or validity.
#>
    [ValidateNotNullOrEmpty()][string] $OriginalPlatform
    [ValidateNotNullOrEmpty()][string] $Indicator
    [ValidateNotNullOrEmpty()][string] $Separator
    [ValidateNotNullOrEmpty()][string[]] $ProcessLevelEnvPaths
    [AllowNull()][string[]] $UserLevelEnvPaths
    [AllowNull()][string[]] $MachineLevelEnvPaths
    [ValidateNotNullOrEmpty()][string[]] $DeDuplicatedProcessLevelEnvPaths
    [AllowNull()][string[]] $DeDuplicatedUserLevelEnvPaths
    [AllowNull()][string[]] $DeDuplicatedMachineLevelEnvPaths
    EnvPaths() {
        if ([Environment]::OSVersion.Platform -eq "Win32NT"){
            $this.OriginalPlatform = "Win32NT"
            $this.Indicator = 'Path'
            $this.Separator = ';'
        }elseif ([Environment]::OSVersion.Platform -eq "Unix") {
            $this.OriginalPlatform = "Unix"
            $this.Indicator = 'PATH'
            $this.Separator = ':'
        }else{
            throw "Only Win32NT and Unix are supported, not $($global:PSVersionTable.Platform)."
        }
        $this.ProcessLevelEnvPaths = @([Environment]::GetEnvironmentVariable($this.Indicator,'Process') -Split $this.Separator)
        $this.UserLevelEnvPaths = @([Environment]::GetEnvironmentVariable($this.Indicator,'User') -Split $this.Separator)
        $this.MachineLevelEnvPaths = @([Environment]::GetEnvironmentVariable($this.Indicator,'Machine') -Split $this.Separator)

        $this.ProcessLevelEnvPaths = $this.DeEmpty($this.ProcessLevelEnvPaths)
        $this.UserLevelEnvPaths = $this.DeEmpty($this.UserLevelEnvPaths)
        $this.MachineLevelEnvPaths = $this.DeEmpty($this.MachineLevelEnvPaths)

        if ($this.OriginalPlatform -eq "Unix"){
            if ($this.UserLevelEnvPaths.Count -ne 0){
                throw "In Unix platform, the User level env path should be empty. But it is $($this.UserLevelEnvPaths)."
            }
            if ($this.MachineLevelEnvPaths.Count -ne 0){
                throw "In Unix platform, the Machine level env path should be empty. But it is $($this.MachineLevelEnvPaths)."
            }
        }
        $verbose = $false
        $this.DeDuplicatedProcessLevelEnvPaths = $this.DeDuplicate($this.ProcessLevelEnvPaths,'Process',$verbose)
        $this.DeDuplicatedUserLevelEnvPaths = $this.DeDuplicate($this.UserLevelEnvPaths,'Process',$verbose)
        $this.DeDuplicatedMachineLevelEnvPaths = $this.DeDuplicate($this.MachineLevelEnvPaths,'Process',$verbose)
    }

    [void] FindDuplicatedPaths([string[]] $Paths, [string] $Level,[bool]$Verbose){
        $grouped_paths = $Paths | Group-Object
        $duplicated_groups = $grouped_paths | Where-Object { $_.Count -gt 1 }

        if ($Verbose){
            foreach ($group in $duplicated_groups) {
                Write-Logs "[Env Paths Duplicated] The $($group.Name) in '$Level' level env path exists $($group.Count) times." -ShowVerbose
            }
        }else{
            foreach ($group in $duplicated_groups) {
                Write-Logs "[Env Paths Duplicated] The $($group.Name) in '$Level' level env path exists $($group.Count) times."
            }
        }
    }
    [string[]] DeEmpty([string[]] $Paths){
        $buf = @()
        foreach ($item in $Paths)
        {
            if ($item.Trim()){
                $buf += $item
            }
        }
        return $buf
    }
    [string[]] DeDuplicate([string[]] $Paths, [string] $Level,[bool]$Verbose){
        $this.FindDuplicatedPaths($Paths,$Level,$Verbose)
        $buf = @()
        foreach ($item in $Paths)
        {
            if (-not $buf.Contains($item)){
                $buf += $item
            }
        }
        return $buf
    }
    [void] SetEnvPath([string[]] $Paths, [string] $Level){
        [Environment]::SetEnvironmentVariable($this.Indicator,$Paths -join $this.Separator,$Level)
    }
    [void] DeDuplicateProcessLevelEnvPaths(){
        $verbose = $true
        $this.ProcessLevelEnvPaths = $this.DeDuplicate($this.ProcessLevelEnvPaths,'Process',$verbose)
        $this.SetEnvPath($this.ProcessLevelEnvPaths,'Process')
        Write-Logs "[Env Paths Modifed] The 'Process' level env path has been de-duplicated." -ShowVerbose
    }
    [void] DeDuplicateUserLevelEnvPaths(){
        $verbose = $true
        $this.UserLevelEnvPaths = $this.DeDuplicate($this.UserLevelEnvPaths,'User',$verbose)
        $this.SetEnvPath($this.UserLevelEnvPaths,'User')
        Write-Logs "[Env Paths Modifed] The 'User' level env path has been de-duplicated." -ShowVerbose
    }
    [void] DeDuplicateMachineLevelEnvPaths(){
        $verbose = $true
        $this.MachineLevelEnvPaths = $this.DeDuplicate($this.MachineLevelEnvPaths,'Machine',$verbose)
        $this.SetEnvPath($this.MachineLevelEnvPaths,'Machine')
        Write-Logs "[Env Paths Modifed] The 'Machine' level env path has been de-duplicated." -ShowVerbose
    }
    [void] MergeDeDuplicatedEnvPathsFromMachineLevelToUserLevel(){
        $this.DeDuplicateUserLevelEnvPaths()
        $this.DeDuplicateMachineLevelEnvPaths()

        $buf = $this.UserLevelEnvPaths+$this.MachineLevelEnvPaths
        $verbose = $true
        $this.FindDuplicatedPaths($buf,'User+Machine',$verbose)
        $buf = @()
        foreach ($item in $this.MachineLevelEnvPaths)
        {
            if (-not $this.UserLevelEnvPaths.Contains($item)){
                $buf += $item
            }
        }
        $this.MachineLevelEnvPaths = $buf
        $this.SetEnvPath($this.MachineLevelEnvPaths,'Machine')
        Write-Logs "[Env Paths Modifed] The items duplicated across 'Machine' level and 'User' level env path have been merged into 'User' level env path." -ShowVerbose
    }
    [string[]] Append([string[]] $Paths, [string] $Level,[string] $Path){
        $buf = $Paths.Clone()
        if (-not $buf.Contains($Path)){
            $buf += $Path
        }else{
            Write-Logs "[Env Paths Duplicated] The $Path in '$Level' level is existent already." -ShowVerbose
        }
        return $buf
    }

    [void] AppendProcessLevelEnvPaths([string] $Path){
        $this.DeDuplicateProcessLevelEnvPaths()
        $this.ProcessLevelEnvPaths = $this.Append($this.ProcessLevelEnvPaths,'Process',$Path)
        $this.SetEnvPath($this.ProcessLevelEnvPaths,'Process')
        Write-Logs "[Env Paths Modifed] The $Path has been appended into 'Process' level env path." -ShowVerbose
    }
    [void] AppendUserLevelEnvPaths([string] $Path){
        $this.DeDuplicateUserLevelEnvPaths()
        $this.UserLevelEnvPaths = $this.Append($this.UserLevelEnvPaths,'User',$Path)
        $this.SetEnvPath($this.UserLevelEnvPaths,'User')
        Write-Logs "[Env Paths Modifed] The $Path has been appended into 'User' level env path." -ShowVerbose
    }
    [void] AppendMachineLevelEnvPaths([string] $Path){
        $this.DeDuplicateMachineLevelEnvPaths()
        $this.MachineLevelEnvPaths = $this.Append($this.MachineLevelEnvPaths,'Machine',$Path)
        $this.SetEnvPath($this.MachineLevelEnvPaths,'Machine')
        Write-Logs "[Env Paths Modifed] The $Path has been appended into 'Machine' level env path." -ShowVerbose
    }

    [string[]] Remove([string[]] $Paths, [string] $Level, [string] $Path, [bool] $IsPattern){
        $buf = @()
        foreach ($item in $Paths)
        {
            if ($IsPattern){
                if ($item -NotMatch $Path){
                    $buf += $item
                }else{
                    Write-Logs "[Env Paths to Remove] The $item in '$Level' level will be removed." -ShowVerbose
                }
            }else{
                if ($item -ne $Path){
                    $buf += $item
                }else{
                    Write-Logs "[Env Paths to Remove] The $item in '$Level' level will be removed." -ShowVerbose
                }
            }
        }
        return $buf
    }
    [void] RemoveProcessLevelEnvPaths([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateProcessLevelEnvPaths()
        $this.ProcessLevelEnvPaths = $this.Remove($this.ProcessLevelEnvPaths,'Process',$Target,$IsPattern)
        $this.SetEnvPath($this.ProcessLevelEnvPaths,'Process')
        Write-Logs "[Env Paths Modifed] The removement has been done on 'Process' level env path." -ShowVerbose
    }
    [void] RemoveUserLevelEnvPaths([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateUserLevelEnvPaths()
        $this.UserLevelEnvPaths = $this.Remove($this.UserLevelEnvPaths,'User',$Target,$IsPattern)
        $this.SetEnvPath($this.UserLevelEnvPaths,'User')
        Write-Logs "[Env Paths Modifed] The removement has been done on 'User' level env path." -ShowVerbose
    }
    [void] RemoveMachineLevelEnvPaths([string] $Target, [bool] $IsPattern){
        $this.DeDuplicateMachineLevelEnvPaths()
        $this.MachineLevelEnvPaths = $this.Remove($this.MachineLevelEnvPaths,'Machine',$Target,$IsPattern)
        $this.SetEnvPath($this.MachineLevelEnvPaths,'Machine')
        Write-Logs "[Env Paths Modifed] The removement has been done on 'Machine' level env path." -ShowVerbose
    }
}

function Get-EnvPaths{
<#
.DESCRIPTION
    A function to apply the class EnvPaths.
    Return the formatted liiteral path.
#>
    param()
    return [EnvPaths]::new()
}