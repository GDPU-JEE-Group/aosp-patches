#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <cpp-file>"
    exit 1
fi

file=$1

# 使用grep查找函数定义并打印行号，同时用awk提取函数名称及其所在行号
grep -nE '^[a-zA-Z_][a-zA-Z0-9_<> ,*&:]*\([a-zA-Z0-9_<> ,*&:\[\]\(\)\{\}]*\)\s*\{' "$file" | awk -F: '{print $1, $2}' | while read -r line func; do
    echo "$file:$line $func"
done
