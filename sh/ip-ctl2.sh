#!/system/bin/sh

package_name=$1      # 应用包名
operate=$2           # 操作: get 或 set
val=$3               # true 或 false

IPTABLES=iptables
BUSYBOX=busybox
GREP=grep
ECHO=echo

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
                exit 10
        fi
fi

# Try to find iptables
if ! command -v iptables &> /dev/null; then
    if /data/user/0/com.aidian.flowhelper/app_bin/iptables_armv5 --version >/dev/null 2>/dev/null ; then
            IPTABLES=/data/user/0/com.aidian.flowhelper/app_bin/iptables_armv5
    fi
fi

$IPTABLES --version || exit 10

# 获取应用的 UID
get_uid_from_package() {
    package_name=$1
    # 获取应用 UID
    uid=$(dumpsys package $package_name | grep userId= | awk -F'=' '{print $2}')
    if [ -z "$uid" ]; then
        echo "UID not found for $package_name"
        exit 10
    fi
    echo $uid
}

# 设置限制
set_restriction() {
    package_name=$1
    uid=$2

    # 为该应用的 UID 设置流量限制
    $IPTABLES -A droidwall-3g -m owner --uid-owner $uid -j droidwall-reject || exit 10
    $IPTABLES -A droidwall-wifi -m owner --uid-owner $uid -j droidwall-reject || exit 10
    $IPTABLES -A droidwall-eth0 -m owner --uid-owner $uid -j droidwall-reject || exit 10
}

# 取消限制
unset_restriction() {
    package_name=$1
    uid=$2

    # 删除该应用的流量限制规则
    $IPTABLES -D droidwall-3g -m owner --uid-owner $uid -j droidwall-reject || exit 10
    $IPTABLES -D droidwall-wifi -m owner --uid-owner $uid -j droidwall-reject || exit 10
    $IPTABLES -D droidwall-eth0 -m owner --uid-owner $uid -j droidwall-reject || exit 10
}

# 获取是否被限制
check_restriction() {
    package_name=$1
    uid=$2

    # 检查是否存在流量限制规则
    result=$(iptables -L droidwall-3g -v -n | grep -- "-m owner --uid-owner $uid" || true)
    if [ -n "$result" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# 根据操作选择执行的内容
uid=$(get_uid_from_package $package_name)

if [ "$operate" == "set" ]; then
    if [ "$val" == "true" ]; then
        # 设置限制
        set_restriction $package_name $uid
        echo "Network restriction applied to $package_name"
        exit 0
    elif [ "$val" == "false" ]; then
        # 取消限制
        unset_restriction $package_name $uid
        echo "Network restriction removed from $package_name"
        exit 0
    else
        echo "Invalid value for 'set' operation. Use true or false."
        exit 10
    fi
elif [ "$operate" == "get" ]; then
    # 获取是否被限制
    restriction_status=$(check_restriction $package_name $uid)
    echo "$restriction_status"
    exit 0
else
    echo "Invalid operation. Use 'get' or 'set'."
    exit 10
fi
