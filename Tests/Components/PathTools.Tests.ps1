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
        It 'Test on Windows dir' -Skip:(!(Test-Platform 'Windows')){
            $path = Format-Path "${test_path}\tEsT_diR"
            $path | Should -BeExactly "$(Format-Path $test_path)test_dir\"
        }
        It 'Test on Linux dir' -Skip:(!(Test-Platform 'Linux')){
            $path = Format-Path "${test_path}\test_dir"
            $path | Should -BeExactly "$(Format-Path $test_path)test_dir/"
        }
        It 'Test on Wsl2 dir' -Skip:(!(Test-Platform 'Wsl2')){
            $path = Format-Path "${test_path}\test_dir"
            $path | Should -BeExactly "$(Format-Path $test_path)test_dir/"
        }
        It 'Test on windows drive' -Skip:(!(Test-Platform 'Windows')){
            # 获取 FileSystem 提供程序的驱动器
            $filesystemDrives = Get-PSDrive -PSProvider FileSystem

            # 尝试选择 C 盘
            $selectedDrive = $filesystemDrives | Where-Object { $_.Name -eq "C" }

            # 如果 C 盘不存在，则选择第一个驱动器
            if (-not $selectedDrive) {
                $selectedDrive = $filesystemDrives[0]
            }

            $maybe_c = $selectedDrive.Name
            $maybe_c_lower = $selectedDrive.Name.ToLower()

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
        }
        It 'Test on Linux drive' -Skip:(!(Test-Platform 'Linux')){
            $maybe_root = ((Get-PSDrive -PSProvider FileSystem)[0]).Name # / on Linux and Wsl2, not '/root'
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
        }
        It 'Test on Wsl2 drive' -Skip:(!(Test-Platform 'Wsl2')){
            $maybe_root = ((Get-PSDrive -PSProvider FileSystem)[0]).Name # / on Linux and Wsl2, not '/root'
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
        }
    }

}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
}