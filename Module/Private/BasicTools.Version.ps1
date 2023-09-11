function Get-PreReleaseString{
<#
.DESCRIPTION
    Get the pre-release string from a release note file.
.INPUTS
    A release note file path.
.OUTPUTS
    A string of the pre-release string.
#>
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
<#
.DESCRIPTION
    Assert if the release version in the release note file is consistent with the given version.
.PARAMETER Version
    The version.
.PARAMETER ReleaseNotesPath
    The release note file path.
.OUTPUTS
    None.
#>
    param(
        [Parameter(Mandatory)]
        [string]$Version,
        [Parameter(Mandatory)]
        [string]$ReleaseNotesPath
    )

    $release_title = Get-Content $ReleaseNotesPath | Select-String -Pattern "^# " | Select-Object -First 1
    if ($release_title -match 'v([\d]+\.[\d]+\.[\d]+)'){
        $release_version = $Matches[1]
        if (!($release_version -ceq $Version)){
            throw "[Imcompatible version] The newest version in $ReleaseNotesPath is $release_version, but it should be $Version."
        }
    }else{
        throw "[Invalid release title] The release title in $ReleaseNotesPath is $release_title, but it should be like '# xxx v0.0.1'."
    }
}