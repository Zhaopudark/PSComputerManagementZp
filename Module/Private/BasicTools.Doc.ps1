function Get-FunctionDoc{
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
        else{
            $function_comment = ''
        }
        $function_name_with_docs[$function_name] = $function_comment
    }
    return $function_name_with_docs
}

function Get-ClassDoc{
<#
.DESCRIPTION
    Get class docs from a script file.
.INPUTS
    A script file path.
.OUTPUTS
    A hashtable with class names as keys and class docs as values.
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
    $class_bloks =  $script_content | Select-String -Pattern '(?sm)^\s*class .*?^\}' -AllMatches
    $class_name_with_docs = @{}
    foreach ($match in $class_bloks.Matches) {
        $block = $match.Value
        $class_name = ($block | Select-String -Pattern 'class\s+([A-Za-z0-9_]+)').Matches.Groups[1].Value
        $comment_matched = $block | Select-String -Pattern '(?s)<#(.*?)#>'
        if ($comment_matched.Count -ne 0){
            $class_comment = $comment_matched.Matches.Groups[1].Value
        }
        else{
            $class_comment = ''
        }
        $class_name_with_docs[$class_name] = $class_comment
    }
    return $class_name_with_docs
}
function Format-Doc2Markdown{
<#
.DESCRIPTION
    Convert a function doc to markdown string with a fixed format.
.NOTES
    The formatted markdown string is like this:
    ```markdown
    - Synopsis

        xxx
    - Description

        xxx
    - Parameters `$Aa`

        xxx
    - Parameters `$Bb`

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
    $function_comment = $null
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
                    $title += " ```$$($Matches[3])``"
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


function Get-SortedNameWithDocFromScript{
<#
.DESCRIPTION
    Get sorted function names with docs from a script file or script files.
.INPUTS
    A script file path or script files path, and the type of docs.
.PARAMETER Path
    The path of a script file or script files.
.PARAMETER DocType
    The type of docs, 'Function' or 'Class'.
.OUTPUTS
    A hashtable enumerator with sorted function names as keys(names) and function docs as values.
#>
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [ValidateSet('Function','Class')]
        [string]$DocType

    )
    $source = Get-Item -Path $Path -Include '*.ps1','*.psm1'| ForEach-Object { $_.FullName }
    $name_with_docs = @{}
    foreach ($item in $source) {
        if ($DocType -eq 'Function'){
            $name_with_docs += Get-FunctionDoc -Path $item
        }else{
            $name_with_docs += Get-ClassDoc -Path $item
        }
    }
    $sorted_name_with_docs = $name_with_docs.GetEnumerator() | Sort-Object -Property Name
    return $sorted_name_with_docs
} 
    
    