function Get-FunctionDocs{
<#
.DESCRIPTION
    Get function docs from a script file.
.INPUTS
    A script file path.
.OUTPUTS
    A hashtable with function names as keys and function docs as values.
#>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    if (-not (Test-Path -Path $Path -PathType Leaf)){
        throw "Path '$Path' does not exist or is not a file."
    }
    if (-not ($Path.EndsWith('.ps1') -or $Path.EndsWith('.psm1'))){
        throw "Path '$Path' is not a PowerShell script file."
    }
    $script_content = Get-Content -Path $Path -Raw
    $function_bloks =  $script_content | Select-String -Pattern '(?sm)^\s*function .*?^\}' -AllMatches
    $function_name_with_docs = @{}
    foreach ($match in $function_bloks.Matches) {
        $block = $match.Value
        $function_name = ($block | Select-String -Pattern 'function\s+([A-Za-z0-9_\-]+)').Matches.Groups[1].Value
        $comment_matched = $block | Select-String -Pattern '(?s)<#(.*?)#>'
        if ($comment_matched.Count -ne 0){
            $function_comment = $comment_matched.Matches.Groups[1].Value
        }
        $function_name_with_docs[$function_name] = $function_comment
    }
    return $function_name_with_docs
}

function Format-Doc2Markdown{
<#
.DESCRIPTION
    Convert a function doc to markdown string with a fixed format.
.NOTES
    The formatting rule is as:
    ```powershell
    .SYNOPSIS
        xxx
    .DESCRIPTION
        xxx
    .PARAMETER Aa
        xxx
    .PARAMETER Bb
        xxx
    ```
    to
    ```markdown
    - Synopsis
        
        xxx
    - Description
        
        xxx
    - Parameters `Aa`

        xxx
    - Parameters `Bb`

        xxx
    ```
.INPUTS
    A powershell doc string.
.OUTPUTS
    A formatted string that can be used in markdown directly.
#>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$DocString
    )
    if ($DocString){
        $comment_lines = $DocString -split '\r?\n'
        $block = @()
        foreach ($line in $comment_lines) {
            $line = $line.TrimStart()
            if ($line -match '^(\.)(\w+)[ ]*(\w*)') {
                # Function-Name -> ### Function-Name
                # .DESCRIPTION ->  - Description
                # .PARAMETER xxx -> - Parameter `xxx`
                $title = '- **'+$Matches[2].Substring(0,1).ToUpper() + $Matches[2].Substring(1).ToLower()+'**'
                if ($Matches[3]) {
                    $title += " ``$($Matches[3])``"
                }
                $block += $title
                $block += ''
            } else {
                $block += ' '*4+$line
            }
        }
        $function_comment = $block -join "`r`n"
    }
    return $function_comment
}

function Get-PreReleaseString{
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$ReleaseNotesPath
    )
    $release_title = Get-Content $ReleaseNotesPath | Select-String -Pattern "^## " | Select-Object -First 1
    if ($release_title -match 'v([\d]+\.[\d]+\.[\d]+)[\-]*(.*)'){
        $pre_release_string = $Matches[2]
        if ($pre_release_string -match 'beta[\d+]|stable'){
            $result = $pre_release_string.ToLower()
            if ($result -eq 'stable'){
                return '' # stable version should not have pre-release string
            }
            else{
                return $result
            }
        }
        else{
            throw "[Invalid pre-release string] The pre-release string in $ReleaseNotesPath is $pre_release_string, but it should one be 'stable' or 'beta0', 'beta1' etc."
        }
    }else{
        return ''
    }
}

function Assert-ReleaseVersionConsistency{
    param(
        [Parameter(Mandatory)]
        [string]$ModuleVersion,
        [Parameter(Mandatory)]
        [string]$ReleaseNotesPath
    )

    $release_title = Get-Content $ReleaseNotesPath | Select-String -Pattern "^# " | Select-Object -First 1
    if ($release_title -match 'v([\d]+\.[\d]+\.[\d]+)'){
        $version = $Matches[1]
        if (!($version -ceq $ModuleInfo.ModuleVersion)){
            throw "[Imcompatible version] The newest version in $ReleaseNotesPath is $version, but it should be $ModuleVersion."
        }
    }else{
        throw "[Invalid release title] The release title in $ReleaseNotesPath is $release_title, but it should be like '# xxx v0.0.1'."
    }
}

