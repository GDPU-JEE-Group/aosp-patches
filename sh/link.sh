#!/bin/bash

# 定义源目录和目标目录
# src_dir=$1
src_dir="./a_patches/sh"
dst_dir=$2

chmod +x a_patches/sh/*.sh

# 遍历源目录下的所有文件
for file in "$src_dir"/*; do
    # 获取文件名
    filename=$(basename "$file")
    # 在目标目录下创建软链接
    ln -s "$file" "$dst_dir/$filename"

done

cat /snow/android10-rk3588/a_patches/gitinore > .gitignore

ln -s a_patches/TODO.md TODO.md