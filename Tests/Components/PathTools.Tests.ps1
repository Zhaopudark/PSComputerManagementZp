BeforeAll {
    foreach ($item in (Get-ChildItem "${PSScriptRoot}\..\..\Module" -Filter *.ps1)){
        Import-Module $item.FullName -Force -Scope Local
    }
    . "${PSScriptRoot}\..\..\Module\Config.ps1"

    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force

    $test_dir = "${test_path}\test_dir"
    $test_file = "${test_path}\test.txt"
    New-Item -Path $test_dir -ItemType Directory -Force
    New-Item -Path $test_file -ItemType File -Force
}

Describe 'Test PathTools' {
    Context 'Test Format-LiteralPath' {
        It 'Test on Windows dir' -Skip:(!(Test-Platform 'Windows')){
            $path = [FormattedPath]::new("${test_path}\tEsT_diR")
            $path | Should -BeExactly "$([FormattedPath]::new($test_path))test_dir\"
        }
        It 'Test on Linux dir' -Skip:(!(Test-Platform 'Linux')){
            $path = [FormattedPath]::new("${test_path}\test_dir")
            $path | Should -BeExactly "$([FormattedPath]::new($test_path))test_dir/"
        }
        It 'Test on Wsl2 dir' -Skip:(!(Test-Platform 'Wsl2')){
            $path = [FormattedPath]::new("${test_path}\test_dir")
            $path | Should -BeExactly "$([FormattedPath]::new($test_path))test_dir/"
        }
        It 'Test on windows drive' -Skip:(!(Test-Platform 'Windows')){

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
        It 'Test on Linux drive' -Skip:(!(Test-Platform 'Linux')){
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
        It 'Test on Wsl2 drive' -Skip:(!(Test-Platform 'Wsl2')){
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

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
}