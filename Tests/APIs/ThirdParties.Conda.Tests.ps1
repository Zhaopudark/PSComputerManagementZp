BeforeAll {
    $user_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','User')
    $machine_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','Machine')
    $process_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','Process')

    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"

}

Describe 'Test the third party assister' {
    Context 'Register and unregeister env variables for conda' {
        It 'Test Register-AndBackupEnvItemForConda' {
            $Env:CUDA_PATH = ''
            Register-AndBackupEnvItemForConda -Name 'CUDA_PATH' -Value 'aaa/bbb/ccc'
            $Env:CUDA_PATH | Should -BeExactly 'aaa/bbb/ccc'
            $Env:CUDA_PATH_CONDA_BACK | Should -BeNullOrEmpty

            Register-AndBackupEnvItemForConda -Name 'CUDA_PATH' -Value 'aaa/bbb/ccc/ddd'
            $Env:CUDA_PATH | Should -BeExactly 'aaa/bbb/ccc/ddd'
            $Env:CUDA_PATH_CONDA_BACK | Should -BeExactly 'aaa/bbb/ccc'
        }
        It 'Test Unregister-WithBackupEnvItemForConda'{
            Unregister-WithBackupEnvItemForConda -Name 'CUDA_PATH'
            $Env:CUDA_PATH | Should -BeExactly 'aaa/bbb/ccc'
            $Env:CUDA_PATH_CONDA_BACK | Should -BeNullOrEmpty
        }
    }
}

AfterAll {
    [Environment]::SetEnvironmentVariable('PATH',$user_env_paths_backup ,'User')
    [Environment]::SetEnvironmentVariable('PATH',$machine_env_paths_backup,'Machine')
    [Environment]::SetEnvironmentVariable('PATH',$process_env_paths_backup,'Process')
}