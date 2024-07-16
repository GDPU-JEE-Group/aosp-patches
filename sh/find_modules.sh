#!/bin/bash

# 要遍历的目录
TARGET_DIR=$1

# 检查是否指定了目录
if [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 <target-directory>"
  exit 1
fi

# 检查目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
  echo "Directory $TARGET_DIR does not exist."
  exit 1
fi

# 查找并处理 .bp 文件中的模块名
echo "Module names in .bp files:"
find "$TARGET_DIR" -name "*.bp" | while read -r file; do
  grep -E '^\s*name\s*:\s*".*"' "$file" | sed -E 's/^\s*name\s*:\s*"([^"]+)".*/\1/'
done

echo

# 查找并处理 .mk 文件中的模块名
echo "Module names in .mk files:"
find "$TARGET_DIR" -name "*.mk" | while read -r file; do
  grep -E '^\s*LOCAL_MODULE\s*[:=]\s*.*' "$file" | sed -E 's/^\s*LOCAL_MODULE\s*[:=]\s*([^ ]+).*/\1/'
done
