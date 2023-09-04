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
        It 'Test on process level env paths' {
            $env_paths = Get-xEnvPaths
            $count = $env_paths.DeDuplicatedProcessLevelEnvPaths.Count 
            $env_paths.DeDuplicatedProcessLevelEnvPaths | Should -Not -Contain $test_path
            Add-PathToCurrentProcessEnvPaths -Path $test_path
            Add-PathToCurrentProcessEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedProcessLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPaths.Count | Should -Be ($count+1)

            Remove-PathFromCurrentProcessEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedProcessLevelEnvPaths | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPaths.Count | Should -Be $count

            Add-PathToCurrentProcessEnvPaths -Path $test_path
            Add-PathToCurrentProcessEnvPaths -Path $test_path
            Add-PathToCurrentProcessEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedProcessLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPaths.Count | Should -Be ($count+1)

            Remove-MatchedPathsFromCurrentProcessEnvPaths -Pattern $guid
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedProcessLevelEnvPaths | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedProcessLevelEnvPaths.Count | Should -Be $count
        }
        It 'Test on user level env paths' -Skip:(!$IsWindows){
            $env_paths = Get-xEnvPaths
            $count = $env_paths.DeDuplicatedUserLevelEnvPaths.Count 
            $env_paths.DeDuplicatedUserLevelEnvPaths | Should -Not -Contain $test_path
            Add-PathToCurrentUserEnvPaths -Path $test_path
            Add-PathToCurrentUserEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedUserLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPaths.Count | Should -Be ($count+1)

            Remove-PathFromCurrentUserEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedUserLevelEnvPaths | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPaths.Count | Should -Be $count

            Add-PathToCurrentUserEnvPaths -Path $test_path
            Add-PathToCurrentUserEnvPaths -Path $test_path
            Add-PathToCurrentUserEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedUserLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPaths.Count | Should -Be ($count+1)

            Remove-MatchedPathsFromCurrentUserEnvPaths -Pattern $guid
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedUserLevelEnvPaths | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPaths.Count | Should -Be $count
        }
        It 'Test on machine level env paths' -Skip:(!$IsWindows){
            $env_paths = Get-xEnvPaths
            $count = $env_paths.DeDuplicatedMachineLevelEnvPaths.Count 
            $env_paths.DeDuplicatedMachineLevelEnvPaths | Should -Not -Contain $test_path
            Add-PathToCurrentMachineEnvPaths -Path $test_path
            Add-PathToCurrentMachineEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedMachineLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPaths.Count | Should -Be ($count+1)

            Remove-PathFromCurrentMachineEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedMachineLevelEnvPaths | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPaths.Count | Should -Be $count

            Add-PathToCurrentMachineEnvPaths -Path $test_path
            Add-PathToCurrentMachineEnvPaths -Path $test_path
            Add-PathToCurrentMachineEnvPaths -Path $test_path
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedMachineLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPaths.Count | Should -Be ($count+1)

            Remove-MatchedPathsFromCurrentMachineEnvPaths -Pattern $guid
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedMachineLevelEnvPaths | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPaths.Count | Should -Be $count
        }
        It 'Test Merge-RedundantEnvPathsFromCurrentMachineToCurrentUser' -Skip:(!$IsWindows){
            Merge-RedundantEnvPathsFromCurrentMachineToCurrentUser

            $env_paths = Get-xEnvPaths
            $count_user = $env_paths.DeDuplicatedUserLevelEnvPaths.Count
            $count_machine = $env_paths.DeDuplicatedMachineLevelEnvPaths.Count

            Add-PathToCurrentUserEnvPaths -Path $test_path
            Add-PathToCurrentMachineEnvPaths -Path $test_path

            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedUserLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPaths.Count | Should -Be ($count_user+1)
            $env_paths.DeDuplicatedMachineLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPaths.Count | Should -Be ($count_machine+1)

            Merge-RedundantEnvPathsFromCurrentMachineToCurrentUser
            $env_paths = Get-xEnvPaths
            $env_paths.DeDuplicatedUserLevelEnvPaths | Should -Contain $test_path
            $env_paths.DeDuplicatedUserLevelEnvPaths.Count | Should -Be ($count_user+1)
            $env_paths.DeDuplicatedMachineLevelEnvPaths | Should -Not -Contain $test_path
            $env_paths.DeDuplicatedMachineLevelEnvPaths.Count | Should -Be ($count_machine)
        }
    }
}

AfterAll {    
    [Environment]::SetEnvironmentVariable('PATH',$user_env_paths_backup ,'User')
    [Environment]::SetEnvironmentVariable('PATH',$machine_env_paths_backup,'Machine')
    [Environment]::SetEnvironmentVariable('PATH',$process_env_paths_backup,'Process')

    . "${PSScriptRoot}\..\Configs\APIs.Tests.Config.AfterAll.ps1" 
}