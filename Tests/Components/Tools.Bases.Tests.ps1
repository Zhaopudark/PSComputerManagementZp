BeforeAll {
    $guid = [guid]::NewGuid()
    $test_path = "${Home}/$guid"
    New-Item -Path $test_path -ItemType Directory -Force

    New-Item -Path "$test_path/test_dir" -ItemType Directory -Force
    New-Item -Path "$test_path/test.txt" -ItemType File -Force
}

Describe '[Test Bases Tools]' {
    Context '[Test Version Tools]' {
        It '[Test Format-VersionTo4SegmentFormat]' {
            Format-VersionTo4SegmentFormat -RawVersion 'v0.0.1' | Should -Be '0.0.1.0'
            Format-VersionTo4SegmentFormat -RawVersion 'v0.1' | Should -Be '0.1.0.0'
            Format-VersionTo4SegmentFormat -RawVersion 'v1' | Should -Be '1.0.0.0'
            Format-VersionTo4SegmentFormat -RawVersion 'v1.2.3.4.5.6.7' | Should -Be '1.2.3.4'
            {Format-VersionTo4SegmentFormat -RawVersion 'x1.2.3.4.5.6.7'} | Should -Throw "Invalid version number: x1.2.3.4.5.6.7. It should be in the format like vX, vX.X, vX.X.X, vX.X.X.X...."
        }
    }
}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
}