#!/bin/bash

# 检查是否提供了文件路径
if [ -z "$1" ]; then
  echo "Usage: $0 <java-file>"
  exit 1
fi

# 获取文件路径
file=$1

# 使用awk和grep提取方法声明行，并格式化输出
awk -v file="$file" '
{
  if ($0 ~ /^[ \t]*(public|protected|private)[ \t]+[a-zA-Z<>]+[ \t]+[a-zA-Z0-9_]+\s*\(.*\)\s*\{/) {
    line = $0
    gsub(/(public|protected|private)/, "\033[1;31m&\033[0m", line)  # 设置访问修饰符为粗体红色
    printf "\033[1;34m%s\033[0m:\033[1;32m%d\033[0m: %s\n", file, NR, line
  }
}' "$file"
