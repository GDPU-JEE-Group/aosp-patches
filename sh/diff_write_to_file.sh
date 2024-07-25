#!/bin/bash
rm -rf ./aa/*.diff
# 定义源目录和目标目录
SRC_DIR="/linux_data/rockchip_android_src/android_10_bak"
DEST_DIR="/linux_data/alex/snow/android10-rk3588"
OUTPUT_DIR="./aa"

# 定义排除目录列表
EXCLUDE_DIRS=("out" "IMAGE")

# 创建输出目录
mkdir -p $OUTPUT_DIR

# 获取源目录和目标目录中的一级子目录
src_subdirs=$(ls -d $SRC_DIR/*/ 2>/dev/null | xargs -n 1 basename)
dest_subdirs=$(ls -d $DEST_DIR/*/ 2>/dev/null | xargs -n 1 basename)

# 取交集，只比较同时存在于两个目录中的子目录
common_subdirs=$(echo $src_subdirs $dest_subdirs | tr ' ' '\n' | sort | uniq -d)

# 过滤排除目录
for exclude in "${EXCLUDE_DIRS[@]}"; do
    common_subdirs=$(echo "$common_subdirs" | grep -vw "$exclude")
done

# 遍历公共子目录，比较差异并保存到文件
for subdir in $common_subdirs; do
    src_path="$SRC_DIR/$subdir"
    dest_path="$DEST_DIR/$subdir"
    output_file="$OUTPUT_DIR/$subdir.diff"
    
    echo "Comparing $src_path with $dest_path"
    diff -urN --exclude=".git" $src_path $dest_path > $output_file
done

echo "Comparison complete. Differences saved in $OUTPUT_DIR."
