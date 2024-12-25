#!/system/bin/sh


package_name=$1      # 应用包名
operate=$2           # 操作: get 或 set
val=$3               # true 或 false

IPTABLES=iptables
BUSYBOX=busybox
GREP=grep
ECHO=echo

# ------------------------------------------------------
debug=0
version=2024_1217_1639
# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
# ------------------------------------------------自定义变量区
# 设置当前脚本路径
base_dri=/data/local/$package_name
cur_time=$(date  +%Y%m%d.%H%M)
max_log_size=8388608 # 8MB 日志最大的容量
log_path=$base_dri
log_name=$package_name.log
game_save_dir=$base_dri/ip-ctl

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

    # log_and_echo  "debug == $debug" "$GREEN"
    # log_and_echo  "version == $version" "$GREEN"
    # log_and_echo  "base_dri == $base_dri" "$GREEN"
    # log_and_echo  "cur_time == $cur_time" "$GREEN"
    # log_and_echo  "max_log_size == $max_log_size" "$GREEN"
    # log_and_echo  "operation == $operation" "$GREEN"
    # log_and_echo  "package_name == $package_name" "$GREEN"
    # log_and_echo  "backup_label == $backup_label" "$GREEN"
    # log_and_echo  "log_path == $log_path" "$GREEN"
    # log_and_echo  "log_name == $log_name" "$GREEN"
    # log_and_echo  "game_save_dir == $game_save_dir" "$GREEN"
}
check_log_size





# ------------------------------------------------------
#
# Try to find busybox
if /data/user/0/com.aidian.flowhelper/app_bin/busybox_g1 --help >/dev/null 2>/dev/null ; then
        BUSYBOX=/data/user/0/com.aidian.flowhelper/app_bin/busybox_g1
        GREP="$BUSYBOX grep"
        ECHO="$BUSYBOX echo"
elif busybox --help >/dev/null 2>/dev/null ; then
        BUSYBOX=busybox
elif /system/xbin/busybox --help >/dev/null 2>/dev/null ; then
        BUSYBOX=/system/xbin/busybox
elif /system/bin/busybox --help >/dev/null 2>/dev/null ; then
        BUSYBOX=/system/bin/busybox
fi
# Try to find grep
if ! $ECHO 1 | $GREP -q 1 >/dev/null 2>/dev/null ; then
        if $ECHO 1 | $BUSYBOX grep -q 1 >/dev/null 2>/dev/null ; then
                GREP="$BUSYBOX grep"
        fi
        # Grep is absolutely required
        if ! $ECHO 1 | $GREP -q 1 >/dev/null 2>/dev/null ; then
                $ECHO The grep command is required. DroidWall will not work.
                exit 1
        fi
fi
# Try to find iptables
# Added if iptables binary already in system then use it, if not use implemented one
if ! command -v iptables &> /dev/null; then
if /data/user/0/com.aidian.flowhelper/app_bin/iptables_armv5 --version >/dev/null 2>/dev/null ; then
        IPTABLES=/data/user/0/com.aidian.flowhelper/app_bin/iptables_armv5
