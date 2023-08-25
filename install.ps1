foreach ($item in (Get-ChildItem "${PSScriptRoot}\Module" -Filter *.psm1)){
    Import-Module $item.FullName -Force -Scope Local
}

$ModuleInfo = Get-ModuleInfo

if (!(Test-Path -LiteralPath $ModuleInfo.InstallPath)){
    New-Item -Path $ModuleInfo.InstallPath -ItemType Directory
}
if (Test-Path -LiteralPath "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)"){
    $content = Get-ChildItem "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)" -Exclude $ModuleInfo.LogDir
    Remove-Item $content -Force -Recurse
}else{
    New-Item -Path "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)" -ItemType Directory
    New-Item -Path "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)\$($ModuleInfo.LogDir)" -ItemType Directory
}

foreach ($item in (Get-ChildItem $ModuleInfo.InstallPath -Exclude $ModuleInfo.ModuleVersion)){
    if (Test-Path -LiteralPath "$($item.FullName)\$($ModuleInfo.LogDir)"){
        Copy-Item -Path "$($item.FullName)\$($ModuleInfo.LogDir)\*" -Destination "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)\$($ModuleInfo.LogDir)" -Recurse -Force
    }
    Remove-Item $item.FullName -Force -Recurse
}

Copy-Item -Path "${PSScriptRoot}\Module\*" -Destination "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)" -Recurse -Force

New-ModuleManifest -Path "$($ModuleInfo.InstallPath)\$($ModuleInfo.ModuleVersion)\$($ModuleInfo.ModuleName).psd1" `
    -ModuleVersion $ModuleInfo.ModuleVersion `
    -RootModule $ModuleInfo.RootModule `
    -Author $ModuleInfo.Author`
    -PowerShellVersion $ModuleInfo.PowerShellVersion`
    -FunctionsToExport $ModuleInfo.FunctionsToExport`
    -CmdletsToExport @()`
    -VariablesToExport @()`
    -AliasesToExport @()
