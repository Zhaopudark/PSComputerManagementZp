foreach ($item in (Get-ChildItem "${PSScriptRoot}\Module" -Filter *.psm1)){
    Import-Module $item.FullName -Force -Scope Local
}

$ModuleInfo = Get-ModuleInfo

if (Test-Platform 'Windows'){
    $ModuleInfo.InstallPath = "$(Split-Path -Path $PROFILE -Parent)\Modules\$($ModuleInfo.ModuleName)"
    $maybe_c = (Get-ItemProperty ${Home}).PSDrive.Name
    $ModuleInfo.BuildPath = "$maybe_c`:\temp\$($ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Wsl2'){
    $ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($ModuleInfo.ModuleName)"
    $ModuleInfo.BuildPath = "/tmp/$($ModuleInfo.ModuleName)"
}elseif (Test-Platform 'Linux'){
    $ModuleInfo.InstallPath = "${Home}/.local/share/powershell/Modules/$($ModuleInfo.ModuleName)"
    $ModuleInfo.BuildPath = "/tmp/$($ModuleInfo.ModuleName)"
}else{
    Write-Error "The current platform, $($PSVersionTable.Platform), has not been supported yet."
    exit -1
}

if (!(Test-Path -LiteralPath $ModuleInfo.BuildPath)){
    New-Item -Path $ModuleInfo.BuildPath -ItemType Directory
}
if (Test-Path -LiteralPath "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)"){
    Remove-Item "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)" -Force -Recurse
}
New-Item -Path "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)" -ItemType Directory

Copy-Item -Path "${PSScriptRoot}\Module\*" -Destination "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)" -Recurse -Force

New-ModuleManifest -Path "$($ModuleInfo.BuildPath)\$($ModuleInfo.ModuleVersion)\$($ModuleInfo.ModuleName).psd1" `
    -ModuleVersion $ModuleInfo.ModuleVersion `
    -RootModule $ModuleInfo.RootModule `
    -Author $ModuleInfo.Author`
    -Description $ModuleInfo.Description`
    -PowerShellVersion $ModuleInfo.PowerShellVersion`
    -FunctionsToExport $ModuleInfo.FunctionsToExport`
    -CmdletsToExport @()`
    -VariablesToExport @()`
    -AliasesToExport @()`
    -LicenseUri $ModuleInfo.LicenseUri`
    -ProjectUri $ModuleInfo.ProjectUri`
    -IconUri $ModuleInfo.IconUri`
    -ReleaseNotes = $ModuleInfo.ReleaseNotes`
    -HelpInfoURI $ModuleInfo.HelpInfoURI