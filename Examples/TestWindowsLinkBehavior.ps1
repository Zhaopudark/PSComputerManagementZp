# This test is not for CI/CD because it need atleast 2 dirves, such as C: and D:
# To find more conclusions on NTFS and ReFS respectively, this test can be run twice.
# One is C:(NTFS)|D:(NTFS) and the other is C:(NTFS)|D:(ReFS)
# For more information, see the [post](https://little-train.com/posts/f76966e4.html).
BeforeAll {
    $guid = [guid]::NewGuid()
    function Test-LinkAclBeahvior([string]$Link,[string]$Source){
    <#
    .DESCRIPTION
    Test link's ACL beahvior, i.e., check the ACL info whether be syncronized
    between Link and Source  on `SymbolicLink` `Junction` or `HardLink`

    We use `Owner` info to test.
    #>
        $LinkAcl =  Get-Acl -Path $Link
        $LinkAcl_bak =  Get-Acl -Path $Link
        $SourceAcl =  Get-Acl -Path $Source
        $SourceAcl_bak =  Get-Acl -Path $Source

        # unify Owner
        $LinkAcl.SetOwner((new-object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")))
        $SourceAcl.SetOwner((new-object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")))
        Set-Acl $Link -AclObject $LinkAcl
        Set-Acl $Source -AclObject $SourceAcl

        # make Owner different
        $LinkAcl =  Get-Acl -Path $Link
        $SourceAcl =  Get-Acl -Path $Source
        $LinkAcl.SetOwner((new-object System.Security.Principal.NTAccount("BUILTIN\Administrators")))
        $SourceAcl.SetOwner((new-object System.Security.Principal.NTAccount("NT AUTHORITY\SYSTEM")))
        Set-Acl $Link -AclObject $LinkAcl
        Set-Acl $Source -AclObject $SourceAcl

        # test sync
        $LinkAcl =  Get-Acl -Path $Link
        $SourceAcl =  Get-Acl -Path $Source
        # Write-Output $LinkAcl.Owner
        # Write-Output $SourceAcl.Owner
        $output = ($LinkAcl.Owner -eq $SourceAcl.Owner)

        # restore
        Set-Acl $Link -AclObject $LinkAcl_bak
        Set-Acl $Source -AclObject $SourceAcl_bak

        return $output
    }
    function New-AllItem {
        [CmdletBinding(SupportsShouldProcess)]
        param (
            $guid
        )
        if ($PSCmdlet.ShouldProcess("New all items for tests in ${Home}\${guid} and D:\${guid}, including these 2 dir.",'','')){
            New-Item -Path "${Home}\${guid}" -ItemType Directory
            New-Item -Path "D:\${guid}" -ItemType Directory

            New-Item -Path "${Home}\${guid}\file_for_hardlink.txt" -ItemType File
            New-Item -Path "${Home}\${guid}\hardlink" -ItemType HardLink -Target "${Home}\${guid}\file_for_hardlink.txt"

            New-Item -Path "D:\${guid}\file_for_hardlink.txt" -ItemType File
            New-Item -Path "D:\${guid}\hardlink" -ItemType HardLink -Target "D:\${guid}\file_for_hardlink.txt"

            New-Item -Path "${Home}\${guid}\dir_for_local_junction" -ItemType Directory
            New-Item -Path "${Home}\${guid}\local_junction" -ItemType Junction -Target "${Home}\${guid}\dir_for_local_junction"

            New-Item -Path "D:\${guid}\dir_for_local_junction" -ItemType Directory
            New-Item -Path "D:\${guid}\local_junction" -ItemType Junction -Target "D:\${guid}\dir_for_local_junction"

            New-Item -Path "${Home}\${guid}\dir_for_non_local_junction" -ItemType Directory
            New-Item -Path "D:\${guid}\non_local_junction" -ItemType Junction -Target "${Home}\${guid}\dir_for_non_local_junction"

            New-Item -Path "D:\${guid}\dir_for_non_local_junction" -ItemType Directory
            New-Item -Path "${Home}\${guid}\non_local_junction" -ItemType Junction -Target "D:\${guid}\dir_for_non_local_junction"


            New-Item -Path "${Home}\${guid}\fire_for_local_symbiliclink.txt" -ItemType File
            New-Item -Path "${Home}\${guid}\local_symbiliclink-txt" -ItemType SymbolicLink -Target "${Home}\${guid}\fire_for_local_symbiliclink.txt"

            New-Item -Path "D:\${guid}\fire_for_local_symbiliclink.txt" -ItemType File
            New-Item -Path "D:\${guid}\local_symbiliclink-txt" -ItemType SymbolicLink -Target "D:\${guid}\fire_for_local_symbiliclink.txt"

            New-Item -Path "${Home}\${guid}\fire_for_non_local_symbiliclink.txt" -ItemType File
            New-Item -Path "D:\${guid}\non_local_symbiliclink-txt" -ItemType SymbolicLink -Target "${Home}\${guid}\fire_for_non_local_symbiliclink.txt"

            New-Item -Path "D:\${guid}\fire_for_non_local_symbiliclink.txt" -ItemType File
            New-Item -Path "${Home}\${guid}\non_local_symbiliclink-txt" -ItemType SymbolicLink -Target "D:\${guid}\fire_for_non_local_symbiliclink.txt"

            New-Item -Path "${Home}\${guid}\dir_for_local_symbiliclink" -ItemType Directory
            New-Item -Path "${Home}\${guid}\local_symbiliclink" -ItemType SymbolicLink -Target "${Home}\${guid}\dir_for_local_symbiliclink"

            New-Item -Path "D:\${guid}\dir_for_local_symbiliclink" -ItemType Directory
            New-Item -Path "D:\${guid}\local_symbiliclink" -ItemType SymbolicLink -Target "D:\${guid}\dir_for_local_symbiliclink"

            New-Item -Path "${Home}\${guid}\dir_for_non_local_symbiliclink" -ItemType Directory
            New-Item -Path "D:\${guid}\non_local_symbiliclink" -ItemType SymbolicLink -Target "${Home}\${guid}\dir_for_non_local_symbiliclink"

            New-Item -Path "D:\${guid}\dir_for_non_local_symbiliclink" -ItemType Directory
            New-Item -Path "${Home}\${guid}\non_local_symbiliclink" -ItemType SymbolicLink -Target "D:\${guid}\dir_for_non_local_symbiliclink"
        }
    }
    function Remove-AllItem {
        [CmdletBinding(SupportsShouldProcess)]
        param (
            $guid
        )
        if ($PSCmdlet.ShouldProcess("Remove all items for tests in ${Home}\${guid} and D:\${guid}, including these 2 dir.",'','')){
            Remove-Item "${Home}\${guid}" -Force -Recurse
            Remove-Item "D:\${guid}" -Force -Recurse
        }
    }
    New-AllItem -guid $guid
}

Describe 'Links Behavior' -Skip:(!$IsWindows) {
    Context 'Test Basic Attributes'{
        It 'Test HardLink' {
            (Get-ItemProperty "${Home}\${guid}\file_for_hardlink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "${Home}\${guid}\file_for_hardlink.txt").LinkType | Should -Be 'HardLink'
            (Get-ItemProperty "${Home}\${guid}\file_for_hardlink.txt").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "${Home}\${guid}\hardlink").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "${Home}\${guid}\hardlink").LinkType | Should -Be 'HardLink'
            (Get-ItemProperty "${Home}\${guid}\hardlink").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "D:\${guid}\file_for_hardlink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "D:\${guid}\file_for_hardlink.txt").LinkType | Should -Be 'HardLink'
            (Get-ItemProperty "D:\${guid}\file_for_hardlink.txt").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "D:\${guid}\hardlink").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "D:\${guid}\hardlink").LinkType | Should -Be 'HardLink'
            (Get-ItemProperty "D:\${guid}\hardlink").LinkTarget | Should -BeNullOrEmpty
        }
        It 'Test Junction' {
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_junction").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_junction").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_junction").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "${Home}\${guid}\local_junction").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\local_junction").LinkType | Should -Be 'Junction'
            (Get-ItemProperty "${Home}\${guid}\local_junction").LinkTarget | Should -Be "${Home}\${guid}\dir_for_local_junction"

            (Get-ItemProperty "D:\${guid}\dir_for_local_junction").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "D:\${guid}\dir_for_local_junction").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\dir_for_local_junction").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "D:\${guid}\local_junction").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\local_junction").LinkType | Should -Be 'Junction'
            (Get-ItemProperty "D:\${guid}\local_junction").LinkTarget | Should -Be "D:\${guid}\dir_for_local_junction"

            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_junction").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_junction").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_junction").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "D:\${guid}\non_local_junction").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\non_local_junction").LinkType | Should -Be 'Junction'
            (Get-ItemProperty "D:\${guid}\non_local_junction").LinkTarget | Should -Be  "${Home}\${guid}\dir_for_non_local_junction"

            (Get-ItemProperty "D:\${guid}\dir_for_non_local_junction").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_junction").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_junction").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "${Home}\${guid}\non_local_junction").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\non_local_junction").LinkType | Should -Be 'Junction'
            (Get-ItemProperty "${Home}\${guid}\non_local_junction").LinkTarget | Should -Be "D:\${guid}\dir_for_non_local_junction"
        }
        It 'Test symbolic file' {
            (Get-ItemProperty "${Home}\${guid}\fire_for_local_symbiliclink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "${Home}\${guid}\fire_for_local_symbiliclink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\fire_for_local_symbiliclink.txt").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink-txt").Attributes | Should -Be 'Archive, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink-txt").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink-txt").LinkTarget | Should -Be "${Home}\${guid}\fire_for_local_symbiliclink.txt"

            (Get-ItemProperty "D:\${guid}\fire_for_local_symbiliclink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "D:\${guid}\fire_for_local_symbiliclink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\fire_for_local_symbiliclink.txt").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "D:\${guid}\local_symbiliclink-txt").Attributes | Should -Be 'Archive, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\local_symbiliclink-txt").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "D:\${guid}\local_symbiliclink-txt").LinkTarget | Should -Be "D:\${guid}\fire_for_local_symbiliclink.txt"

            (Get-ItemProperty "${Home}\${guid}\fire_for_non_local_symbiliclink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "${Home}\${guid}\fire_for_non_local_symbiliclink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\fire_for_non_local_symbiliclink.txt").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink-txt").Attributes | Should -Be 'Archive, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink-txt").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink-txt").LinkTarget | Should -Be "${Home}\${guid}\fire_for_non_local_symbiliclink.txt"

            (Get-ItemProperty "D:\${guid}\fire_for_non_local_symbiliclink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "D:\${guid}\fire_for_non_local_symbiliclink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\fire_for_non_local_symbiliclink.txt").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink-txt").Attributes | Should -Be 'Archive, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink-txt").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink-txt").LinkTarget | Should -Be "D:\${guid}\fire_for_non_local_symbiliclink.txt"
        }
        It 'Test symbolic dir' {
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_symbiliclink").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_symbiliclink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_symbiliclink").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink").LinkTarget | Should -Be "${Home}\${guid}\dir_for_local_symbiliclink"

            (Get-ItemProperty "D:\${guid}\dir_for_local_symbiliclink").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "D:\${guid}\dir_for_local_symbiliclink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\dir_for_local_symbiliclink").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "D:\${guid}\local_symbiliclink").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\local_symbiliclink").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "D:\${guid}\local_symbiliclink").LinkTarget | Should -Be "D:\${guid}\dir_for_local_symbiliclink"

            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_symbiliclink").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_symbiliclink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_symbiliclink").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink").LinkTarget | Should -Be "${Home}\${guid}\dir_for_non_local_symbiliclink"

            (Get-ItemProperty "D:\${guid}\dir_for_non_local_symbiliclink").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_symbiliclink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_symbiliclink").LinkTarget | Should -BeNullOrEmpty

            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink").LinkTarget | Should -Be "D:\${guid}\dir_for_non_local_symbiliclink"
        }
    }
    Context 'Test Deletion Behavior1 (delete link)'{
        It 'Test deletion about hardlink' {
            Remove-AllItem -guid $guid
            New-AllItem -guid $guid
            Remove-Item "${Home}\${guid}\hardlink" -Force
            (Get-ItemProperty "${Home}\${guid}\file_for_hardlink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "${Home}\${guid}\file_for_hardlink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\file_for_hardlink.txt").LinkTarget | Should -BeNullOrEmpty

            Remove-Item "D:\${guid}\hardlink" -Force
            (Get-ItemProperty "D:\${guid}\file_for_hardlink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "D:\${guid}\file_for_hardlink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\file_for_hardlink.txt").LinkTarget | Should -BeNullOrEmpty

        }
        It 'Test deletion about junction' {
            New-Item "${Home}\${guid}\local_junction\test.txt"
            Remove-Item "${Home}\${guid}\local_junction" -Force -Recurse
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_junction").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_junction").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_junction").LinkTarget | Should -BeNullOrEmpty
            "${Home}\${guid}\dir_for_local_junction\test.txt" | Should -Exist

            New-Item "D:\${guid}\local_junction\test.txt"
            Remove-Item "D:\${guid}\local_junction" -Force -Recurse
            (Get-ItemProperty "D:\${guid}\dir_for_local_junction").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "D:\${guid}\dir_for_local_junction").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\dir_for_local_junction").LinkTarget | Should -BeNullOrEmpty
            "D:\${guid}\dir_for_local_junction\test.txt" | Should -Exist

            New-Item "D:\${guid}\non_local_junction\test.txt"
            Remove-item "D:\${guid}\non_local_junction" -Force -Recurse
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_junction").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_junction").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_junction").LinkTarget | Should -BeNullOrEmpty
            "${Home}\${guid}\dir_for_non_local_junction\test.txt" | Should -Exist

            New-item "${Home}\${guid}\non_local_junction\test.txt"
            Remove-item "${Home}\${guid}\non_local_junction" -Force -Recurse
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_junction").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_junction").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_junction").LinkTarget | Should -BeNullOrEmpty
            "D:\${guid}\dir_for_non_local_junction\test.txt" | Should -Exist
        }
        It 'Test deletion about symbolic link file' {
            Remove-Item "${Home}\${guid}\local_symbiliclink-txt" -Force
            (Get-ItemProperty "${Home}\${guid}\fire_for_local_symbiliclink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "${Home}\${guid}\fire_for_local_symbiliclink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\fire_for_local_symbiliclink.txt").LinkTarget | Should -BeNullOrEmpty

            Remove-Item "D:\${guid}\local_symbiliclink-txt" -Force
            (Get-ItemProperty "D:\${guid}\fire_for_local_symbiliclink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "D:\${guid}\fire_for_local_symbiliclink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\fire_for_local_symbiliclink.txt").LinkTarget | Should -BeNullOrEmpty

            Remove-Item "D:\${guid}\non_local_symbiliclink-txt" -Force
            (Get-ItemProperty "${Home}\${guid}\fire_for_non_local_symbiliclink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "${Home}\${guid}\fire_for_non_local_symbiliclink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\fire_for_non_local_symbiliclink.txt").LinkTarget | Should -BeNullOrEmpty

            Remove-Item "${Home}\${guid}\non_local_symbiliclink-txt" -Force
            (Get-ItemProperty "D:\${guid}\fire_for_non_local_symbiliclink.txt").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "D:\${guid}\fire_for_non_local_symbiliclink.txt").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\fire_for_non_local_symbiliclink.txt").LinkTarget | Should -BeNullOrEmpty

        }
        It 'Test deletion about symbolic link dir' {
            New-Item "${Home}\${guid}\local_symbiliclink\test.txt"
            Remove-Item "${Home}\${guid}\local_symbiliclink" -Force -Recurse
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_symbiliclink").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_symbiliclink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\dir_for_local_symbiliclink").LinkTarget | Should -BeNullOrEmpty
            "${Home}\${guid}\dir_for_local_symbiliclink\test.txt" | Should -Exist

            New-Item "D:\${guid}\local_symbiliclink\test.txt"
            Remove-Item "D:\${guid}\local_symbiliclink" -Force -Recurse
            (Get-ItemProperty "D:\${guid}\dir_for_local_symbiliclink").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "D:\${guid}\dir_for_local_symbiliclink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\dir_for_local_symbiliclink").LinkTarget | Should -BeNullOrEmpty
            "D:\${guid}\dir_for_local_symbiliclink\test.txt" | Should -Exist

            New-Item "D:\${guid}\non_local_symbiliclink\test.txt"
            Remove-item "D:\${guid}\non_local_symbiliclink" -Force -Recurse
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_symbiliclink").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_symbiliclink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\dir_for_non_local_symbiliclink").LinkTarget | Should -BeNullOrEmpty
            "${Home}\${guid}\dir_for_non_local_symbiliclink\test.txt" | Should -Exist

            New-item "${Home}\${guid}\non_local_symbiliclink\test.txt"
            Remove-item "${Home}\${guid}\non_local_symbiliclink" -Force -Recurse
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_symbiliclink").Attributes | Should -Be 'Directory'
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_symbiliclink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\dir_for_non_local_symbiliclink").LinkTarget | Should -BeNullOrEmpty
            "D:\${guid}\dir_for_non_local_symbiliclink\test.txt" | Should -Exist
        }
    }
    Context 'Test Deletion Behavior2 (delete source|target)'{
        It 'Test deletion about hardlink' {
            Remove-AllItem -guid $guid
            New-AllItem -guid $guid
            Remove-Item "${Home}\${guid}\file_for_hardlink.txt" -Force
            (Get-ItemProperty "${Home}\${guid}\hardlink").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "${Home}\${guid}\hardlink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "${Home}\${guid}\hardlink").LinkTarget | Should -BeNullOrEmpty

            Remove-Item "D:\${guid}\file_for_hardlink.txt" -Force
            (Get-ItemProperty "D:\${guid}\hardlink").Attributes | Should -Be 'Archive'
            (Get-ItemProperty "D:\${guid}\hardlink").LinkType | Should -BeNullOrEmpty
            (Get-ItemProperty "D:\${guid}\hardlink").LinkTarget | Should -BeNullOrEmpty
        }
        It 'Test deletion about junction' {
            New-Item "${Home}\${guid}\dir_for_local_junction\test.txt"
            Remove-Item "${Home}\${guid}\dir_for_local_junction" -Force -Recurse
            (Get-ItemProperty "${Home}\${guid}\local_junction").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\local_junction").LinkType | Should -Be 'Junction'
            (Get-ItemProperty "${Home}\${guid}\local_junction").LinkTarget | Should -Be "${Home}\${guid}\dir_for_local_junction"
            "${Home}\${guid}\local_junction\test.txt" | Should -Not -Exist

            New-Item "D:\${guid}\dir_for_local_junction\test.txt"
            Remove-Item "D:\${guid}\dir_for_local_junction" -Force -Recurse
            (Get-ItemProperty "D:\${guid}\local_junction").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\local_junction").LinkType | Should -Be 'Junction'
            (Get-ItemProperty "D:\${guid}\local_junction").LinkTarget | Should -Be "D:\${guid}\dir_for_local_junction"
            "D:\${guid}\local_junction\test.txt" | Should -Not -Exist

            New-Item "D:\${guid}\dir_for_non_local_junction\test.txt"
            Remove-item "D:\${guid}\dir_for_non_local_junction" -Force -Recurse
            (Get-ItemProperty "${Home}\${guid}\non_local_junction").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\non_local_junction").LinkType | Should -Be 'Junction'
            (Get-ItemProperty "${Home}\${guid}\non_local_junction").LinkTarget | Should -Be "D:\${guid}\dir_for_non_local_junction"
            "${Home}\${guid}\non_local_junction\test.txt" | Should -Not -Exist

            New-item "${Home}\${guid}\dir_for_non_local_junction\test.txt"
            Remove-item "${Home}\${guid}\dir_for_non_local_junction" -Force -Recurse
            (Get-ItemProperty "D:\${guid}\non_local_junction").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\non_local_junction").LinkType | Should -Be 'Junction'
            (Get-ItemProperty "D:\${guid}\non_local_junction").LinkTarget | Should -Be "${Home}\${guid}\dir_for_non_local_junction"
            "D:\${guid}\non_local_junction\test.txt" | Should -Not -Exist
        }
        It 'Test deletion about symbolic link file' {
            Remove-Item "${Home}\${guid}\fire_for_local_symbiliclink.txt" -Force
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink-txt").Attributes | Should -Be 'Archive, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink-txt").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink-txt").LinkTarget | Should -Be "${Home}\${guid}\fire_for_local_symbiliclink.txt"

            Remove-Item "D:\${guid}\fire_for_local_symbiliclink.txt" -Force
            (Get-ItemProperty "D:\${guid}\local_symbiliclink-txt").Attributes | Should -Be 'Archive, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\local_symbiliclink-txt").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "D:\${guid}\local_symbiliclink-txt").LinkTarget | Should -Be "D:\${guid}\fire_for_local_symbiliclink.txt"

            Remove-Item "D:\${guid}\fire_for_non_local_symbiliclink.txt" -Force
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink-txt").Attributes | Should -Be 'Archive, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink-txt").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink-txt").LinkTarget | Should -Be "D:\${guid}\fire_for_non_local_symbiliclink.txt"

            Remove-Item "${Home}\${guid}\fire_for_non_local_symbiliclink.txt" -Force
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink-txt").Attributes | Should -Be 'Archive, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink-txt").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink-txt").LinkTarget | Should -Be "${Home}\${guid}\fire_for_non_local_symbiliclink.txt"
        }
        It 'Test deletion about symbolic link dir' {
            New-Item "${Home}\${guid}\dir_for_local_symbiliclink\test.txt"
            Remove-Item "${Home}\${guid}\dir_for_local_symbiliclink" -Force -Recurse
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "${Home}\${guid}\local_symbiliclink").LinkTarget | Should -Be "${Home}\${guid}\dir_for_local_symbiliclink"
            "${Home}\${guid}\local_symbiliclink\test.txt" | Should -Not -Exist

            New-Item "D:\${guid}\dir_for_local_symbiliclink\test.txt"
            Remove-Item "D:\${guid}\dir_for_local_symbiliclink" -Force -Recurse
            (Get-ItemProperty "D:\${guid}\local_symbiliclink").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\local_symbiliclink").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "D:\${guid}\local_symbiliclink").LinkTarget | Should -Be "D:\${guid}\dir_for_local_symbiliclink"
            "D:\${guid}\local_symbiliclink\test.txt" | Should -Not -Exist

            New-Item "D:\${guid}\dir_for_non_local_symbiliclink\test.txt"
            Remove-item "D:\${guid}\dir_for_non_local_symbiliclink" -Force -Recurse
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "${Home}\${guid}\non_local_symbiliclink").LinkTarget | Should -Be "D:\${guid}\dir_for_non_local_symbiliclink"
            "${Home}\${guid}\non_local_symbiliclink\test.txt" | Should -Not -Exist

            New-item "${Home}\${guid}\dir_for_non_local_symbiliclink\test.txt"
            Remove-item "${Home}\${guid}\dir_for_non_local_symbiliclink" -Force -Recurse
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink").Attributes | Should -Be 'Directory, ReparsePoint'
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink").LinkType | Should -Be 'SymbolicLink'
            (Get-ItemProperty "D:\${guid}\non_local_symbiliclink").LinkTarget | Should -Be "${Home}\${guid}\dir_for_non_local_symbiliclink"
            "D:\${guid}\non_local_symbiliclink\test.txt" | Should -Not -Exist
        }
    }
    Context 'Test Authorization Behavior'{
        It 'Test acl sync behavior on hardlink' {
            Remove-AllItem -guid $guid
            New-AllItem -guid $guid
            Test-LinkAclBeahvior -Link "${Home}\${guid}\hardlink" -Source "${Home}\${guid}\file_for_hardlink.txt" | Should -BeTrue
            Test-LinkAclBeahvior -Link "D:\${guid}\hardlink" -Source "D:\${guid}\file_for_hardlink.txt" | Should -BeTrue
        }
        It 'Test acl sync behavior on junction' {
            Test-LinkAclBeahvior -Link "${Home}\${guid}\local_junction" -Source "${Home}\${guid}\dir_for_local_junction" | Should -BeFalse
            Test-LinkAclBeahvior -Link "D:\${guid}\local_junction" -Source "D:\${guid}\dir_for_local_junction" | Should -BeFalse
            Test-LinkAclBeahvior -Link "D:\${guid}\non_local_junction" -Source "${Home}\${guid}\dir_for_non_local_junction" | Should -BeFalse
            Test-LinkAclBeahvior -Link "${Home}\${guid}\non_local_junction" -Source "D:\${guid}\dir_for_non_local_junction" | Should -BeFalse
        }
        It 'Test acl sync behavior on symbolic link file' {
            Test-LinkAclBeahvior -Link "${Home}\${guid}\local_symbiliclink-txt" -Source "${Home}\${guid}\fire_for_local_symbiliclink.txt" | Should -BeFalse
            Test-LinkAclBeahvior -Link "D:\${guid}\local_symbiliclink-txt" -Source "D:\${guid}\fire_for_local_symbiliclink.txt" | Should -BeFalse
            Test-LinkAclBeahvior -Link "D:\${guid}\non_local_symbiliclink-txt" -Source "${Home}\${guid}\fire_for_non_local_symbiliclink.txt" | Should -BeFalse
            Test-LinkAclBeahvior -Link "${Home}\${guid}\non_local_symbiliclink-txt" -Source "D:\${guid}\fire_for_non_local_symbiliclink.txt" | Should -BeFalse
        }
        It 'Test acl sync behavior on symbolic link dir' {
            Test-LinkAclBeahvior -Link "${Home}\${guid}\local_symbiliclink" -Source "${Home}\${guid}\dir_for_local_symbiliclink" | Should -BeFalse
            Test-LinkAclBeahvior -Link "D:\${guid}\local_symbiliclink" -Source "D:\${guid}\dir_for_local_symbiliclink" | Should -BeFalse
            Test-LinkAclBeahvior -Link "D:\${guid}\non_local_symbiliclink" -Source "${Home}\${guid}\dir_for_non_local_symbiliclink" | Should -BeFalse
            Test-LinkAclBeahvior -Link "${Home}\${guid}\non_local_symbiliclink" -Source "D:\${guid}\dir_for_non_local_symbiliclink" | Should -BeFalse
        }
    }
}

AfterAll {
    Remove-AllItem -guid $guid
}