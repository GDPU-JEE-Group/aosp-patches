#!/bin/bash

run_cmd() {
    echo -e "\033[0;32mExecuting: $*\033[0m"
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "\033[0;31mError: Command failed with status $status\033[0m"
        exit $status
    fi
}

# 临时关闭 Bracketed Paste Mode
echo -e '\e[?2004l'

# 请求用户输入各项参数
read -p "请输入开发分支名称（dev_branch）: " dev_branch
read -p "请输入本地分支名称（push_branch）: " push_branch
read -p "请输入补丁文件路径（patch_path）: " patch_path
read -p "请输入提交信息（commit_msg）: " commit_msg

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
if [ $? -ne 0 ]; then
  echo "重置分支失败，请检查分支名称是否正确。"
  exit 1
fi

# 应用补丁并直接添加到暂存区
run_cmd git apply --index $patch_path
if [ $? -ne 0 ]; then
  echo "应用补丁时发生冲突。请手动解决冲突后继续操作。"
  
  # 提示用户处理冲突
  echo "是否已经解决冲突？(yes/no)"
  read conflict_resolved
  
  if [ "$conflict_resolved" != "yes" ]; then
    echo "请先解决冲突，然后再次运行脚本。"
    exit 1
  fi
fi

# 提交变更
run_cmd git commit -m "$commit_msg"
if [ $? -ne 0 ]; then
  echo "提交变更失败，请检查。"
  exit 1
fi

# 检查远程分支是否存在
if git ls-remote --exit-code --heads origin $push_branch; then
    # 强制推送到远程分支
    run_cmd git push origin $push_branch --force
else
    # 普通推送到远程分支
    run_cmd git push origin $push_branch
fi

if [ $? -ne 0 ]; then
  echo "推送到远程分支失败。"
  exit 1
fi

echo "操作完成。"

# dev-20240815
# ft/20240815/CLOUDPHONE-3196-clip
# a_patches/snow/0016-bidirectional-replication-release1-patch
# ft(剪切板)：双向复制粘贴安卓镜像支持