$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -eq "main") {
    $version = . "${PSScriptRoot}/check_release_version.ps1"
    $tagName = "v${version}"
    # 检测标签是否存在
    if (git show-ref "refs/tags/$tagName") {
        Write-Error "Tag '$tagName' already exists."
    } else {
        # 标签不存在
        Write-Output "Tag '$tagName' does not exist."
        Write-Output "Creating tag '$tagName'."
        git tag -a $tagName -m "Release $tagName"
    }

    # 检测远程标签是否存在
    if (git ls-remote --tags origin | Where-Object { $_ -match "refs/tags/$tagName" }) {
        Write-Error "Remote tag '$tagName' already exists."
    } else {
        # 远程标签不存在
        Write-Output "Remote tag '$tagName' does not exist."
        Write-Output "Pushing tag '$tagName' to remote."
        git push origin $tagName
    }
} else {
    Write-Host "Not on main branch. Current branch: $currentBranch"
}