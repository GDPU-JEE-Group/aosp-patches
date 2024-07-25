#!/bin/bash

# 指定要递归查找的目录
SEARCH_DIR=$1

# 基准提交
BASE_COMMIT="8c4fd0980e98014761a379c07f6af8c55387dc15"
BASE_DATE="2024-05-08 14:40:32 +0800"


# --------------        转换日期
# # 原始日期字符串
# original_date="Thu Sep 22 16:39:06 2016 +0000"
# # 提取日期和时区部分
# date_part=$(echo "$original_date" | sed 's/ +.*//')
# tz_part=$(echo "$original_date" | sed 's/.* \(\+.*\)/\1/')
# # 将原始日期字符串转换为目标格式
# formatted_date=$(date -d "$date_part" "+%Y-%m-%d %H:%M:%S")
# # 输出结果
# echo "$formatted_date $tz_part"


# 输出文件路径
OUTPUT_FILE="./aa/list.txt"

# 排除的目录列表（可以添加更多目录）
EXCLUDE_DIRS=("out" "IMAGE" "RKDocs"  "test" "repo" )

# 创建输出文件目录
mkdir -p "$(dirname "$OUTPUT_FILE")"

# 清空输出文件
> "$OUTPUT_FILE"

# 递归查找包含 .git 子目录的目录
find "$SEARCH_DIR" -type d -name ".git" | while read -r git_dir; do
    repo_dir=$(dirname "$git_dir")
    
    # 检查是否在排除目录列表中
    exclude=false
    for exclude_dir in "${EXCLUDE_DIRS[@]}"; do
        if [[ "$repo_dir" == *"$exclude_dir"* ]]; then
            exclude=true
            break
        fi
    done

    if $exclude; then
        echo "Skipping excluded directory: $repo_dir"
        continue
    fi

    echo "Checking repository: $repo_dir"
    # 获取提交日期大于基准提交日期的提交记录
    git -C "$repo_dir" log --since="$BASE_DATE" --pretty=format:"%H" | grep -q .
    if [ $? -eq 0 ]; then
        echo "$repo_dir" >> "$OUTPUT_FILE"
    fi
done

echo "Done. Check the output file: $OUTPUT_FILE"
echo "------------------------------------"
cat $OUTPUT_FILE
