BeforeAll {
    class FormattedxPath {
    
        [ValidateNotNullOrEmpty()][string] $BasePath
        [ValidateNotNullOrEmpty()][string] $OriginalPlatform 
        [ValidateNotNullOrEmpty()][bool] $IsContainer = $false
        [ValidateNotNullOrEmpty()][bool] $IsFile = $false
        [ValidateNotNullOrEmpty()][bool] $IsInSystemDrive = $false
        [ValidateNotNullOrEmpty()][bool] $IsInInHome = $false
        [ValidateNotNullOrEmpty()][bool] $IsDesktopINI = $false
        [ValidateNotNullOrEmpty()][bool] $IsSystemVolumeInfo = $false
        [ValidateNotNullOrEmpty()][bool] $IsRecycleBin = $false
    
        FormattedxPath([string] $Path) {
            
            if ([System.Environment]::OSVersion.Platform -eq "Win32NT"){
                $this.OriginalPlatform = "Win32NT"
            }elseif ([System.Environment]::OSVersion.Platform -eq "Unix") {
                $this.OriginalPlatform = "Unix"
            }else{
                throw "Only Win32NT and Unix are supported, not $($global:PSVersionTable.Platform)."
            }
    
            if(Test-Path -LiteralPath $Path){
                $this.BasePath = $this.FormatLiteralPath($Path)
            }
            else{
                throw "Path does not exist: $Path"
            }
            if (Test-Path -LiteralPath $this.BasePath -PathType Container){
                $this.IsContainer = $true
                $this.IsFile = $false
            }
            else {
                $this.IsContainer = $false
                $this.IsFile = $true
            }
    
    
            $home_path = $this.FormatLiteralPath([System.Environment]::GetFolderPath("UserProfile"))
    
            if (($this.GetQualifier($this.BasePath)).Name -eq ($this.GetQualifier($home_path)).Name){
                $this.IsInSystemDrive = $true
            }
            else {
                $this.IsInSystemDrive = $false
            }
            if ($this.BasePath.StartsWith($home_path)){
                $this.IsInInHome = $true
            }else{
                $this.IsInInHome = $false
            }
    
            
            if ($this.OriginalPlatform -eq "Win32NT"){
                if ($this.IsFile -and ((Split-Path $this.BasePath -Leaf) -eq "desktop.ini")){
                    $this.IsDesktopINI = $true
                }
                else {
                    $this.IsDesktopINI = $false
                }
                if ($this.BasePath -eq $this.FormatLiteralPath("$($this.GetQualifier($this.BasePath).Root)System Volume Information")){
                    $this.IsSystemVolumeInfo = $true
                }
                else {
                    $this.IsSystemVolumeInfo = $false
                }
        
                if ($this.BasePath -eq $this.FormatLiteralPath("$($this.GetQualifier($this.BasePath).Root)`$RECYCLE.BIN")){
                    $this.IsSystemVolumeInfo = $true
                }
                else {
                    $this.IsSystemVolumeInfo = $false
                }
            }  
            
        }
    
        [string] FormatLiteralPath([string] $Path){
            
            if ($Path -match ":$") {
                if ($this.OriginalPlatform -eq "Win32NT"){
                    $Path = $Path + "\"
                }else{
                    $Path = $Path + "/"
                }
            }
            $resolvedPath = Resolve-Path -LiteralPath $Path
            $item = Get-ItemProperty -LiteralPath $resolvedPath
            if (Test-Path -LiteralPath $item -PathType Container){
                $output += (join-Path $item '')
            }
            else{
                $output += $item.FullName
            }
            return $output
        }
        [System.Management.Automation.PSDriveInfo] GetQualifier([string]$LiteralPath){
            return (Get-ItemProperty -LiteralPath $LiteralPath -ErrorAction Stop).PSDrive
        }
        [string] GetDriveWithFirstDir(){
    
            $splited_paths = $this.BasePath -split '\\'
            if ($splited_paths.Count -gt 1) { $max_index = 1 } else { $max_index = 0 }
            return $this.FormatLiteralPath($splited_paths[0..$max_index] -join '\\')
        }
        [string] ToString() { # like __repr__ in python
            return $this.BasePath
        }
    
    }

    Import-Module PSComputerManagementZp -Force 
    $user_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','User')
    $machine_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','Machine')
    $process_env_paths_backup = [Environment]::GetEnvironmentVariable('PATH','Process')

    $guid = [guid]::NewGuid()
    $test_path = "${Home}\$guid"
    New-Item -Path $test_path -ItemType Directory -Force


    # $test_path = Format-LiteralPath $test_path
    $test_path = [FormattedxPath]::new($test_path)

}

Describe 'Test EnvTools' {
    Context 'Symplify non-process level Env:PATH' {
        It 'Test Merge-RedundantEnvPathFromLocalMachineToCurrentUser' -Skip:(!$IsWindows){
            Merge-RedundantEnvPathFromLocalMachineToCurrentUser
            $user_env_paths = Get-EnvPathAsSplit -Level 'User'
            $user_env_paths += $test_path
            $machine_env_paths = Get-EnvPathAsSplit -Level 'Machine'
            $machine_env_paths += $test_path
            Set-EnvPathBySplit -Level 'User' -Path $user_env_paths
            Set-EnvPathBySplit -Level 'Machine' -Path $machine_env_paths
            Merge-RedundantEnvPathFromLocalMachineToCurrentUser
            $user_env_paths2 = Get-EnvPathAsSplit -Level 'User'
            $machine_env_paths2 = Get-EnvPathAsSplit -Level 'Machine'

            $user_env_paths2 | Should -Contain $test_path
            $user_env_paths2.count | Should -Be $user_env_paths.count
            $machine_env_paths2 | Should -Not -Contain $test_path
            $machine_env_paths2.count | Should -Be ($machine_env_paths.count-1)
        }
    }
    Context 'Add items into process level Env:PATH' {
        It 'Test Add-EnvPathToCurrentProcess' {
            $process_env_paths1 = Get-EnvPathAsSplit -Level 'Process'
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths2 = Get-EnvPathAsSplit -Level 'Process'

            $process_env_paths1 | Should -Not -Contain $test_path
            $process_env_paths2 | Should -Contain $test_path
        }

    }
    Context 'Remove items from process level Env:PATH' {
        It 'Test Remove-EnvPathByPattern'{
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths1 = Get-EnvPathAsSplit -Level 'Process'
            Remove-EnvPathByPattern -Pattern $guid -Level 'Process'
            $process_env_paths2 = Get-EnvPathAsSplit -Level 'Process'

            $process_env_paths1 | Should -Contain $test_path
            $process_env_paths2 | Should -Not -Contain $test_path

        }
        It 'Test Remove-EnvPathByTargetPath'{
            Add-EnvPathToCurrentProcess -Path $test_path
            $process_env_paths1 = Get-EnvPathAsSplit -Level 'Process'
            Remove-EnvPathByTargetPath -TargetPath $test_path -Level 'Process'
            $process_env_paths2 = Get-EnvPathAsSplit -Level 'Process'

            $process_env_paths1 | Should -Contain $test_path
            $process_env_paths2 | Should -Not -Contain $test_path
        }
    }

}

AfterAll {
    Remove-Item $test_path -Force -Recurse
    Remove-Module PSComputerManagementZp -Force

    [Environment]::SetEnvironmentVariable('PATH',$user_env_paths_backup ,'User')
    [Environment]::SetEnvironmentVariable('PATH',$machine_env_paths_backup,'Machine')
    [Environment]::SetEnvironmentVariable('PATH',$process_env_paths_backup,'Process')
}