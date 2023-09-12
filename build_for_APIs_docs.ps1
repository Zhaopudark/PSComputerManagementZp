$ErrorActionPreference = 'Stop'
Remove-Module PSComputerManagementZp -Force -ErrorAction SilentlyContinue
Remove-Module platyPS -Force -ErrorAction SilentlyContinue
Install-Module platyPS

Import-Module "${PSScriptRoot}\Module\PSComputerManagementZp.psm1" -Force

New-MarkdownHelp -Module PSComputerManagementZp -OutputFolder "${PSScriptRoot}\Docs\APIs" -Force

foreach ($item in Get-Item "${PSScriptRoot}\Docs\APIs\*.md"){
    $fileContent = Get-Content -Path $item -Raw
    $fileContent = $fileContent -replace '\\`', '`'
    $fileContent = $fileContent -replace '\\\[', '['
    $fileContent = $fileContent -replace '\\\]', ']'
    $fileContent = $fileContent -replace '\[\[', '['
    $fileContent = $fileContent -replace '\]\(\)', ''
    Set-Content -Path $item -Value $fileContent
}

Remove-Module PSComputerManagementZp -Force -ErrorAction SilentlyContinue
Remove-Module platyPS -Force -ErrorAction SilentlyContinue