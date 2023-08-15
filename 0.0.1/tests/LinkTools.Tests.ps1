BeforeAll {

    Import-Module PSComputerManagementZp -Force
    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force
    New-Item -Path "$test_path\file_for_symbolic_link.txt" -ItemType File
    New-Item -Path "$test_path\file_for_hard_link.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir1" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir1\file1.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir1\dir1" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir1\dir1\file11.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir2" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir2\file2.txt" -ItemType File
    New-Item -Path "$test_path\test_junction\dir2\dir2" -ItemType Directory
    New-Item -Path "$test_path\test_junction\dir2\dir2\file22.txt" -ItemType File
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
    }
    Context 'On non-Windows' -Skip:(Test-Platform 'Windows'){
        It 'Test Set-DirSymbolicLinkWithSync' {
            {Set-DirSymbolicLinkWithSync -Path "$test_path\test_symbolick_dir\dir1"  -Target "$test_path\test_symbolick_dir\dir2" -Backuppath "$test_path\backup" }| Should -Throw
        }
    }

}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
}