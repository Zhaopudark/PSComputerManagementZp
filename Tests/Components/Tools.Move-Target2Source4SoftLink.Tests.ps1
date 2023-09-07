BeforeAll {
    . "${PSScriptRoot}\..\Configs\Components.Tests.Config.BeforeAll.ps1"

    $guid = [guid]::NewGuid()
    $test_path = "${Home}/$guid"
    New-Item -Path $test_path -ItemType Directory -Force
    $backup_dir = "${Home}/$guid/backup"
    New-Item -Path $backup_dir -ItemType Directory -Force
    $file_path = "${Home}/$guid/test.txt"
    New-Item -Path $file_path -ItemType File -Force
    $another_file_path = "${Home}/$guid/another_test.txt"
    New-Item -Path $another_file_path -ItemType File -Force
    $dir_path = "${Home}/$guid/test"
    New-Item -Path $dir_path -ItemType Directory -Force
    $another_dir_path = "${Home}/$guid/another_test"
    New-Item -Path $another_dir_path -ItemType Directory -Force
    $target = "${Home}/$guid/target"
    $source = "${Home}/$guid/source"
}
Describe '[Test Move-Target2Source4SoftLink on different conditions of Target and Source]' {
    Context '[Target:non-existing]' {
        It '[Source:non-existing]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target and $Source are both non-existing."
        }
        It '[Source:existing-simple-file]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $source -ItemType File -Force

            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            $target | Should -Not -Exist
            $source | Should -Exist
            Get-ChildItem $backup_dir | Should -HaveCount 0

            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-simple-directory]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $source -ItemType Directory -Force

            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            $target | Should -Not -Exist
            $source | Should -Exist
            Get-ChildItem $backup_dir | Should -HaveCount 0

            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-file-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $file_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is non-existing but the $Source a soft link."
        }
        It '[Source:existing-directory-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is non-existing but the $Source a soft link."
        }
        It '[Source:existing-directory-junction-point]' -Skip:(!$IsWIndows){
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $source -ItemType Junction -Force -Target $dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is non-existing but the $Source a soft link."
        }     
    }
    Context '[Target:existing-simple-file]'{
        It '[Source:non-existing]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType File -Force

            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            $target | Should -Not -Exist
            $source | Should -Exist

            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-simple-file]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType File -Force
            New-Item -Path $source -ItemType File -Force

            foreach($item in Get-Item "$backup_dir\*$guid*"){
                $item | Should -Not -Exist
            }
            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            $target | Should -Not -Exist
            $source | Should -Exist
            foreach($item in Get-Item "$backup_dir\*$guid*"){
                $item | Should -Exist
            }
            
            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-simple-directory]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType File -Force
            New-Item -Path $source -ItemType Directory -Force
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a simple file but the $Source is a simple directory."
        }
        It '[Source:existing-file-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType File -Force
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $file_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a simple file but the $Source is a soft link."
        }
        It '[Source:existing-directory-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType File -Force
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a simple file but the $Source is a soft link."
        }
        It '[Source:existing-directory-junction-point]' -Skip:(!$IsWIndows){
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType File -Force
            New-Item -Path $source -ItemType Junction -Force -Target $dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a simple file but the $Source is a soft link."
        }
    }
    Context '[Target:existing-simple-directory]'{
        It '[Source:non-existing]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType Directory -Force

            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            $target | Should -Not -Exist
            $source | Should -Exist

            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-simple-file]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType Directory -Force
            New-Item -Path $source -ItemType File -Force
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a simple directory but the $Source is a simple file."
        }
        It '[Source:existing-simple-directory]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType Directory -Force
            New-Item -Path $source -ItemType Directory -Force
            New-Item -Path "$target\test1.txt" -ItemType File -Force
            New-Item -Path "$source\test2.txt" -ItemType File -Force

            foreach($item in Get-Item "$backup_dir\*$guid*test1*.txt"){
                $item | Should -Not -Exist
            }
            foreach($item in Get-Item "$backup_dir\*$guid*test2*.txt"){
                $item | Should -Not -Exist
            }
            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            foreach($item in Get-Item "$backup_dir\*$guid*test1*.txt"){
                $item | Should -Exist
            }
            foreach($item in Get-Item "$backup_dir\*$guid*test2*.txt"){
                $item | Should -Exist
            }
            $target | Should -Not -Exist
            $source | Should -Exist
            "$source\test1.txt" | Should -Exist
            "$source\test2.txt" | Should -Exist

            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-file-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Directory -Force
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $file_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a simple directory but the $Source is a soft link."
        }
        It '[Source:existing-directory-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Directory -Force
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a simple directory but the $Source is a soft link."
        }
        It '[Source:existing-directory-junction-point]' -Skip:(!$IsWIndows){
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Directory -Force
            New-Item -Path $source -ItemType Junction -Force -Target $dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a simple directory but the $Source is a soft link."
        }
    }
    Context '[Target:existing-file-symbolic-link]'{
        It '[Source:non-existing]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType SymbolicLink -Force -Target $file_path

            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a file symbolic link but the $Source is non-existing."
        }
        It '[Source:existing-simple-file]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType SymbolicLink -Force -Target $file_path
            New-Item -Path $source -ItemType File -Force

            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            $target | Should -Not -Exist
            $source | Should -Exist

            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-simple-directory]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType SymbolicLink -Force -Target $file_path
            New-Item -Path $source -ItemType Directory -Force
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a file symbolic link but the $Source is a simple directory."
        }
        It '[Source:existing-file-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType SymbolicLink -Force -Target $file_path
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $another_file_path

            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a file symbolic link but the $Source is a soft link."
        }
        It '[Source:existing-directory-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType SymbolicLink -Force -Target $file_path
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $another_dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a file symbolic link but the $Source is a soft link."
        }
        It '[Source:existing-directory-junction-point]' -Skip:(!$IsWIndows){
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType SymbolicLink -Force -Target $file_path
            New-Item -Path $source -ItemType Junction -Force -Target $another_dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a file symbolic link but the $Source is a soft link."
        }
    }
    Context '[Target:existing-directory-symbolic-link]'{
        It '[Source:non-existing]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType SymbolicLink -Force -Target $dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a directory symbolic link but the $Source is non-existing."
        }
        It '[Source:existing-simple-file]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType SymbolicLink -Force -Target $dir_path
            New-Item -Path $source -ItemType File -Force
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a directory symbolic link but the $Source is a simple file."
        }
        It '[Source:existing-simple-directory]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue
            New-Item -Path $target -ItemType SymbolicLink -Force -Target $dir_path
            New-Item -Path $source -ItemType Directory -Force
            New-Item -Path "$target\test1.txt" -ItemType File -Force
            New-Item -Path "$source\test2.txt" -ItemType File -Force

            "$dir_path\test1.txt" | Should -Exist
            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            foreach($item in Get-Item "$backup_dir\*$guid*test1*.txt"){
                $item | Should -Not -Exist
            }
            foreach($item in Get-Item "$backup_dir\*$guid*test2*.txt"){
                $item | Should -Not -Exist
            }
            $target | Should -Not -Exist
            $source | Should -Exist
            "$dir_path\test1.txt" | Should -Exist
            "$source\test1.txt" | Should -Not -Exist
            "$source\test2.txt" | Should -Exist

            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-file-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType SymbolicLink -Force -Target $dir_path
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $another_file_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a directory symbolic link but the $Source is a soft link."
        }
        It '[Source:existing-directory-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType SymbolicLink -Force -Target $dir_path
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $another_dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a directory symbolic link but the $Source is a soft link."
        }
        It '[Source:existing-directory-junction-point]' -Skip:(!$IsWIndows){
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType SymbolicLink -Force -Target $dir_path
            New-Item -Path $source -ItemType Junction -Force -Target $another_dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a directory symbolic link but the $Source is a soft link."
        }
    }
    Context '[Target:existing-directory-junction-point]' -Skip:(!$IsWIndows){
        It '[Source:non-existing]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Junction -Force -Target $dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a junction point but the $Source is non-existing."
        }
        It '[Source:existing-simple-file]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Junction -Force -Target $dir_path
            New-Item -Path $source -ItemType File -Force
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a junction point but the $Source is a simple file."
        }
        It '[Source:existing-simple-directory]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Junction -Force -Target $dir_path
            New-Item -Path $source -ItemType Directory -Force
            New-Item -Path "$target\test1.txt" -ItemType File -Force
            New-Item -Path "$source\test2.txt" -ItemType File -Force

            "$dir_path\test1.txt" | Should -Exist
            Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir
            foreach($item in Get-Item "$backup_dir\*$guid*test1*.txt"){
                $item | Should -Not -Exist
            }
            foreach($item in Get-Item "$backup_dir\*$guid*test2*.txt"){
                $item | Should -Not -Exist
            }
            $target | Should -Not -Exist
            $source | Should -Exist
            "$dir_path\test1.txt" | Should -Exist
            "$source\test1.txt" | Should -Not -Exist
            "$source\test2.txt" | Should -Exist

            Remove-Item "$backup_dir\*" -Recurse -Force
        }
        It '[Source:existing-file-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Junction -Force -Target $dir_path
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $another_file_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a junction point but the $Source is a soft link."
        }
        It '[Source:existing-directory-symbolic-link]'{
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Junction -Force -Target $dir_path
            New-Item -Path $source -ItemType SymbolicLink -Force -Target $another_dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a junction point but the $Source is a soft link."
        }
        It '[Source:existing-directory-junction-point]' -Skip:(!$IsWIndows){
            Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $source -Force -Recurse -ErrorAction SilentlyContinue

            New-Item -Path $target -ItemType Junction -Force -Target $dir_path
            New-Item -Path $source -ItemType Junction -Force -Target $another_dir_path
            {Move-Target2Source4SoftLink -Target $target -Source $source -BackupDir $backup_dir } | Should -Throw "[[]Non-supported conditions[]] The $Target is a junction point but the $Source is a soft link."
        }
    }
}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse

    . "${PSScriptRoot}\..\Configs\Components.Tests.Config.AfterAll.ps1"
}