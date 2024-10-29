#!/bin/bash
source util.sh
# 检查参数数量是否正确
if [ $# -ne 2 ]; then
    echo "Usage: $0 <文件路径> <自定义名称>"
    echo "       AppStore"
    echo "       ESFileExplorer"
    echo "       google-chrome"
    echo "       com.google.android.gms"
    echo "       com.sohu.inputmethod.sogou"
    echo "       Gboard"
    echo "       czwg"
    echo "       Launcher3-aosp-withQuickstep"
    echo "       extension_tools"
    echo "       com.google.android.apps.nbu.files"
    echo "       AppStore"
    echo "       AppStore"
    

    exit 1
fi

# 获取传入的参数
FILE_PATH=$1
CUSTOM_NAME=$2

# 检查文件是否存在
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: 文件不存在: $FILE_PATH"
    exit 1
fi

# 获取当前时间戳
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# 原文件名（不带路径）
ORIGINAL_FILE_NAME=$(basename "$FILE_PATH")

# 目标目录
TARGET_DIR="./packages/apps/ntimesapp"

# 新文件名（在原文件名基础上加上时间戳）
NEW_FILE_NAME="${ORIGINAL_FILE_NAME%.*}_${TIMESTAMP}.apk"

# 删除旧的自定义名称.apk 文件
if [ -f "${TARGET_DIR}/${CUSTOM_NAME}.apk" ]; then
   run_cmd rm "${TARGET_DIR}/${CUSTOM_NAME}.apk"
fi

# 复制文件到目标目录并重命名
run_cmd cp "$FILE_PATH" "${TARGET_DIR}/${NEW_FILE_NAME}"

# 创建自定义名称的软链接，指向重命名后的文件
run_cmd ln -s "${NEW_FILE_NAME}" "${TARGET_DIR}/${CUSTOM_NAME}.apk"

# 完成
echo "文件已重命名为: ${NEW_FILE_NAME} 并复制到 ${TARGET_DIR}"
echo "软链接 ${CUSTOM_NAME}.apk 已指向 ${NEW_FILE_NAME}"

run_cmd ls -al $TARGET_DIR