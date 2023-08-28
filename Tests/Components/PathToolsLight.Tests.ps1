BeforeAll {
    class FormattedFileSystemPath1 {
        FormattedFileSystemPath1([string] $Path) {
            Write-Verbose "PWD is:$PWD" -Verbose
            $link_target = (Get-ChildItem 'usr' -ErrorAction Stop| Where-Object Name -eq 'sbin')
        }
    }
    class FormattedFileSystemPath2 {
        FormattedFileSystemPath2([string] $Path) {
            $link_target  = $this.PreProcess()
        }
        [string] PreProcess(){
            Write-Verbose "PWD is:$PWD" -Verbose
            return (Get-ChildItem 'usr' -ErrorAction Stop| Where-Object Name -eq 'sbin')
        }
    }
}

Describe '[Test PathToolsLight]' {
    Context '[Test the formatting feature of FormattedFileSystemPath]' {
        It '[Test on FormattedFileSystemPath1]'{
            {Write-Verbose ([FormattedFileSystemPath1]::new('???')) -Verbose }| Should -Throw
        }

        It '[Test on FormattedFileSystemPath2]'{
            {Write-Verbose ([FormattedFileSystemPath2]::new('???')) -Verbose }| Should -Throw
        }

    }  
}

AfterAll {
    # $null
}