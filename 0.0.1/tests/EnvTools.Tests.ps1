BeforeAll {
    $user_env_paths_backup = @([Environment]::GetEnvironmentVariable('PATH','User') -Split ';')
    $machine_env_paths_backup = @([Environment]::GetEnvironmentVariable('PATH','Machine') -Split ';')
    $process_env_paths_backup = @([Environment]::GetEnvironmentVariable('PATH') -Split ';')
    Import-Module PSComputerManagementZp -Force
    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force
    Import-Module "${PSScriptRoot}\..\helpers\PathTools.psm1" -Scope local
    $test_path = Format-Path $test_path
    
}

Describe 'Test EnvTools' {
    Context 'Symplify non-process level Env:PATH' {
        It 'Test Merge-RedundantEnvPathFromLocalMachineToCurrentUser' {
            Merge-RedundantEnvPathFromLocalMachineToCurrentUser
            $user_env_paths = @([Environment]::GetEnvironmentVariable('PATH','User') -Split ';')
            $user_env_paths += $test_path
            $machine_env_paths = @([Environment]::GetEnvironmentVariable('PATH','Machine') -Split ';')
            $machine_env_paths += $test_path
            [Environment]::SetEnvironmentVariable('PATH', ($user_env_paths -Join ';'), 'User')
            [Environment]::SetEnvironmentVariable('PATH', ($machine_env_paths -Join ';'), 'Machine')
            Merge-RedundantEnvPathFromLocalMachineToCurrentUser
            $user_env_paths2 = @([Environment]::GetEnvironmentVariable('PATH','User') -Split ';')
            $machine_env_paths2 = @([Environment]::GetEnvironmentVariable('PATH','Machine') -Split ';')
            
            $user_env_paths2 | Should -Contain $test_path
            $user_env_paths2.count | Should -Be $user_env_paths.count
            $machine_env_paths2 | Should -Not -Contain $test_path
            $machine_env_paths2.count | Should -Be ($machine_env_paths.count-1)
        }
    }
    Context 'Add items into process level Env:PATH' {
        It 'Test Add-EnvPathToCurrentProcess' {
            $process_env_paths1 = @([Environment]::GetEnvironmentVariable('PATH') -Split ';')
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths2 = @([Environment]::GetEnvironmentVariable('PATH') -Split ';')
            
            $process_env_paths1 | Should -Not -Contain $test_path
            $process_env_paths2 | Should -Contain $test_path
           
        }

    }
    Context 'Remove items from process level Env:PATH' {
        It 'Test Remove-EnvPathByPattern'{
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths1 = @([Environment]::GetEnvironmentVariable('PATH') -Split ';')
            Remove-EnvPathByPattern -Pattern $guid -Level 'Process'
            $process_env_paths2 = @([Environment]::GetEnvironmentVariable('PATH') -Split ';')
            
            $process_env_paths1 | Should -Contain $test_path
            $process_env_paths2 | Should -Not -Contain $test_path

        }
        It 'Test Remove-EnvPathByTargetPath'{
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths1 = @([Environment]::GetEnvironmentVariable('PATH') -Split ';')
            Remove-EnvPathByTargetPath -TargetPath $test_path -Level 'Process'
            $process_env_paths2 = @([Environment]::GetEnvironmentVariable('PATH') -Split ';')
            
            $process_env_paths1 | Should -Contain $test_path
            $process_env_paths2 | Should -Not -Contain $test_path
        }
    }

}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
    [Environment]::SetEnvironmentVariable('PATH', ($user_env_paths_backup -Join ';'), 'User')
    [Environment]::SetEnvironmentVariable('PATH', ($machine_env_paths_backup -Join ';'), 'Machine')
    [Environment]::SetEnvironmentVariable('PATH', ($process_env_paths_backup -Join ';'))
}