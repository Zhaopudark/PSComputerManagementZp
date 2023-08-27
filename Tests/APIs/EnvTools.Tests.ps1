BeforeAll {
    function Format-LiteralPath{
        <#
        .DESCRIPTION
            mimic the function `Format-LiteralPath` in Private\PathTools.ps1
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

    Import-Module PSComputerManagementZp -Force 
    $user_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','User')
    $machine_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','Machine')
    $process_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','Process')

    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force

    $test_path = Format-LiteralPath $test_path
}

Describe 'Test EnvTools' {
    Context 'Symplify non-process level Env:PATH' {
        It 'Test Merge-RedundantEnvPathFromLocalMachineToCurrentUser' -Skip:(!$IsWindows){
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
    Remove-Item $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force

    [Environment]::SetEnvironmentVariable('PATH',$user_env_paths_backup ,'User')
    [Environment]::SetEnvironmentVariable('PATH',$machine_env_paths_backup,'Machine')
    [Environment]::SetEnvironmentVariable('PATH',$process_env_paths_backup,'Process')
}