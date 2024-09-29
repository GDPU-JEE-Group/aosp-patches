# #!/bin/bash

# # 检查是否提供了文件路径
# if [ -z "$1" ]; then
#   echo "Usage: $0 <java-file>"
#   exit 1
# fi

# # 获取文件路径
# file=$1

# # 使用awk和grep提取方法声明行，并格式化输出
# awk -v file="$file" '
# {
#   if ($0 ~ /^[ \t]*(public|protected|private)[ \t]+[a-zA-Z<>]+[ \t]+[a-zA-Z0-9_]+\s*\(.*\)\s*\{/) {
#     line = $0
#     gsub(/(public|protected|private)/, "\033[1;31m&\033[0m", line)  # 设置访问修饰符为粗体红色
#     printf "\033[1;34m%s\033[0m:\033[1;32m%d\033[0m: %s\n", file, NR, line
#   }
# }' "$file"
#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'  # 绿色
RED='\033[0;31m'    # 红色
WHITE='\033[0;37m'  # 白色
RESET='\033[0m'     # 重置颜色

# 检查参数
if [ $# -ne 1 ]; then
    echo -e "${RED}用法: $0 <java_file_path>${RESET}"
    exit 1
fi

# 获取文件路径
JAVA_FILE="$1"

# 检查文件是否存在
if [ ! -f "$JAVA_FILE" ]; then
    echo -e "${RED}文件不存在: $JAVA_FILE${RESET}"
    exit 1
fi

# 列出函数定义
grep -n '^[[:space:]]*public\|protected\|private\|static\|synchronized\|native\|abstract' "$JAVA_FILE" | while IFS= read -r line; do
    # 提取行号和方法定义
    line_number=$(echo "$line" | cut -d: -f1)
    method_signature=$(echo "$line" | cut -d: -f2-)

    # 高亮行号和关键字
    echo -e "${GREEN}${line_number}:${RESET} ${RED}${method_signature}${RESET}"
done

