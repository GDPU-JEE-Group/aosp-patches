#!/system/bin/sh

apk_path=$1
apk_name=$2

# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
debug=1
log_and_echo() {
    local message="$1"
    local color="$2"

    # 打印信息到控制台并根据颜色设置（仅在 debug 模式下）
    if [ "$debug" -eq 1 ]; then
        if [ -n "$color" ]; then
            echo -e "${color}${message}${NC}"
        else
            echo "$message"
        fi
    fi

    # 将信息写入日志文件
    # echo "$message" >> "$log_path/$log_name"
}

# 错误处理函数
errorr() {
    local error_message="$1"
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 错误: $error_message" "$RED"
}

# 记录并运行命令
run_cmd() {
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 执行命令: $*" "$NC"

    # 捕获命令的输出
    local output
    output=$("$@" 2>&1)
    local status=$?

    # 记录命令输出到日志
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 命令输出: $output" "$NC"

    if [ $status -ne 0 ]; then
        errorr "命令执行失败，状态码 $status"
        return 1
    else
        log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 命令执行成功" "$GREEN"
        return 0
    fi
}



run_cmd mount -o remount -o rw /
run_cmd mkdir -p /system/priv-app/$apk_name
run_cmd cp -r $apk_path /system/priv-app/$apk_name/
run_cmd chmod -R 755 /system/priv-app/$apk_name
run_cmd chown -R root:root /system/priv-app/$apk_name
run_cmd mount -o remount -o ro /

run_cmd ls -al /system/priv-app/$apk_name/