function Get-PreReleaseString{
<#
.DESCRIPTION
    Get the pre-release string from a release note file.
.PARAMETER ReleaseNotesPath
    The release note file path.
.INPUTS
    String.
.OUTPUTS
    String.
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
.INPUTS
    String.
    String.
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

function Format-VersionTo4SegmentFormat{
<#
.DESCRIPTION
    Format a version string like `vX.X.X...` to a fixed format that consists of 4 segments.
    If there are more than 4 segments, the extra segments will be truncated (the leftmost 4 segments will be retained while others will be droped).
    If there are less than 4 segments, the missing segments will be appended with `0`.
.PARAMETER RawVersion
    The raw version string.
.INPUTS
    String.
.OUTPUTS
    System.Version.
#>
    [OutputType([System.Version])]
    param (
        [Parameter(Mandatory)]
        [string]$RawVersion
    )
    if ($RawVersion -match "v(\d+(\.\d+)*)"){
        $version = $Matches[1]
        $version_segments = $version -split '\.'
        while ($version_segments.Count -lt 4) {
            $version_segments += "0"
        }
        $normalized_version = $version_segments[0..3] -join "."
        return [system.version]::new($normalized_version)
    }
    else{
        throw "Invalid version number: $RawVersion. It should be in the format like vX, vX.X, vX.X.X, vX.X.X.X...."
    }
}