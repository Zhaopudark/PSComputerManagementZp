# 检查是否存在 dev 分支
$branchExists = git branch --list dev

if ($branchExists) {
    # 如果分支存在，则切换到 dev 分支
    git switch dev
} else {
    # 如果分支不存在，则创建一个新的 dev 分支并切换到该分支
    git switch -c dev
}
