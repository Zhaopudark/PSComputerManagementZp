$sb = {
    param(
        $IsxWIndows,
        $IsxLinux,
        $IsxWsl2)

    Describe 'Test PathTools' {
    Context 'Test FormattedPath' {
        It 'Test on Windows dir' -Skip:(!$IsxWIndows){
            $path = [FormattedPath]::new("${test_path}\tEsT_diR")
            $path | Should -BeExactly "$([FormattedPath]::new($test_path))test_dir\"
        }
        It 'Test on Linux dir' -Skip:(!$IsxLinux){
            $path = [FormattedPath]::new("${test_path}\test_dir")
            $path | Should -BeExactly "$([FormattedPath]::new($test_path))test_dir/"
        }
        It 'Test on Wsl2 dir' -Skip:(!$IsxWsl2){
            $path = [FormattedPath]::new("${test_path}\test_dir")
            $path | Should -BeExactly "$([FormattedPath]::new($test_path))test_dir/"
        }
        It 'Test on windows drive' -Skip:(!$IsxWIndows){

            $maybe_c = (Get-ItemProperty ${Home}).PSDrive.Name
            $maybe_c_lower = (Get-ItemProperty ${Home}).PSDrive.Name.ToLower()

            $path = [FormattedPath]::new("$maybe_c`:\")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c`:/")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c`:")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c_lower`:\")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c_lower`:/")
            $path | Should -BeExactly "$maybe_c`:\"

            $path = [FormattedPath]::new("$maybe_c_lower`:")
            $path | Should -BeExactly "$maybe_c`:\"
        }
        It 'Test on Linux drive' -Skip:(!$IsxLinux){
            $maybe_root = (Get-ItemProperty ${Home}).PSDrive.Name # / on Linux and Wsl2, not '/root'
            $path = [FormattedPath]::new("$maybe_root")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root/")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root\")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root\/\/\/\/\/")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root/\/\/\/\/\")
            $path | Should -BeExactly "$maybe_root"
        }
        It 'Test on Wsl2 drive' -Skip:(!$IsxWsl2){
            $maybe_root = (Get-ItemProperty ${Home}).PSDrive.Name # / on Linux and Wsl2, not '/root'
            $path = [FormattedPath]::new("$maybe_root")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root/")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root\")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root\/\/\/\/\/")
            $path | Should -BeExactly "$maybe_root"

            $path = [FormattedPath]::new("$maybe_root/\/\/\/\/\")
            $path | Should -BeExactly "$maybe_root"
        }
    }  
    }
}


. "${PSScriptRoot}\..\..\Module\Config.ps1"

$guid = [guid]::NewGuid()
$test_path = "${Home}\$guid"
New-Item -Path $test_path -ItemType Directory -Force

$test_dir = "${test_path}\test_dir"
$test_file = "${test_path}\test.txt"
New-Item -Path $test_dir -ItemType Directory -Force
New-Item -Path $test_file -ItemType File -Force

$IsxWIndows = Test-Platform 'Windows'
$IsxLinux =  Test-Platform 'Linux'
$IsxWsl2 =  Test-Platform 'Wsl2'

$container = New-PesterContainer -ScriptBlock $sb -Data @{ 
        IsxWIndows = $IsxWIndows
        IsxLinux = $IsxLinux
        IsxWsl2 = $IsxWsl2}
$configuration = New-PesterConfiguration
$configuration.Run.Container = $container
$configuration.Output.Verbosity = 'Detailed'

Invoke-Pester -Configuration $configuration

Remove-Item -Path $test_path -Force -Recurse