BeforeAll {
    . "${PSScriptRoot}\..\Configs\APIs.Tests.Config.BeforeAll.ps1"

    $user_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','User')
    $machine_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','Machine')
    $process_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','Process')

    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"

}

Describe 'Test Env Management' {
    Context 'Merging, appending and removement on $Env:PATH' {
        It 'Test on process level `$Env:PATH`' {
            $env_paths = Get-EnvPath
            $count = $env_paths.DeDuplicatedProcessLevelEnvPath.Count
            $env_paths.DeDuplicatedProcessLevelEnvPath | Should -Not -Contain $test_path

            Add-PathToCurrentProcessEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedProcessLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPath.Count | Should -Be ($count+1)

            Add-PathToCurrentProcessEnvPath -Path $test_path -IsAppend
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedProcessLevelEnvPath[-1] | Should -Be $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPath.Count | Should -Be ($count+1)

            Add-PathToCurrentProcessEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedProcessLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPath.Count | Should -Be ($count+1)

            Remove-PathFromCurrentProcessEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedProcessLevelEnvPath | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPath.Count | Should -Be $count

            Add-PathToCurrentProcessEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedProcessLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPath.Count | Should -Be ($count+1)

            Remove-MatchedPathsFromCurrentProcessEnvPath -Pattern $guid
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedProcessLevelEnvPath | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPath.Count | Should -Be $count
        }
        It 'Test on user level `$Env:PATH`' -Skip:(!$IsWindows){
            $env_paths = Get-EnvPath
            $count = $env_paths.DeDuplicatedUserLevelEnvPath.Count
            $env_paths.DeDuplicatedUserLevelEnvPath | Should -Not -Contain $test_path

            Add-PathToCurrentUserEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedUserLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedUserLevelEnvPath.Count | Should -Be ($count+1)

            Add-PathToCurrentUserEnvPath -Path $test_path -IsAppend
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedUserLevelEnvPath[-1] | Should -Be $test_path
            $env_paths.DeDuplicatedUserLevelEnvPath.Count | Should -Be ($count+1)

            Add-PathToCurrentUserEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedUserLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedUserLevelEnvPath.Count | Should -Be ($count+1)

            Remove-PathFromCurrentUserEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedUserLevelEnvPath | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPath.Count | Should -Be $count

            Add-PathToCurrentUserEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedUserLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedUserLevelEnvPath.Count | Should -Be ($count+1)

            Remove-MatchedPathsFromCurrentUserEnvPath -Pattern $guid
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedUserLevelEnvPath | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPath.Count | Should -Be $count
        }
        It 'Test on machine level `$Env:PATH`' -Skip:(!$IsWindows){
            $env_paths = Get-EnvPath
            $count = $env_paths.DeDuplicatedMachineLevelEnvPath.Count
            $env_paths.DeDuplicatedMachineLevelEnvPath | Should -Not -Contain $test_path

            Add-PathToCurrentMachineEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedMachineLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPath.Count | Should -Be ($count+1)

            Add-PathToCurrentMachineEnvPath -Path $test_path -IsAppend
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedMachineLevelEnvPath[-1] | Should -Be $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPath.Count | Should -Be ($count+1)

            Add-PathToCurrentMachineEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedMachineLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPath.Count | Should -Be ($count+1)

            Remove-PathFromCurrentMachineEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedMachineLevelEnvPath | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPath.Count | Should -Be $count

            Add-PathToCurrentMachineEnvPath -Path $test_path
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedMachineLevelEnvPath[0] | Should -Be $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPath.Count | Should -Be ($count+1)

            Remove-MatchedPathsFromCurrentMachineEnvPath -Pattern $guid
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedMachineLevelEnvPath | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPath.Count | Should -Be $count
        }
        It 'Test Merge-RedundantEnvPathFromCurrentMachineToCurrentUser' -Skip:(!$IsWindows){
            Merge-RedundantEnvPathFromCurrentMachineToCurrentUser

            $env_paths = Get-EnvPath
            $count_user = $env_paths.DeDuplicatedUserLevelEnvPath.Count
            $count_machine = $env_paths.DeDuplicatedMachineLevelEnvPath.Count

            Add-PathToCurrentUserEnvPath -Path $test_path
            Add-PathToCurrentMachineEnvPath -Path $test_path

            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedUserLevelEnvPath | Should -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPath.Count | Should -Be ($count_user+1)
            $env_paths.DeDuplicatedMachineLevelEnvPath | Should -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPath.Count | Should -Be ($count_machine+1)

            Merge-RedundantEnvPathFromCurrentMachineToCurrentUser
            $env_paths = Get-EnvPath
            $env_paths.DeDuplicatedUserLevelEnvPath | Should -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPath.Count | Should -Be ($count_user+1)
            $env_paths.DeDuplicatedMachineLevelEnvPath | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPath.Count | Should -Be ($count_machine)
        }
    }
}

AfterAll {
    [Environment]::SetEnvironmentVariable('PATH',$user_env_paths_backup ,'User')
    [Environment]::SetEnvironmentVariable('PATH',$machine_env_paths_backup,'Machine')
    [Environment]::SetEnvironmentVariable('PATH',$process_env_paths_backup,'Process')

    . "${PSScriptRoot}\..\Configs\APIs.Tests.Config.AfterAll.ps1"
}