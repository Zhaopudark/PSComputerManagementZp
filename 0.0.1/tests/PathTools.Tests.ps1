BeforeAll {
    Import-Module PSComputerManagementZp -Force
    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force
    Import-Module "${PSScriptRoot}\..\helpers\PathTools.psm1" -Scope local
    # $test_path = Format-Path $test_path

    $test_dir = "${test_path}\test_dir"
    $test_file = "${test_path}\test.txt"
    New-Item -Path $test_dir -ItemType Directory -Force
    New-Item -Path $test_file -ItemType File -Force
}

Describe 'Test PathTools' {
    Context 'Test Format-Path' {
        It 'Test on a exiting dir' {

            if (Test-IfIsOnCertainPlatform -SystemName 'Windows') {
                $path = Format-Path "${test_path}\tEsT_diR"
                $path | Should -BeExactly "$(Format-Path $test_path)test_dir\"
            }elseif (Test-IfIsOnCertainPlatform -SystemName 'Linux') {
                $path = Format-Path "${test_path}\test_dir"
                $path | Should -BeExactly "$(Format-Path $test_path)test_dir/"
            }elseif (Test-IfIsOnCertainPlatform -SystemName 'Wsl2') {
                $path = Format-Path "${test_path}\test_dir"
                $path | Should -BeExactly "$(Format-Path $test_path)test_dir/"
            }else{
                $($PSVersionTable.Platform) | Should -BeIn @('Windows','Linux','Wsl2')
            }
        }
        It 'Test on a exiting file' {
            # Format-Path will not influence `file`'s name.
            # It will maintain the case in `file`'s name.
            # $path = Format-Path "${test_path}\tESt.tXt"
            # Write-Output Resolve-Path $path
            # $path | Should -BeExactly "${test_path}\test.txt"
        }
    }

}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force
}