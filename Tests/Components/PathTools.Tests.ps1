BeforeAll {
    . "${PSScriptRoot}\..\..\Module\Config.ps1"

    $guid = [guid]::NewGuid()
    $test_path = "${Home}/$guid"
    New-Item -Path $test_path -ItemType Directory -Force
    
    $test_dir = "${test_path}/test_dir"
    $test_file = "${test_path}/test.txt"
    New-Item -Path $test_dir -ItemType Directory -Force
    New-Item -Path $test_file -ItemType File -Force

    New-Item -Path "$test_path/file_for_hardlink.txt" -ItemType File
    New-Item -Path "$test_path/hardlink" -ItemType HardLink -Target "$test_path/file_for_hardlink.txt"
    New-Item -Path "$test_path/test_for_junction" -ItemType Directory
    New-Item -Path "$test_path/junction" -ItemType Junction -Target "$test_path/test_for_junction"
    New-Item -Path "$test_path/test_for_symbolick_dir" -ItemType Directory
    New-Item -Path "$test_path/symbolick_dir" -ItemType SymbolicLink -Target "$test_path/test_for_symbolick_dir"
    New-Item -Path "$test_path/test_for_symbolick_file" -ItemType File
    New-Item -Path "$test_path/symbolick_file" -ItemType SymbolicLink -Target "$test_path/test_for_symbolick_file"
        
}

