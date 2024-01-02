function Get-TempPath{
    [OutputType([string])]
    param ()
    try {
        if (Test-Platform 'Windows'){   
            if (!$Env:TEMP -or !$Env:TMP){
                throw "Get the temp path faild, on Windows, the environment variable TEMP or TMP should both exist."
            }
            if ($Env:TEMP -ne $Env:TMP){
                throw "Get the temp path faild, on Windows, the environment variable TEMP or TMP should be the same."
            }
            return [FormattedFileSystemPath]::new($Env:TEMP)
        }elseif (Test-Platform 'Wsl2'){
            return [FormattedFileSystemPath]::new("/tmp")
        }elseif (Test-Platform 'Linux'){
            return [FormattedFileSystemPath]::new("/tmp")
        }elseif (Test-Platform 'MacOS'){
            $temp_path = [FormattedFileSystemPath]::new("/tmp")
            Write-Warning "$($temp_path -eq $null)" -Verbose
            return [FormattedFileSystemPath]::new("/tmp")
        }else{
            throw "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        }
       
    }
    catch {
        Write-Log $_.Exception.Message -ShowVerbose
        exit -1
    }
}
function Get-SelfBuildDir{
<#
.LINK
    [PSModulePath](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-7.3)
#>
    [OutputType([string])]
    param()
    return [FormattedFileSystemPath]::new($(Get-TempPath))
}
function Get-SelfInstallDir{
<#
.LINK
    [PSModulePath](https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-7.3)
#>
    [OutputType([string])]
    param()
    try {
        $windows_path = "$(Split-Path -Path $PROFILE.CurrentUserAllHosts -Parent)\Modules\"
        $non_windows_path = "${Home}/.local/share/powershell/Modules"
        if (Test-Platform 'Windows'){
            if (!(Test-Path -LiteralPath $windows_path)){
                New-Item -Path $windows_path -ItemType Directory -Force | Out-Null
            }
            return [FormattedFileSystemPath]::new($windows_path)
        }elseif (Test-Platform 'Wsl2'){
            if (!(Test-Path -LiteralPath $non_windows_path)){
                New-Item -Path $non_windows_path -ItemType Directory -Force | Out-Null
            }
            return [FormattedFileSystemPath]::new($non_windows_path)
        }elseif (Test-Platform 'Linux'){
            if (!(Test-Path -LiteralPath $non_windows_path )){
                New-Item -Path $non_windows_path -ItemType Directory -Force | Out-Null
            }
            return [FormattedFileSystemPath]::new($non_windows_path)
        }elseif (Test-Platform 'MacOS'){
            if (!(Test-Path -LiteralPath $non_windows_path )){
                New-Item -Path $non_windows_path -ItemType Directory -Force | Out-Null
            }
            return [FormattedFileSystemPath]::new($non_windows_path)
        }else{
            throw "The current platform, $($PSVersionTable.Platform), has not been supported yet."
        }
    }
    catch {
        Write-Log $_.Exception.Message -ShowVerbose
        exit -1
    }
}