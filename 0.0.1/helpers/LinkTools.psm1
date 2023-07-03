
function local:Set-SymbolicLink{
    param(
        [string]$Path,
        [string]$Target
    )
    try{
        # 借助于符号链接的特性, `Remove-Item 符号链接点 -Recurse` 不会顺着链接删除原文件
        Remove-Item $Path -Recurse -ErrorAction Stop 
    }
    catch
    {
        Write-Output $PSItem
        Write-Output "Going on."
    }
    try
    {
        if (Test-Path -Path $Target){
            $link = New-Item -ItemType SymbolicLink -Path $Path -Target $Target -ErrorAction Stop 
            $link | Select-Object LinkType, FullName, Target
        }
        else{
            throw "`$Target $Target should exist!"
        }
        
    }
    catch [System.IO.IOException]
    {
        # refer to 
        # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-error?view=powershell-7.2
        # https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-exceptions?view=powershell-7.2
        # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally?view=powershell-7.2
        Write-Output "System.IO.IOException: $PSItem"
    }
    catch
    {
        Write-Output "Unknown Exception: $PSItem"
    }
}

function local:Set-Junction{
    param(
        [string]$Path,
        [string]$Target
    )
    try
    {
        $link = New-Item `
            -ItemType Junction `
            -Path $Path `
            -Target $Target `
            -ErrorAction Stop 
        $link | Select-Object LinkType, FullName, Target
    }
    catch [System.IO.IOException]
    {
        Write-Output "System.IO.IOException: $PSItem"
    }
    catch
    {
        Write-Output "Unknown Exception: $PSItem"
    }
}
function local:Test-ReparsePoint{
    param(
        [string]$Path
    ) 
    # refer to https://cloud.tencent.com/developer/ask/sof/112542
    $File = Get-Item $Path -Force -ea SilentlyContinue
    return [bool]($File.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function local:Set-SymbolicLinkSync{
    <#
    .Description
    Make a SymbolicLink from $Source to $Destination
    This function will try to merge $Source and $Destination first, then make a `Link` from $Source as $Destination.
        If $Destination is not existed, just make `Link` from $Source.
        If $Destination is existed but not a `Link`, cut $Destination and cover $Source, then make `Link` from $Source.
        If $Destination is existed and is a `Link`, del the `Link` and re-make a new `Link` from $Source.
    This func may have some redundant and repetitive logic with func `Set-SymbolicLink`.
    #>
    param(
        [string]$Destination,
        [string]$Source
    )
    try
    {
        if (!(Test-Path -Path $Destination)){
            if (!(Test-Path -Path $Source)){
                throw "At least one of `$Destination or `$Source should exists!"
            }
            else{
                if (Test-ReparsePoint -Path $Source){
                    throw "`$Source should not be `ReparsePoint`!"
                }
                else{
                    Set-SymbolicLink -Path $Destination -Target $Source
                }
            }
        }
        else{
            if (!(Test-Path -Path $Source)){
                if (Test-ReparsePoint -Path $Destination){
                    throw "`$Destination should not be `ReparsePoint`!"
                }
                else{
                    Copy-Item -Path $Destination -Destination $Source -Recurse -Force -Container
                    Remove-Item $Destination -Recurse -Force
                    Set-SymbolicLink -Path $Destination -Target $Source
                }
            }
            else{
                if (Test-ReparsePoint -Path $Source){
                    throw "`$Source should not be `ReparsePoint`!"
                }
                if (Test-ReparsePoint -Path $Destination){
                    Remove-Item $Destination -Recurse -Force
                    Set-SymbolicLink -Path $Destination -Target $Source
                }
                else{
                    Copy-Item -Path $Destination\* -Destination $Source -Recurse -Force -Container
                    Remove-Item $Destination -Recurse -Force
                    Set-SymbolicLink -Path $Destination -Target $Source
                }
            }
        }
    }
    catch
    {
        Write-Output "Exception: $PSItem"
        Write-Output "Operation has been skipped on $Source."
    }
}


function local:Set-JunctionSync{
    <#
    .Description
    Same to Set-SymbolicLinkSync
    #>
    param(
        [string]$Destination,
        [string]$Source
    )
    try
    {
        if (!(Test-Path -Path $Destination)){
            if (!(Test-Path -Path $Source)){
                throw "At least one of `$Destination or `$Source should exists!"
            }
            else{
                if (Test-ReparsePoint -Path $Source){
                    throw "`$Source should not be `ReparsePoint`!"
                }
                else{
                    Set-Junction -Path $Destination -Target $Source
                }
            }
        }
        else{
            if (!(Test-Path -Path $Source)){
                if (Test-ReparsePoint -Path $Destination){
                    throw "`$Destination should not be `ReparsePoint`!"
                }
                else{
                    Copy-Item -Path $Destination -Destination $Source -Recurse -Force -Container
                    Remove-Item $Destination -Recurse -Force
                    Set-Junction -Path $Destination -Target $Source
                }
            }
            else{
                if (Test-ReparsePoint -Path $Source){
                    throw "`$Source should not be `ReparsePoint`!"
                }
                if (Test-ReparsePoint -Path $Destination){
                    Remove-Item $Destination -Recurse -Force
                    Set-Junction -Path $Destination -Target $Source
                }
                else{
                    Copy-Item -Path $Destination\* -Destination $Source -Recurse -Force -Container
                    Remove-Item $Destination -Recurse -Force
                    Set-Junction -Path $Destination -Target $Source
                }
            }
        }
    }
    catch
    {
        Write-Output "Exception: $PSItem"
        Write-Output "Operation has been skipped on $Source."
    }
}