Describe 'Test PathTools' {
    Context 'Test the formatting feature of FormattedPath' {
        It 'Test on Windows dir' -Skip:(!$IsWIndows){
            $path = [FormattedPath]::new("${test_path}\tEsT_diR")
            $path | Should -BeExactly "$([FormattedPath]::new($test_path))test_dir\"
        }
        It 'Test on Linux dir' -Skip:(!$IsLinux){
            $path = [FormattedPath]::new("${test_path}\test_dir")
            $path | Should -BeExactly "$([FormattedPath]::new($test_path))test_dir/"
        }
        It 'Test on windows drive' -Skip:(!$IsWIndows){

            $maybe_c = (Get-ItemProperty ${Home}).PSDrive.Name
            $maybe_c_lower = (Get-ItemProperty ${Home}).PSDrive.Name.ToLower()

            $path = [FormattedPath]::new("$maybe_c`:\")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c`:/")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c`:")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c_lower`:\")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c_lower`:/")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c_lower`:")
            $path | Should -BeExactly "$maybe_c`:\"
        }
        It 'Test on Linux drive' -Skip:(!$IsLinux){
            $maybe_root = (Get-ItemProperty ${Home}).PSDrive.Name # / on Linux and Wsl2, not '/root'
            $path = [FormattedPath]::new("$maybe_root")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root/")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root\")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root\/\/\/\/\/")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root/\/\/\/\/\")
            $path | Should -BeExactly "$maybe_root"
        }
    }
    Context 'Test the attributes of FormattedPath' {
        It 'Test on Windows' -Skip:(!$IsWIndows){
            $path = [FormattedPath]::new("${Home}")
            $path.OriginalPlatform | Should -BeExactly 'Win32NT'
            $path.Attributes | Should -BeExactly 'Directory'
            $path.Linktype | Should -BeNullOrEmpty
            $path.LinkTarget | Should -BeNullOrEmpty
            $path.Qualifier | Should -BeExactly 'C'
            $path.QualifierRoot | Should -BeExactly 'C:\'
            $path.IsContainer | Should -BeTrue
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'NTFS'
            $path.IsDir | Should -BeTrue
            $path.IsFile | Should -BeFalse
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeFalse
            $path.IsHome | Should -BeTrue
            $path.IsDesktopINI | Should -BeFalse
            $path.IsSystemVolumeInfo | Should -BeFalse
            $path.IsInSystemVolumeInfo | Should -BeFalse
            $path.IsRecycleBin | Should -BeFalse
            $path.IsInRecycleBin | Should -BeFalse
            $path.IsSymbolicLink | Should -BeFalse
            $path.IsJunction | Should -BeFalse
            $path.IsHardLink | Should -BeFalse


            $path = [FormattedPath]::new("$test_path\hardlink")
            $path.OriginalPlatform | Should -BeExactly 'Win32NT'
            $path.Attributes | Should -BeExactly 'Archive'
            $path.Linktype | Should -BeExactly 'HardLink'
            $path.LinkTarget | Should -BeNullOrEmpty
            $path.Qualifier | Should -BeExactly 'C'
            $path.QualifierRoot | Should -BeExactly 'C:\'
            $path.IsContainer | Should -BeFalse
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'NTFS'
            $path.IsDir | Should -BeFalse
            $path.IsFile | Should -BeTrue
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeTrue
            $path.IsHome | Should -BeFalse
            $path.IsDesktopINI | Should -BeFalse
            $path.IsSystemVolumeInfo | Should -BeFalse
            $path.IsInSystemVolumeInfo | Should -BeFalse
            $path.IsRecycleBin | Should -BeFalse
            $path.IsInRecycleBin | Should -BeFalse
            $path.IsSymbolicLink | Should -BeFalse
            $path.IsJunction | Should -BeFalse
            $path.IsHardLink | Should -BeTrue

            $path = [FormattedPath]::new("$test_path\junction")
            $path.OriginalPlatform | Should -BeExactly 'Win32NT'
            $path.Attributes | Should -BeExactly 'Directory, ReparsePoint'
            $path.Linktype | Should -BeExactly 'Junction'
            $path.LinkTarget | Should -BeExactly "$test_path\test_for_junction"
            $path.Qualifier | Should -BeExactly 'C'
            $path.QualifierRoot | Should -BeExactly 'C:\'
            $path.IsContainer | Should -BeTrue
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'NTFS'
            $path.IsDir | Should -BeTrue
            $path.IsFile | Should -BeFalse
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeTrue
            $path.IsHome | Should -BeFalse
            $path.IsDesktopINI | Should -BeFalse
            $path.IsSystemVolumeInfo | Should -BeFalse
            $path.IsInSystemVolumeInfo | Should -BeFalse
            $path.IsRecycleBin | Should -BeFalse
            $path.IsInRecycleBin | Should -BeFalse
            $path.IsSymbolicLink | Should -BeFalse
            $path.IsJunction | Should -BeTrue
            $path.IsHardLink | Should -BeFalse


            $path = [FormattedPath]::new("$test_path\symbolick_dir")
            $path.OriginalPlatform | Should -BeExactly 'Win32NT'
            $path.Attributes | Should -BeExactly 'Directory, ReparsePoint'
            $path.Linktype | Should -BeExactly 'SymbolicLink'
            $path.LinkTarget | Should -BeExactly "$test_path\test_for_symbolick_dir"
            $path.Qualifier | Should -BeExactly 'C'
            $path.QualifierRoot | Should -BeExactly 'C:\'
            $path.IsContainer | Should -BeTrue
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'NTFS'
            $path.IsDir | Should -BeTrue
            $path.IsFile | Should -BeFalse
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeTrue
            $path.IsHome | Should -BeFalse
            $path.IsDesktopINI | Should -BeFalse
            $path.IsSystemVolumeInfo | Should -BeFalse
            $path.IsInSystemVolumeInfo | Should -BeFalse
            $path.IsRecycleBin | Should -BeFalse
            $path.IsInRecycleBin | Should -BeFalse
            $path.IsSymbolicLink | Should -BeTrue
            $path.IsJunction | Should -BeFalse
            $path.IsHardLink | Should -BeFalse
            
            $path = [FormattedPath]::new("$test_path\symbolick_file")
            $path.OriginalPlatform | Should -BeExactly 'Win32NT'
            $path.Attributes | Should -BeExactly 'Archive, ReparsePoint'
            $path.Linktype | Should -BeExactly 'SymbolicLink'
            $path.LinkTarget | Should -BeExactly "$test_path\test_for_symbolick_file"
            $path.Qualifier | Should -BeExactly 'C'
            $path.QualifierRoot | Should -BeExactly 'C:\'
            $path.IsContainer | Should -BeFalse
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'NTFS'
            $path.IsDir | Should -BeFalse
            $path.IsFile | Should -BeTrue
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeTrue
            $path.IsHome | Should -BeFalse
            $path.IsDesktopINI | Should -BeFalse
            $path.IsSystemVolumeInfo | Should -BeFalse
            $path.IsInSystemVolumeInfo | Should -BeFalse
            $path.IsRecycleBin | Should -BeFalse
            $path.IsInRecycleBin | Should -BeFalse
            $path.IsSymbolicLink | Should -BeTrue
            $path.IsJunction | Should -BeFalse
            $path.IsHardLink | Should -BeFalse
        }
        It 'Test on Linux' -Skip:(!$IsLinux){
            $path = [FormattedPath]::new("${Home}")
            $path.OriginalPlatform | Should -BeExactly 'Unix'
            $path.Attributes | Should -BeExactly 'Directory'
            $path.Linktype | Should -BeNullOrEmpty
            $path.LinkTarget | Should -BeNullOrEmpty
            $path.Qualifier | Should -BeExactly '/'
            $path.QualifierRoot | Should -BeExactly '/'
            $path.IsContainer | Should -BeTrue
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'ext2'
            $path.IsDir | Should -BeTrue
            $path.IsFile | Should -BeFalse
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeFalse
            $path.IsHome | Should -BeTrue
            $path.IsDesktopINI | Should -BeNullOrEmpty
            $path.IsSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsInSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsRecycleBin | Should -BeNullOrEmpty
            $path.IsInRecycleBin | Should -BeNullOrEmpty
            $path.IsSymbolicLink | Should -BeFalse
            $path.IsJunction | Should -BeFalse
            $path.IsHardLink | Should -BeFalse


            $path = [FormattedPath]::new("$test_path\hardlink")
            $path.OriginalPlatform | Should -BeExactly 'Unix'
            $path.Attributes | Should -BeExactly 'Archive'
            $path.Linktype | Should -BeExactly 'HardLink'
            $path.LinkTarget | Should -BeNullOrEmpty
            $path.Qualifier | Should -BeExactly '/'
            $path.QualifierRoot | Should -BeExactly '/'
            $path.IsContainer | Should -BeFalse
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'ext2'
            $path.IsDir | Should -BeFalse
            $path.IsFile | Should -BeTrue
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeTrue
            $path.IsHome | Should -BeFalse
            $path.IsDesktopINI | Should -BeNullOrEmpty
            $path.IsSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsInSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsRecycleBin | Should -BeNullOrEmpty
            $path.IsInRecycleBin | Should -BeNullOrEmpty
            $path.IsSymbolicLink | Should -BeFalse
            $path.IsJunction | Should -BeFalse
            $path.IsHardLink | Should -BeTrue

            $path = [FormattedPath]::new("$test_path\junction")
            $path.OriginalPlatform | Should -BeExactly 'Unix'
            $path.Attributes | Should -BeExactly 'Directory, ReparsePoint'
            $path.Linktype | Should -BeExactly 'Junction'
            $path.LinkTarget | Should -BeExactly "$test_path\test_for_junction"
            $path.Qualifier | Should -BeExactly '/'
            $path.QualifierRoot | Should -BeExactly '/'
            $path.IsContainer | Should -BeTrue
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'ext2'
            $path.IsDir | Should -BeTrue
            $path.IsFile | Should -BeFalse
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeTrue
            $path.IsHome | Should -BeFalse
            $path.IsDesktopINI | Should -BeNullOrEmpty
            $path.IsSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsInSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsRecycleBin | Should -BeNullOrEmpty
            $path.IsInRecycleBin | Should -BeNullOrEmpty
            $path.IsSymbolicLink | Should -BeFalse
            $path.IsJunction | Should -BeTrue
            $path.IsHardLink | Should -BeFalse


            $path = [FormattedPath]::new("$test_path\symbolick_dir")
            $path.OriginalPlatform | Should -BeExactly 'Unix'
            $path.Attributes | Should -BeExactly 'Directory, ReparsePoint'
            $path.Linktype | Should -BeExactly 'SymbolicLink'
            $path.LinkTarget | Should -BeExactly "$test_path\test_for_symbolick_dir"
            $path.Qualifier | Should -BeExactly '/'
            $path.QualifierRoot | Should -BeExactly '/'
            $path.IsContainer | Should -BeTrue
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'ext2'
            $path.IsDir | Should -BeTrue
            $path.IsFile | Should -BeFalse
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeTrue
            $path.IsHome | Should -BeFalse
            $path.IsDesktopINI | Should -BeFalse
            $path.IsSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsInSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsRecycleBin | Should -BeNullOrEmpty
            $path.IsInRecycleBin | Should -BeNullOrEmpty
            $path.IsSymbolicLink | Should -BeNullOrEmpty
            $path.IsJunction | Should -BeFalse
            $path.IsHardLink | Should -BeFalse
            
            $path = [FormattedPath]::new("$test_path\symbolick_file")
            $path.OriginalPlatform | Should -BeExactly 'Unix'
            $path.Attributes | Should -BeExactly 'Archive, ReparsePoint'
            $path.Linktype | Should -BeExactly 'SymbolicLink'
            $path.LinkTarget | Should -BeExactly "$test_path\test_for_symbolick_file"
            $path.Qualifier | Should -BeExactly '/'
            $path.QualifierRoot | Should -BeExactly '/'
            $path.IsContainer | Should -BeFalse
            $path.IsInFileSystem | Should -BeTrue
            $path.DriveFormat | Should -BeExactly 'ext2'
            $path.IsDir | Should -BeFalse
            $path.IsFile | Should -BeTrue
            $path.IsInSystemDrive | Should -BeTrue
            $path.IsDriveRoot | Should -BeFalse
            $path.IsInHome | Should -BeTrue
            $path.IsHome | Should -BeFalse
            $path.IsDesktopINI | Should -BeNullOrEmpty
            $path.IsSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsInSystemVolumeInfo | Should -BeNullOrEmpty
            $path.IsRecycleBin | Should -BeNullOrEmpty
            $path.IsInRecycleBin | Should -BeNullOrEmpty
            $path.IsSymbolicLink | Should -BeTrue
            $path.IsJunction | Should -BeFalse
            $path.IsHardLink | Should -BeFalse
        }
    }  
}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
}