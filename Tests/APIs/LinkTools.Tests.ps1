BeforeAll {

    Import-Module PSComputerManagementZp -Force
    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force
    New-Item -Path "$test_path\file_for_symboliclink1.txt" -ItemType File
    New-Item -Path "$test_path\file_for_symboliclink2.txt" -ItemType File
    New-Item -Path "$test_path\file_for_hardlink1.txt" -ItemType File
    New-Item -Path "$test_path\file_for_hardlink2.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir3" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir3\file3.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir3\dir3" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir3\dir3\file33.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir4" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir4\file4.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir4\dir4" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir4\dir4\file44.txt" -ItemType File
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

Describe 'Link EnvTools' {
    Context 'On Windows' -Skip:(!(Test-Platform 'Windows')){
        It 'Test Set-DirSymbolicLinkWithSync' {
            Set-DirSymbolicLinkWithSync -Path "$test_path\test_symbolick_dir\dir1"  -Target "$test_path\test_symbolick_dir\dir2" -Backuppath "$test_path\backup"
            $item = Get-ItemProperty "$test_path\test_symbolick_dir\dir1"
            $item.LinkType | Should -Be 'SymbolicLink'
            $item.LinkTarget | Should -Be "$test_path\test_symbolick_dir\dir2"
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
        It 'Test Set-DirJunctionWithSync' {
            Set-DirJunctionWithSync -Path "$test_path\test_junction\dir3"  -Target "$test_path\test_junction\dir4" -Backuppath "$test_path\backup"
            $item = Get-ItemProperty "$test_path\test_junction\dir3"
            $item.LinkType | Should -Be 'Junction'
            $item.LinkTarget | Should -Be "$test_path\test_junction\dir4"
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
            Set-FileSymbolicLinkWithSync -Path "$test_path\file_for_symboliclink1.txt"  -Target "$test_path\file_for_symboliclink2.txt" -Backuppath "$test_path\backup"
            $item = Get-ItemProperty "$test_path\file_for_symboliclink1.txt"
            $item.LinkType | Should -Be 'SymbolicLink'
            $item.LinkTarget | Should -Be "$test_path\file_for_symboliclink2.txt"
            "$test_path\file_for_symboliclink1.txt" | Should -Exist
            "$test_path\file_for_symboliclink2.txt" | Should -Exist
            $backup1 = (Get-ChildItem "$test_path\backup"  -Filter "*symboliclink1.txt")[0]
            $backup2 = (Get-ChildItem "$test_path\backup"  -Filter "*symboliclink2.txt")[0]
            "$backup1" | Should -Exist
            "$backup2" | Should -Exist
        }
        It 'Test Set-FileHardLinkWithSync' {
            Set-FileHardLinkWithSync -Path "$test_path\file_for_hardlink1.txt"  -Target "$test_path\file_for_hardlink2.txt" -Backuppath "$test_path\backup"
            $item = Get-ItemProperty "$test_path\file_for_hardlink1.txt"
            $item.LinkType | Should -Be 'Hardlink'
            $item.LinkTarget | Should -BeNullOrEmpty
            $item = Get-ItemProperty "$test_path\file_for_hardlink2.txt"
            $item.LinkType | Should -Be 'Hardlink'
            $item.LinkTarget | Should -BeNullOrEmpty
            "$test_path\file_for_hardlink1.txt" | Should -Exist
            "$test_path\file_for_hardlink2.txt" | Should -Exist
            $backup1 = (Get-ChildItem "$test_path\backup"  -Filter "*hardlink1.txt")[0]
            $backup2 = (Get-ChildItem "$test_path\backup"  -Filter "*hardlink2.txt")[0]
            "$backup1" | Should -Exist
            "$backup2" | Should -Exist
        }
    }
    Context 'On non-Windows' -Skip:(Test-Platform 'Windows'){
        It 'Test Set-DirSymbolicLinkWithSync' {
            {Set-DirSymbolicLinkWithSync -Path "$test_path\test_symbolick_dir\dir1"  -Target "$test_path\test_symbolick_dir\dir2" -Backuppath "$test_path\backup" }| Should -Throw
        }
        It 'Test Set-DirJunctionWithSync' {
            {Set-DirJunctionWithSync -Path "$test_path\test_symbolick_dir\dir3"  -Target "$test_path\test_symbolick_dir\dir4" -Backuppath "$test_path\backup" }| Should -Throw
        }
        It 'Test Set-FileSymbolicLinkWithSync' {
            {Set-FileSymbolicLinkWithSync -Path "$test_path\file_symbolic_link"  -Target "$test_path\file_for_symbolic_link.txt" -Backuppath "$test_path\backup"}| Should -Throw
        }

    }

}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
}