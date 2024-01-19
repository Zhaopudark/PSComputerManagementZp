param (
    [Parameter(Mandatory)]
    [string]$message
)

$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -eq "main") {
    git branch -D dev
    git switch -c dev

    # 如果当前分支是 dev 分支，则进行 commit 操作
    . "${PSScriptRoot}/build.ps1"
    git add .  # 添加需要提交的文件（假设你要提交所有文件）
    git commit -m $message
    git push origin dev:dev
    # 如果当前分支是 dev 分支，则进行 commit 操作
    # . "${PSScriptRoot}/check_release_version.ps1"
    

    # if (git branch --list dev) {
    #     # 如果分支存在，则切换到 dev 分支
    #     git switch dev
    # } else {
    #     # 如果分支不存在，则创建一个新的 dev 分支并切换到该分支
    #     git switch -c dev
    # }
    
    # # 获取当前所在的分支
    # 
} else {
    Write-Host "Not on main branch. Current branch: $currentBranch"
}