BeforeAll {
    . "${PSScriptRoot}\..\..\Module\Config.ps1"

    $guid = [guid]::NewGuid()
    $test_path = "${Home}/$guid"
    New-Item -Path $test_path -ItemType Directory -Force

    New-Item -Path "$test_path/test_dir" -ItemType Directory -Force
    New-Item -Path "$test_path/test.txt" -ItemType File -Force

}

Describe '[Test AuthorizationTools]' {
    Context '[Test Reset-PathAttribute]' {
        It '[Test on Windows dir with symbolik link]' -Skip:(!$IsWIndows){
            (get-item "$test_path/test_dir").Attributes | Should -BeExactly 'Directory'
            Set-ItemProperty "$test_path/test_dir" -Name Attributes -Value 'Hidden'
            {(get-item "$test_path/test_dir" -ErrorAction Stop).Attributes} | Should -Throw
            (get-item "$test_path/test_dir" -Force).Attributes | Should -BeExactly 'Hidden, Directory'

            New-Item -Path "$test_path/test_dir_symbilic_link" -ItemType SymbolicLink -Target "$test_path/test_dir"
            (get-item "$test_path/test_dir_symbilic_link").Attributes | Should -BeExactly 'Directory, ReparsePoint'
            Set-ItemProperty "$test_path/test_dir_symbilic_link" -Name Attributes -Value 'Hidden'
            {(get-item "$test_path/test_dir_symbilic_link" -ErrorAction Stop).Attributes} | Should -Throw
            (get-item "$test_path/test_dir_symbilic_link" -Force).Attributes | Should -BeExactly 'Hidden, Directory, ReparsePoint'
            Reset-PathAttribute -Path "$test_path/test_dir_symbilic_link"
            (get-item "$test_path/test_dir_symbilic_link").Attributes | Should -BeExactly 'Directory, ReparsePoint'

            Set-ItemProperty "$test_path/test_dir" -Name Attributes -Value 'Normal'
            (get-item "$test_path/test_dir").Attributes | Should -BeExactly 'Directory'

            Remove-Item "$test_path/test_dir_symbilic_link"
        }
        It '[Test on Windows dir with junction point]' -Skip:(!$IsWIndows){

            (get-item "$test_path/test_dir").Attributes | Should -BeExactly 'Directory'
            Set-ItemProperty "$test_path/test_dir" -Name Attributes -Value 'Hidden'
            {(get-item "$test_path/test_dir" -ErrorAction Stop).Attributes} | Should -Throw
            (get-item "$test_path/test_dir" -Force).Attributes | Should -BeExactly 'Hidden, Directory'

            New-Item -Path "$test_path/test_dir_junction" -ItemType Junction -Target "$test_path/test_dir"
            (get-item "$test_path/test_dir_junction").Attributes | Should -BeExactly 'Directory, ReparsePoint'
            Set-ItemProperty "$test_path/test_dir_junction" -Name Attributes -Value 'Hidden'
            {(get-item "$test_path/test_dir_junction" -ErrorAction Stop).Attributes} | Should -Throw
            (get-item "$test_path/test_dir_junction" -Force).Attributes | Should -BeExactly 'Hidden, Directory, ReparsePoint'
            Reset-PathAttribute -Path "$test_path/test_dir_junction"
            (get-item "$test_path/test_dir_junction").Attributes | Should -BeExactly 'Directory, ReparsePoint'

            Set-ItemProperty "$test_path/test_dir" -Name Attributes -Value 'Normal'
            (get-item "$test_path/test_dir").Attributes | Should -BeExactly 'Directory'

            Remove-Item "$test_path/test_dir_junction"

        }
        It '[Test on Windows file with symbolik link]' -Skip:(!$IsWIndows){
            (get-item "$test_path/test.txt").Attributes | Should -BeExactly 'Archive'
            Set-ItemProperty "$test_path/test.txt" -Name Attributes -Value 'Hidden'
            {(get-item "$test_path/test.txt" -ErrorAction Stop).Attributes} | Should -Throw
            (get-item "$test_path/test.txt" -Force).Attributes | Should -BeExactly 'Hidden'

            New-Item -Path "$test_path/test_txt_symbilic_link" -ItemType SymbolicLink -Target "$test_path/test.txt"
            (get-item "$test_path/test_txt_symbilic_link").Attributes | Should -BeExactly 'Archive, ReparsePoint'
            Set-ItemProperty "$test_path/test_txt_symbilic_link" -Name Attributes -Value 'Hidden'
            {(get-item "$test_path/test_txt_symbilic_link" -ErrorAction Stop).Attributes} | Should -Throw
            (get-item "$test_path/test_txt_symbilic_link" -Force).Attributes | Should -BeExactly 'Hidden, ReparsePoint'
            Reset-PathAttribute -Path "$test_path/test_txt_symbilic_link"
            (get-item "$test_path/test_txt_symbilic_link").Attributes | Should -BeExactly 'Archive, ReparsePoint'

            Set-ItemProperty "$test_path/test.txt" -Name Attributes -Value 'Archive'
            (get-item "$test_path/test.txt").Attributes | Should -BeExactly 'Archive'

            Remove-Item "$test_path/test_txt_symbilic_link"
        }
        It '[Test on Windows file with hard link]' -Skip:(!$IsWIndows){
            # Hardlink
            (get-item "$test_path/test.txt").Attributes | Should -BeExactly 'Archive'
            Set-ItemProperty "$test_path/test.txt" -Name Attributes -Value 'Hidden'
            {(get-item "$test_path/test.txt" -ErrorAction Stop).Attributes} | Should -Throw
            (get-item "$test_path/test.txt" -Force).Attributes | Should -BeExactly 'Hidden'

            New-Item -Path "$test_path/test_txt_hard_link" -ItemType HardLink -Target "$test_path/test.txt"
            {(get-item "$test_path/test_txt_hard_link" -ErrorAction Stop).Attributes}| Should -Throw
            (get-item "$test_path/test_txt_hard_link" -Force).Attributes | Should -BeExactly 'Hidden, Archive'
            (get-item "$test_path/test.txt" -Force).Attributes | Should -BeExactly 'Hidden, Archive'

            Reset-PathAttribute -Path "$test_path/test_txt_hard_link"
            (get-item "$test_path/test_txt_hard_link").Attributes | Should -BeExactly 'Archive'
            (get-item "$test_path/test.txt").Attributes | Should -BeExactly 'Archive'

            Remove-Item "$test_path/test_txt_hard_link"

        }
        It '[Test on Linux dir with symbolik link]' -Skip:(!$IsLinux){
            New-Item -Path "$test_path/test_dir_symbilic_link" -ItemType SymbolicLink -Target "$test_path/test_dir"
            {Reset-PathAttribute -Path "$test_path/test_dir_symbilic_link" -ErrorAction Stop} | Should -Throw
            Remove-Item "$test_path/test_dir_symbilic_link"
        }
        It '[Test on Linux dir with junction point]' -Skip:(!$IsLinux){
            # pass since it is not supported on linux file system
        }
        It '[Test on Linux file with symbolik link]' -Skip:(!$IsLinux){
            New-Item -Path "$test_path/test_txt_symbilic_link" -ItemType SymbolicLink -Target "$test_path/test.txt"
            {Reset-PathAttribute -Path "$test_path/test_txt_symbilic_link" -ErrorAction Stop} | Should -Throw
            Remove-Item "$test_path/test_txt_symbilic_link"
        }
        It '[Test on Linux file with hard link]' -Skip:(!$IsLinux){
            New-Item -Path "$test_path/test_txt_hard_link" -ItemType HardLink -Target "$test_path/test.txt"
            {Reset-PathAttribute -Path "$test_path/test_txt_hard_link" -ErrorAction Stop} | Should -Throw
            Remove-Item "$test_path/test_txt_hard_link"
        }
    }
    Context '[Test Get-PathType]' {
        It '[Test on Windows]' -Skip:(!$IsWindows){
            Get-PathType "$test_path/test_dir" | Should -BeExactly 'Home\Directory'
            Get-PathType "$test_path/test.txt" | Should -BeExactly 'Home\File'

            New-Item -Path "$test_path/test_dir_symbilic_link" -ItemType SymbolicLink -Target "$test_path/test_dir"
            Get-PathType "$test_path/test_dir_symbilic_link" | Should -BeExactly 'Home\SymbolicLinkDirectory'
            Remove-Item "$test_path/test_dir_symbilic_link"

            New-Item -Path "$test_path/test_dir_junction" -ItemType Junction -Target "$test_path/test_dir"
            Get-PathType "$test_path/test_dir_junction" | Should -BeExactly 'Home\Junction'
            Remove-Item "$test_path/test_dir_junction"

            New-Item -Path "$test_path/test_txt_symbilic_link" -ItemType SymbolicLink -Target "$test_path/test.txt"
            Get-PathType "$test_path/test_txt_symbilic_link" | Should -BeExactly 'Home\SymbolicLinkFile'
            Remove-Item "$test_path/test_txt_symbilic_link"

            New-Item -Path "$test_path/test_txt_hard_link" -ItemType HardLink -Target "$test_path/test.txt"
            Get-PathType "$test_path/test_txt_hard_link" | Should -BeExactly 'Home\HardLink'
            Get-PathType "$test_path/test.txt" | Should -BeExactly 'Home\HardLink'
            Remove-Item "$test_path/test_txt_hard_link"
            Get-PathType "$test_path/test.txt" | Should -BeExactly 'Home\File'

            Get-PathType "${Home}" | Should -BeExactly 'Home\Root'

            $maybe_c = (Get-ItemProperty ${Home}).PSDrive.Name

            {Get-PathType "$maybe_c`:\" }| Should -Throw
            {Get-PathType "$maybe_c`:\System Volume Information"}| Should -Throw
            {Get-PathType "$maybe_c`:\`$Recycle.Bin" }| Should -Throw
        }
        It '[Test on Linux file]' -Skip:(!$IsLinux){
            {Get-PathType "$test_path/test_dir" }| Should -Throw
        }
    }
}

AfterAll {
    Remove-Item -Path $test_path -Force -Recurse
}