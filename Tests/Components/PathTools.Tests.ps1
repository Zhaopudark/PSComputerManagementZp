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
                $($PSVersionTable.Platform) | Should -Not -BeIn @('Windows','Linux','Wsl2')
            }
        }
    }

}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
}