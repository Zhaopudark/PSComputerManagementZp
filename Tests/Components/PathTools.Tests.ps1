BeforeAll {
    foreach ($item in (Get-ChildItem "${PSScriptRoot}\..\..\Module" -Filter *.psm1)){
        Import-Module $item.FullName -Force -Scope Local
    }

    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force

    $test_dir = "${test_path}\test_dir"
    $test_file = "${test_path}\test.txt"
    New-Item -Path $test_dir -ItemType Directory -Force
    New-Item -Path $test_file -ItemType File -Force
}

Describe 'Test PathTools' {
    Context 'Test Format-Path' {
        It 'Test on dir' {
            
            if (Test-Platform 'Windows') {
                $path = Format-Path "${test_path}\tEsT_diR"
                $path | Should -BeExactly "$(Format-Path $test_path)test_dir\"
            }elseif (Test-Platform 'Linux') {
                $path = Format-Path "${test_path}\test_dir"
                $path | Should -BeExactly "$(Format-Path $test_path)test_dir/"
            }elseif (Test-Platform 'Wsl2') {
                $path = Format-Path "${test_path}\test_dir"
                $path | Should -BeExactly "$(Format-Path $test_path)test_dir/"
            }else{
                throw "The current platform, $($PSVersionTable.Platform), has not been supported yet."
            }
        }
        It 'Test on drive' {

            $maybe_root = ((Get-PSDrive -PSProvider FileSystem)[0]).Name # / on Linux and Wsl2, not '/root'
            $maybe_c = ((Get-PSDrive -PSProvider FileSystem)[0]).Name
            $maybe_c_lower = ((Get-PSDrive -PSProvider FileSystem)[0]).Name.ToLower()

            if (Test-Platform 'Windows') {
                $path = Format-Path "$maybe_c`:\"
                $path | Should -BeExactly "$maybe_c`:\"

                $path = Format-Path "$maybe_c`:/"
                $path | Should -BeExactly "$maybe_c`:\"

                $path = Format-Path "$maybe_c`:"
                $path | Should -BeExactly "$maybe_c`:\"

                $path = Format-Path "$maybe_c_lower`:\"
                $path | Should -BeExactly "$maybe_c`:\"

                $path = Format-Path "$maybe_c_lower`:/"
                $path | Should -BeExactly "$maybe_c`:\"

                $path = Format-Path "$maybe_c_lower`:"
                $path | Should -BeExactly "$maybe_c`:\"

            }elseif (Test-Platform 'Linux') {
                $path = Format-Path "$maybe_root"
                $path | Should -BeExactly "$maybe_root"

                $path = Format-Path "$maybe_root/"
                $path | Should -BeExactly "$maybe_root"

                $path = Format-Path "$maybe_root\"
                $path | Should -BeExactly "$maybe_root"

                $path = Format-Path "$maybe_root\/\/\/\/\/"
                $path | Should -BeExactly "$maybe_root"

                $path = Format-Path "$maybe_root/\/\/\/\/\"
                $path | Should -BeExactly "$maybe_root"

            }elseif (Test-Platform 'Wsl2') {
                $path = Format-Path "$maybe_root"
                $path | Should -BeExactly "$maybe_root"

                $path = Format-Path "$maybe_root/"
                $path | Should -BeExactly "$maybe_root"

                $path = Format-Path "$maybe_root\"
                $path | Should -BeExactly "$maybe_root"

                $path = Format-Path "$maybe_root\/\/\/\/\/"
                $path | Should -BeExactly "$maybe_root"

                $path = Format-Path "$maybe_root/\/\/\/\/\"
                $path | Should -BeExactly "$maybe_root"
            }else{
                throw "The current platform, $($PSVersionTable.Platform), has not been supported yet."
            }
        }
    }

}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
}