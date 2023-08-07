BeforeAll {
    $process_env_http_proxy_backup = [Environment]::GetEnvironmentVariable('http_proxy')
    $process_env_https_proxy_backup = [Environment]::GetEnvironmentVariable('https_proxy')
    $process_env_all_proxy_backup = [Environment]::GetEnvironmentVariable('all_proxy')
    $process_env_ftp_proxy_backup = [Environment]::GetEnvironmentVariable('ftp_proxy')
    $process_env_socks_proxy_backup = [Environment]::GetEnvironmentVariable('socks_proxy')
    Import-Module PSComputerManagementZp -Force
}

Describe 'Test ProxyTools' {
    It 'Test Set-EnvProxyIPV4ForShellProcess' {
        Set-EnvProxyIPV4ForShellProcess -ServerIP 127.1.2.3 -PortNumber 4567.
        [Environment]::GetEnvironmentVariable('http_proxy') | Should -Be 'http://127.1.2.3:4567'
        [Environment]::GetEnvironmentVariable('https_proxy') | Should -Be 'http://127.1.2.3:4567'
        [Environment]::GetEnvironmentVariable('all_proxy') | Should -Be 'http://127.1.2.3:4567'
        [Environment]::GetEnvironmentVariable('ftp_proxy') | Should -Be 'http://127.1.2.3:4567'
        [Environment]::GetEnvironmentVariable('socks_proxy') | Should -Be 'socks5://127.1.2.3:4567'
    }
    It 'Test Remove-EnvProxyIPV4ForShellProcess' {
        Remove-EnvProxyIPV4ForShellProcess
        [Environment]::GetEnvironmentVariable('http_proxy') | Should -Be $null
        [Environment]::GetEnvironmentVariable('https_proxy') | Should -Be $null
        [Environment]::GetEnvironmentVariable('all_proxy') | Should -Be $null
        [Environment]::GetEnvironmentVariable('ftp_proxy') | Should -Be $null
        [Environment]::GetEnvironmentVariable('socks_proxy') | Should -Be $null
    }

}

AfterAll {
    Remove-Module PSComputerManagementZp -Force
    [Environment]::SetEnvironmentVariable('http_proxy',$process_env_http_proxy_backup)
    [Environment]::SetEnvironmentVariable('https_proxy',$process_env_https_proxy_backup)
    [Environment]::SetEnvironmentVariable('all_proxy',$process_env_all_proxy_backup)
    [Environment]::SetEnvironmentVariable('ftp_proxy',$process_env_ftp_proxy_backup)
    [Environment]::SetEnvironmentVariable('socks_proxy',$process_env_socks_proxy_backup)
}