source a_patches/sh/util.sh
feature_branch=$1
template_branch=$2

check_args() {
    # 检查是否有任意一个参数为空
    if [ -z "$feature_branch" ] || [ -z "$feature_branch" ] ; then
        # 打印示例信息
        echo " - : $0 $feature_branch $feature_branch"
        echo "Usage: $0 feature_branch template_branch"
        echo "Example: $0 20241023/ft_CLOUDPHONE-4265_appguard dev-20241023"
        # 退出脚本
        exit 1
    fi
}

confirm_clear_operation(){
    # 确认操作
    echo "你真的要清除所有内容并拉取全新的分支吗? 输入 'yes' 确认: "
    read confirmation

    if [ "$confirmation" != "yes" ]; then
        echo "操作已取消。"
        exit 0
    else
        # 清理并重置本地分支
        git reset --hard
        git clean -fd
    fi
}

switch_branch(){
    # 检查远程分支是否存在
    if git ls-remote --exit-code --heads origin $template_branch; then
        # git 以某个分支为模板，创建一个新分支并切换到新分支
        run_cmd git fetch origin $template_branch:refs/remotes/origin/$template_branch
        run_cmd git checkout -b $feature_branch origin/$template_branch
    else
        echo -e "\033[0;31mError: $template_branch no error！ \033[0m"
    fi
}

#####################################################################
check_args
confirm_clear_operation
switch_branch

run_cmd git branch
