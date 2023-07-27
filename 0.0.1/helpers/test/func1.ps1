
Import-Module ./func2.ps1
function script:Format-Path{
    param ()
    Write-Host "Format-Path func1"
}
Format-Path 
script:Format-Path 
global:Format-Path
