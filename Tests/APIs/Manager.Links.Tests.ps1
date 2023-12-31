BeforeAll {
    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force
    New-Item -Path "$test_path\file_for_symboliclink1.txt" -ItemType File
    New-Item -Path "$test_path\file_for_symboliclink2.txt" -ItemType File
    New-Item -Path "$test_path\test_junction" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir3" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir3\file3.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir3\dir3" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir3\dir3\file33.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir4" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir4\file4.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir4\dir4" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir4\dir4\file44.txt" -ItemType File
    New-Item -Path "$test_path\test_symbolick_dir" -ItemType Directory
    New-Item -Path "$test_path\test_symbolick_dir\dir1" -ItemType Directory
    New-Item -Path "$test_path\test_symbolick_dir\dir1\file1.txt" -ItemType File
    New-Item -Path "$test_path\test_symbolick_dir\dir1\dir1" -ItemType Directory
    New-Item -Path "$test_path\test_symbolick_dir\dir1\dir1\file11.txt" -ItemType File
    New-Item -Path "$test_path\test_symbolick_dir\dir2" -ItemType Directory
    New-Item -Path "$test_path\test_symbolick_dir\dir2\file2.txt" -ItemType File
    New-Item -Path "$test_path\test_symbolick_dir\dir2\dir2" -ItemType Directory
    New-Item -Path "$test_path\test_symbolick_dir\dir2\dir2\file22.txt" -ItemType File
    New-Item -Path "$test_path\backup" -ItemType Directory
}

Describe 'Test Link Management' {
    Context 'On Windows and non-Windows' {
        It 'Test Set-DirSymbolicLinkWithSync' {
            Set-DirSymbolicLinkWithSync -Path "$test_path\test_symbolick_dir\dir1"  -Target "$test_path\test_symbolick_dir\dir2" -BackupDir "$test_path\backup"
            $item = Get-ItemProperty "$test_path\test_symbolick_dir\dir1"
            $item.LinkType | Should -Be 'SymbolicLink'
            $item.LinkTarget | Should -Be (Get-FormattedFileSystemPath "$test_path\test_symbolick_dir\dir2").ToString()
            "$test_path\test_symbolick_dir\dir1" | Should -Exist
            "$test_path\test_symbolick_dir\dir2\file1.txt" | Should -Exist
            "$test_path\test_symbolick_dir\dir2\dir1" | Should -Exist
            "$test_path\test_symbolick_dir\dir2\dir1\file11.txt" | Should -Exist
            "$test_path\test_symbolick_dir\dir2" | Should -Exist
            "$test_path\test_symbolick_dir\dir2\file2.txt" | Should -Exist
            "$test_path\test_symbolick_dir\dir2\dir2" | Should -Exist
            "$test_path\test_symbolick_dir\dir2\dir2\file22.txt" | Should -Exist
            $backup1 = (Get-ChildItem "$test_path\backup"  -Filter "*dir1")[0]
            $backup2 = (Get-ChildItem "$test_path\backup"  -Filter "*dir2")[0]
            "$backup1\file1.txt" | Should -Exist
            "$backup1\dir1" | Should -Exist
            "$backup1\dir1\file11.txt" | Should -Exist
            "$backup2\file2.txt" | Should -Exist
            "$backup2\dir2" | Should -Exist
            "$backup2\dir2\file22.txt" | Should -Exist
        }
        It 'Test Set-DirJunctionWithSync' -Skip:(!$IsWindows){
            Set-DirJunctionWithSync -Path "$test_path\test_junction\dir3"  -Target "$test_path\test_junction\dir4" -BackupDir "$test_path\backup"
            $item = Get-ItemProperty "$test_path\test_junction\dir3"
            $item.LinkType | Should -Be 'Junction'
            $item.LinkTarget | Should -Be (Get-FormattedFileSystemPath "$test_path\test_junction\dir4").ToString()
            "$test_path\test_junction\dir3" | Should -Exist
            "$test_path\test_junction\dir4\file3.txt" | Should -Exist
            "$test_path\test_junction\dir4\dir3" | Should -Exist
            "$test_path\test_junction\dir4\dir3\file33.txt" | Should -Exist
            "$test_path\test_junction\dir4" | Should -Exist
            "$test_path\test_junction\dir4\file4.txt" | Should -Exist
            "$test_path\test_junction\dir4\dir4" | Should -Exist
            "$test_path\test_junction\dir4\dir4\file44.txt" | Should -Exist
            $backup3 = (Get-ChildItem "$test_path\backup"  -Filter "*dir3")[0]
            $backup4 = (Get-ChildItem "$test_path\backup"  -Filter "*dir4")[0]
            "$backup3\file3.txt" | Should -Exist
            "$backup3\dir3" | Should -Exist
            "$backup3\dir3\file33.txt" | Should -Exist
            "$backup4\file4.txt" | Should -Exist
            "$backup4\dir4" | Should -Exist
            "$backup4\dir4\file44.txt" | Should -Exist
        }
        It 'Test Set-FileSymbolicLinkWithSync' {
            Set-FileSymbolicLinkWithSync -Path "$test_path\file_for_symboliclink1.txt"  -Target "$test_path\file_for_symboliclink2.txt" -BackupDir "$test_path\backup"
            $item = Get-ItemProperty "$test_path\file_for_symboliclink1.txt"
            $item.LinkType | Should -Be 'SymbolicLink'
            $item.LinkTarget | Should -Be (Get-FormattedFileSystemPath "$test_path\file_for_symboliclink2.txt").ToString()
            "$test_path\file_for_symboliclink1.txt" | Should -Exist
            "$test_path\file_for_symboliclink2.txt" | Should -Exist

            foreach($item in Get-Item "$test_path\backup\*symboliclink1.txt"){
                $item | Should -Not -Exist
            }
            foreach($item in Get-Item "$test_path\backup\*symboliclink2.txt"){
                $item | Should -Exist
            }
        }
    }
}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
}