fi
fi

        pro(){
                $IPTABLES --version || exit 1
                # Create the droidwall chains if necessary
                $IPTABLES -L droidwall >/dev/null 2>/dev/null || $IPTABLES --new droidwall || exit 2
                $IPTABLES -L droidwall-3g >/dev/null 2>/dev/null || $IPTABLES --new droidwall-3g || exit 3
                $IPTABLES -L droidwall-wifi >/dev/null 2>/dev/null || $IPTABLES --new droidwall-wifi || exit 4
                $IPTABLES -L droidwall-eth0 >/dev/null 2>/dev/null || $IPTABLES --new droidwall-eth0 || exit 5
                $IPTABLES -L droidwall-reject >/dev/null 2>/dev/null || $IPTABLES --new droidwall-reject || exit 6
                # Add droidwall chain to OUTPUT chain if necessary
                $IPTABLES -L OUTPUT | $GREP -q droidwall || $IPTABLES -A OUTPUT -j droidwall || exit 7
                $IPTABLES -L OUTPUT | $GREP -q droidwall-eth0 || $IPTABLES -A OUTPUT -j droidwall-eth0 || exit 8
                # Flush existing rules
                $IPTABLES -F droidwall || exit 9
                $IPTABLES -F droidwall-3g || exit 10
                $IPTABLES -F droidwall-wifi || exit 11
                $IPTABLES -F droidwall-eth0 || exit 12
                $IPTABLES -F droidwall-reject || exit 13
                # Create the reject rule (log disabled)
                $IPTABLES -A droidwall-reject -j REJECT || exit 14
                # Main rules (per interface)
                $IPTABLES -A droidwall -o rmnet+ -j droidwall-3g || exit
                $IPTABLES -A droidwall -o pdp+ -j droidwall-3g || exit
                $IPTABLES -A droidwall -o ppp+ -j droidwall-3g || exit
                $IPTABLES -A droidwall -o uwbr+ -j droidwall-3g || exit
                $IPTABLES -A droidwall -o wimax+ -j droidwall-3g || exit
                $IPTABLES -A droidwall -o vsnet+ -j droidwall-3g || exit
                $IPTABLES -A droidwall -o ccmni+ -j droidwall-3g || exit
                $IPTABLES -A droidwall -o usb+ -j droidwall-3g || exit
                $IPTABLES -A droidwall -o tiwlan+ -j droidwall-wifi || exit
                $IPTABLES -A droidwall -o wlan+ -j droidwall-wifi || exit
                $IPTABLES -A droidwall -o eth+ -j droidwall-eth0 || exit
                $IPTABLES -A droidwall -o ra+ -j droidwall-wifi || exit
        }






# --------------------------------------------------------
# 获取应用的 UID
get_uid_from_package() {
    package_name=$1
    # 获取应用 UID
    uid=$(dumpsys package $package_name | grep userId= | awk -F'=' '{print $2}')
    echo $uid
}

set_restriction() {
    package_name=$1
    uid=$2

        # Filtering rules
    run_cmd    $IPTABLES -A droidwall-3g -m owner --uid-owner $uid -j droidwall-reject || exit
    run_cmd    $IPTABLES -A droidwall-wifi -m owner --uid-owner $uid -j droidwall-reject || exit
    run_cmd    $IPTABLES -A droidwall-eth0 -m owner --uid-owner $uid -j droidwall-reject || exit

    echo iptables -L droidwall-eth0 -v -n
}


# 取消限制
unset_restriction() {
    package_name=$1
    uid=$2

        # Filtering rules
    # run_cmd    $IPTABLES -D droidwall-3g -m owner --uid-owner $uid -j droidwall-reject || exit
    # run_cmd    $IPTABLES -D droidwall-wifi -m owner --uid-owner $uid -j droidwall-reject || exit
    # run_cmd    $IPTABLES -D droidwall-eth0 -m owner --uid-owner $uid -j droidwall-reject || exit
    echo iptables -L droidwall-eth0 -v -n

}

# 获取是否被限制
check_restriction() {
    package_name=$1
    uid=$2


    # 检查是否存在流量限制规则
    result=$(iptables -L droidwall-eth0 -v -n | grep "owner UID match $uid" || true)

    if [ -n "$result" ]; then
        echo "true"
    else
        echo "false"
    fi
    # echo = $(iptables -L droidwall-eth0 -v -n|grep "owner UID match $uid" )

}


# 根据操作选择执行的内容
uid=$(get_uid_from_package $package_name)

if [ "$operate" == "set" ]; then
        pro  ####!
    if [ "$val" == "true" ]; then
        # 设置限制
        set_restriction $package_name $uid
        echo "Network restriction applied to $package_name"
    elif [ "$val" == "false" ]; then
        # 取消限制
        unset_restriction $package_name $uid
        echo "Network restriction removed from $package_name"
    else
        echo "Invalid value for 'set' operation. Use true or false."
        exit 1
    fi
elif [ "$operate" == "get" ]; then
    # 获取是否被限制
    restriction_status=$(check_restriction $package_name $uid)
    echo "$restriction_status"
else
    echo "Invalid operation. Use 'get' or 'set'."
    exit 1
fi

exit

## v1 version=2024_1217_1639
