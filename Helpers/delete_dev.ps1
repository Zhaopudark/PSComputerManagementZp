git switch main 

# 检查是否存在 dev 分支
$branchExists = git branch --list dev

if ($branchExists) {
    # 如果dev存在 删除dev
    git branch -D dev
}
git pull origin main:main 