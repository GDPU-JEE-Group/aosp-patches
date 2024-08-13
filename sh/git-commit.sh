#!/bin/bash

# 默认值
default_dev_branch="dev-20240815"
default_push_branch="ft/20240829/CLOUDPHONE-3198-input-hijacking"
default_patch_path="a_patches/snow/0009-Update-qq-browser-kernel2.patch"
default_commit_msg="ft(输入法):输入法劫持"

run_cmd() {
    echo -e "\033[0;32mExecuting: $*\033[0m"
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "\033[0;31mError: Command failed with status $status\033[0m"
        while true; do
            read -p "你是否已经解决了问题并准备好继续执行? (yes/no): " choice
            case "$choice" in
                yes)
                    return 0
                    ;;
                no)
                    echo "操作已取消。"
                    exit $status
                    ;;
                *)
                    echo "请输入 'yes' 或 'no'。"
                    ;;
            esac
        done
    fi
}

# 临时关闭 Bracketed Paste Mode
echo -e '\e[?2004l'

# 请求用户输入各项参数，并提供默认值
read -p "请输入开发分支名称（dev_branch） [默认: $default_dev_branch]: " dev_branch
dev_branch=${dev_branch:-$default_dev_branch}

read -p "请输入本地分支名称（push_branch） [默认: $default_push_branch]: " push_branch
push_branch=${push_branch:-$default_push_branch}

read -p "请输入补丁文件路径（patch_path） [默认: $default_patch_path]: " patch_path
patch_path=${patch_path:-$default_patch_path}

read -p "请输入提交信息（commit_msg） [默认: $default_commit_msg]: " commit_msg
commit_msg=${commit_msg:-$default_commit_msg}

# 重新启用 Bracketed Paste Mode
echo -e '\e[?2004h'

# 确认操作
echo "你真的要清除所有内容并拉取全新的分支吗? 输入 'yes' 确认: "
read confirmation

if [ "$confirmation" != "yes" ]; then
  echo "操作已取消。"
  exit 0
fi

# 开始执行操作
echo "开始执行操作..."

# 清理并重置本地分支
run_cmd git reset --hard origin/$dev_branch

# 应用补丁并直接添加到暂存区
run_cmd git apply --index $patch_path

# 提交变更
run_cmd git commit -m "$commit_msg"

# 检查远程分支是否存在
if git ls-remote --exit-code --heads origin $push_branch; then
    # 强制推送到远程分支
    run_cmd git push origin $push_branch --force
else
    # 普通推送到远程分支
    run_cmd git push origin $push_branch
fi

echo "操作完成。"
