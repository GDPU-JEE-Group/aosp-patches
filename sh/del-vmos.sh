#!/bin/sh
### -------------参数区
# 设置当前脚本路径
cur_path="/userdata"
log_name="del-vmos.log"
base_dir="/userdata/container/android_data"
search_term="vmos.db"
# 检测间隔时间，单位秒
loop_time=500

# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

### -------------函数区

# 打印并记录日志的函数
log_and_echo() {
    local message="$1"
    local color="$2"

    # # 打印信息到控制台并根据颜色设置
    # if [ -n "$color" ]; then
    #     echo -e "${color}${message}${NC}"
    # else
    #     echo "$message"
    # fi

    # 将信息写入日志文件
    echo "$message" >> "$cur_path/$log_name"
}

# 记录并运行命令
run_cmd() {
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 执行命令: $*" "$NC"
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 错误: 命令执行失败，状态码 $status" "$RED"
        return 1
    else
        log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 命令执行成功" "$GREEN"
        return 0
    fi
}

# 检查日志文件大小，如果大于2MB则清空
check_log_size() {
    if [ -f $cur_path/$log_name ]; then
        local log_size=$(stat -c%s "$cur_path/$log_name")
        if [ $log_size -gt 2097152 ]; then
            log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志文件超过2MB，清空日志文件" "$NC"
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志文件超过2MB，清空日志文件" > $cur_path/$log_name
        fi
    fi
}

# 主循环，每5秒检测一次
main_loop() {
    while true; do
        # 检查日志文件大小
        check_log_size

        # 扫描所有容器并过滤掉journal文件
        find $base_dir/* -name "*$search_term*" | grep -v 'journal' | while read line; do
            log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 查找到: $line" "$NC"

            # 提取容器编号并确保只处理 0-9 之间的编号
            container_id=$(echo $line | grep -o 'data_[0-9]' | sed 's/data_//')
            package_name=$(echo $line | awk -F '/' '{print $(NF-2)}')

            # 如果没有找到符合条件的容器和包名，跳过该次操作
            if [ -z "$container_id" ] || [ -z "$package_name" ]; then
                log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 未找到符合条件的容器或包名，跳过" "$RED"
                continue
            fi

            log_and_echo "在容器 $container_id 中找到包 $package_name" "$GREEN"

            # 使用 docker 卸载应用，不再使用 -it，只使用 -i
            log_and_echo "docker exec -i android_$container_id pm uninstall $package_name" "$NC"
            docker exec -i android_$container_id pm uninstall $package_name

            if [ $? -eq 0 ]; then
                log_and_echo "应用 $package_name 在容器 $container_id 中成功卸载" "$GREEN"
            else
                log_and_echo "应用 $package_name 在容器 $container_id 中卸载失败" "$RED"
            fi
        done

        # 如果 find 没有找到任何结果，不打印任何信息并进入下一个检测周期
        if [ $(find $base_dir/* -name "*$search_term*" | grep -v 'journal' | wc -l) -eq 0 ]; then
            log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 未找到任何匹配的文件" "$RED"
        fi

        # 每5秒检测一次
        sleep $loop_time
    done
}

# 调用主循环在后台运行
echo "若想修改间隔时间、日志路径，请修改本脚本里变量区的值，默认间隔$loop_time s"
echo "日志在   cat $cur_path/$log_name" "$NC"
main_loop &
