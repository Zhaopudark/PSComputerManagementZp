param (
    [Parameter(Mandatory)]
    [string]$message
)

$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -eq "dev") {
    # 如果当前分支是 dev 分支，则进行 commit 操作
    . "${PSScriptRoot}/build.ps1"
    git add .  # 添加需要提交的文件（假设你要提交所有文件）
    git commit -m $message
    git push
} else {
    Write-Host "Not on main branch. Current branch: $currentBranch"
}