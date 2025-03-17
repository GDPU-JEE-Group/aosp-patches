#!/system/bin/sh
###
# @Author: chaixiang chaixiang@ntimespace.com
# @Date: 2024-11-11 10:07:47
# @LastEditors: chaixiang chaixiang@ntimespace.com
# @LastEditTime: 2024-11-11 10:07:47
# @FilePath: /data/local/monopolygo/game_manage.sh
# @Description: 备份monopolygo游戏存档
###
debug=1
version=2024_1201_0110
# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
# ------------------------------------------------自定义变量区
# 设置当前脚本路径
base_dri=/data/local/wlan
cur_time=$(date  +%Y%m%d.%H%M)
max_log_size=8388608 # 8MB 日志最大的容量
log_path=$base_dri
log_name=$package_name.log
    # run_cmd tar -cf $game_save_dir/media-BASE.tar.gz /data/media/0/Android/data/$package_name

# 获取实例状态 传入存档命名
# 退出码：
# 0：成功
# 1：应用不存在
# 2: 存档目录创建失败
# 3：存档创建失败
# 4：切换存档失败，存档不存在：
# 5：非法参数
# 6：非法操作


# ------------------------------------------------公共基础工具函数库
# 打印并记录日志的函数
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
    echo "$message" >> "$log_path/$log_name"
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

# 检查日志文件大小，如果大于用户定义的最大值则清空
check_log_size() {
    if [ -f "$log_path" ]; then
        local log_size=$(stat -c%s "$log_path/$log_name")
        if [ "$log_size" -gt "$max_log_size" ]; then
            log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志文件超过用户定义的大小限制 $((max_log_size/1024/1024))MB，清空日志文件" "$NC"
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志文件超过用户定义的大小限制，清空日志文件" > "$log_path/$log_name"
        fi
    else
        mkdir -p $log_path
    fi

    log_and_echo  "debug == $debug" "$GREEN"
    log_and_echo  "version == $version" "$GREEN"
    log_and_echo  "base_dri == $base_dri" "$GREEN"
    log_and_echo  "cur_time == $cur_time" "$GREEN"
    log_and_echo  "max_log_size == $max_log_size" "$GREEN"
    log_and_echo  "operation == $operation" "$GREEN"
    log_and_echo  "package_name == $package_name" "$GREEN"
    log_and_echo  "backup_label == $backup_label" "$GREEN"
    log_and_echo  "log_path == $log_path" "$GREEN"
    log_and_echo  "log_name == $log_name" "$GREEN"
    log_and_echo  "game_save_dir == $game_save_dir" "$GREEN"
}


main(){
    # 获取 eth0 的 IP 地址和网关
    eth0_addr=$(/system/bin/ip addr show dev eth0 | grep 'inet ' | awk '{print $2}')
    eth0_gw=$(/system/bin/ip route get 8.8.8.8 | head -n 1 | awk '{print $3}')

    # 重命名 eth0 为 wlan0
    run_cmd /system/bin/ip link set eth0 down
    run_cmd /system/bin/ip link set eth0 name wlan0
    run_cmd /system/bin/ip link set wlan0 up

    # 为 wlan0 配置 IP 地址和路由
    run_cmd /system/bin/ip addr add ${eth0_addr} dev wlan0
    run_cmd /system/bin/ip link set wlan0 up
    run_cmd /system/bin/ip route add default via ${eth0_gw} dev wlan0


    # 创建一个名为 br0 的桥接接口
    run_cmd /system/bin/ip link add name br0 type bridge

    # 将 wlan0 加入桥接
    run_cmd /system/bin/ip link set wlan0 master br0

    # 配置桥接接口的 IP 地址
    run_cmd /system/bin/ip addr add ${eth0_addr} dev br0

    # 设置桥接接口为 UP
    run_cmd /system/bin/ip link set br0 up


    # 启动 hostapd 和 dnsmasq
    run_cmd setprop ctl.start redroid_hostapd
    run_cmd setprop ctl.start redroid_dhcpserver

    # 确保 IP 转发功能启用
    run_cmd /system/bin/sysctl -w net.ipv6.conf.all.forwarding=1

}

