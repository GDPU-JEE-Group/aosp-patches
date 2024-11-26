#!/bin/bash
# 定义远程仓库地址列表
ADD_REPO=(
    "https://gitee.com/trychar-no1/snow-env/raw/master"
    "https://raw.githubusercontent.com/GDPU-JEE-Group/snow-env/refs/heads/master"
)
# 通用函数：从多个仓库加载指定脚本并导入其所有函数----------------------------------
import_sh() {
    local script_path="$1"
    local tmp_script="/tmp/remote_script.sh"

    for repo_base in "${ADD_REPO[@]}"; do
        local full_url="${repo_base}/${script_path}"
        echo "尝试从 $full_url 下载脚本..."
        if curl -s -o "$tmp_script" "$full_url"; then
            echo "成功从 $full_url 下载脚本。"
            chmod +x "$tmp_script"
            source "$tmp_script" # 导入脚本内容
            rm -f "$tmp_script"  # 清理临时文件
            return 0
        else
            echo "从 $full_url 下载失败。"
        fi
    done

    echo "所有仓库均无法加载脚本 '$script_path'。"
    return 1
}
# 示例：执行远程脚本
# bash <(wget -qO- https://gitee.com/trychar-no1/snow-env/raw/master/init.sh)
# bash <(curl -s https://gitee.com/trychar-no1/snow-env/raw/master/init.sh)
# 示例：导入远程函数
# source <(curl -s https://example.com/path/to/script.sh)
# source <(wget -qO- https://example.com/path/to/script.sh)
# -----------------------------------------------------------------------------
# *****************************************************************************
# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# =============================================================================
import_sh "util.sh" || exit 1

run_cmd ls -al
