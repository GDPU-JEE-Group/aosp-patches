#!/bin/bash

# 检查是否需要显示帮助信息
if [ "$1" == "-h" ]; then
    echo "Usage: $0 <file extension> <keyword1> <keyword2>"
    echo "Example: $0 .java AAA BBB"
    exit 0
fi

# 获取文件扩展名和关键词
file_extension=$1
keyword1=$2
keyword2=$3

# 定义排除目录数组
excluded_dirs=("out" "IMAGE" ".git")

# 构建排除目录的find命令参数
exclude_params=()
for dir in "${excluded_dirs[@]}"; do
    exclude_params+=(-not -path "./$dir/*")
done

# 查找文件名包含指定扩展名，且内容包含两个关键词的文件，排除指定目录
find . -name "*$file_extension" "${exclude_params[@]}" -exec grep -l "$keyword1" {} + | xargs grep -l "$keyword2"
