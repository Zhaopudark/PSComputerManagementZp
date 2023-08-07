BeforeAll {
    Import-Module "${PSScriptRoot}\..\helpers\EnvTools.psm1" -Scope local
    $user_env_paths_backup = Get-EnvPathAsSplit -Level 'User'
    $machine_env_paths_backup = Get-EnvPathAsSplit -Level 'Machine'
    $process_env_paths_backup = Get-EnvPathAsSplit -Level 'Process'

    Import-Module PSComputerManagementZp -Force

    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force
    Import-Module "${PSScriptRoot}\..\helpers\PathTools.psm1" -Scope local
    $test_path = Format-Path $test_path

}

Describe 'Test EnvTools' {
    Context 'Symplify non-process level Env:PATH' {
        It 'Test Merge-RedundantEnvPathFromLocalMachineToCurrentUser' -Skip:(!(Test-IfIsOnCertainPlatform -SystemName 'Windows')){
            Merge-RedundantEnvPathFromLocalMachineToCurrentUser
            $user_env_paths = Get-EnvPathAsSplit -Level 'User'
            $user_env_paths += $test_path
            $machine_env_paths = Get-EnvPathAsSplit -Level 'Machine'
            $machine_env_paths += $test_path
            Set-EnvPathBySplit -Level 'User' -Path $user_env_paths
            Set-EnvPathBySplit -Level 'Machine' -Path $machine_env_paths
            Merge-RedundantEnvPathFromLocalMachineToCurrentUser
            $user_env_paths2 = Get-EnvPathAsSplit -Level 'User'
            $machine_env_paths2 = Get-EnvPathAsSplit -Level 'Machine'

            $user_env_paths2 | Should -Contain $test_path
            $user_env_paths2.count | Should -Be $user_env_paths.count
            $machine_env_paths2 | Should -Not -Contain $test_path
            $machine_env_paths2.count | Should -Be ($machine_env_paths.count-1)
        }
    }
    Context 'Add items into process level Env:PATH' {
        It 'Test Add-EnvPathToCurrentProcess' {
            $process_env_paths1 = Get-EnvPathAsSplit -Level 'Process'
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths2 = Get-EnvPathAsSplit -Level 'Process'
            $process_env_paths1 | Should -Not -Contain $test_path
            $process_env_paths2 | Should -Contain $test_path

        }

    }
    Context 'Remove items from process level Env:PATH' {
        It 'Test Remove-EnvPathByPattern'{
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths1 = Get-EnvPathAsSplit -Level 'Process'
            Remove-EnvPathByPattern -Pattern $guid -Level 'Process'
            $process_env_paths2 = Get-EnvPathAsSplit -Level 'Process'

            $process_env_paths1 | Should -Contain $test_path
            $process_env_paths2 | Should -Not -Contain $test_path

        }
        It 'Test Remove-EnvPathByTargetPath'{
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths1 = Get-EnvPathAsSplit -Level 'Process'
            Remove-EnvPathByTargetPath -TargetPath $test_path -Level 'Process'
            $process_env_paths2 = Get-EnvPathAsSplit -Level 'Process'

            $process_env_paths1 | Should -Contain $test_path
            $process_env_paths2 | Should -Not -Contain $test_path
        }
    }

}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
    Set-EnvPathBySplit -Level 'User' -Path $user_env_paths_backup
    Set-EnvPathBySplit -Level 'Machine' -Path $machine_env_paths_backup
    Set-EnvPathBySplit -Level 'Process' -Path $process_env_paths_backup
}