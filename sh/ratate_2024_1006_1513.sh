#!/bin/bash

debug=0
version=2024_1006_1513
# ------------------------------------------------自定义变量区
# 设置当前脚本路径
log_path="/userdata/log"
log_name="ratate.log"
loop_time=3 # 每次循环的间隔时间
max_log_size=8388608 # 8MB 日志最大的容量
# nums是要执行的容器的编号数组，例如：nums=(1 2 5)，则脚本每次在容器android_1,android_2,android_5执行旋转的逻辑
# 还有 nums="auto",则会默认脚本开始时扫描有几个安卓容器，自动把他们加进nums里。
nums="auto"
# nums=(1 2 4)


# ------------------------------------------------公共工具函数库
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
    if [ -f "$log_path/$log_name" ]; then
        local log_size=$(stat -c%s "$log_path/$log_name")
        if [ "$log_size" -gt "$max_log_size" ]; then
            log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志文件超过用户定义的大小限制 $((max_log_size/1024/1024))MB，清空日志文件" "$NC"
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志文件超过用户定义的大小限制，清空日志文件" > "$log_path/$log_name"
        fi
    else
        mkdir -p $log_path
    fi
}

# 杀掉除本次进程以外的其他ratate.sh
kill_other_ratate() {
    log_and_echo "=> 2.杀掉除本次进程以外的其他ratate.sh"

    # 打印当前 ratate 进程信息
    run_cmd bash -c "top -b -n 1 | grep ratate"

    # 获取当前脚本的 PID
    current_pid=$$
    log_and_echo "获取当前脚本的 PID: $current_pid"

    # 获取除当前进程以外的其他 ratate 进程 PID
    kill_pid=$(ps -ef | grep ratate | grep -v grep | awk -v current_pid="$current_pid" '{if ($2 != current_pid) print $2}')

    # 检查 kill_pid 是否为空
    if [ -n "$kill_pid" ]; then
        log_and_echo "killed的 PID: $kill_pid"
        
        # 循环遍历 kill_pid 并杀死每个进程
        for pid in $kill_pid; do
            log_and_echo "杀死进程 $pid"
            run_cmd kill $pid
        done
    else
        log_and_echo "没有其他 ratate 进程需要杀掉" "$YELLOW"
    fi

    # 打印杀掉进程后的进程信息
    run_cmd bash -c "top -b -n 1 | grep ratate"
}

# 主循环，每3秒检测一次
main_loop() {
    log_and_echo "=> 3.进入主循环不断把要旋转的云机转成竖屏"

    while true; do
        # 检查日志文件大小
        check_log_size
        
        ratate #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        # 每3秒检测一次
        sleep $loop_time
    done
}


# ------------------------------------------------业务代码区
# 强制旋转成竖屏
ratate() { 
    for cur_num in "${nums[@]}"; do
        # 获取 accelerometer_rotation 当前值
        original_value=$(docker exec -i android_$cur_num settings get system accelerometer_rotation)
        
        # 错误检测
        if [ -z "$original_value" ] || [[ ! "$original_value" =~ ^(0|1)$ ]]; then
            log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 错误: 获取到的 accelerometer_rotation 值无效 (云机: $cur_num, 值: $original_value)" "$RED"
            original_value=0
        fi
        
        log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 当前 accelerometer_rotation 值: $original_value (云机: $cur_num)" "$NC"
        
        # 将 accelerometer_rotation 设置为 0（禁用自动旋转）
        run_cmd docker exec -i android_$cur_num settings put system accelerometer_rotation 0

        # 将屏幕强制设置为竖屏
        run_cmd docker exec -i android_$cur_num settings put system user_rotation 0

        # 恢复原来的 accelerometer_rotation 值
        run_cmd docker exec -i android_$cur_num settings put system accelerometer_rotation $original_value
    done
}

# 检测 nums数组或自动扫描在线容器填写nums
check_nums() {
    log_and_echo "=> 1.检测 nums数组是否合法或自动扫描在线容器填写nums（确认物理机上有哪些容器要旋转，把编号写入数组nums）"

    # 检测 nums 是否为 "auto"
    if [ "$nums" == "auto" ]; then
        # 获取所有容器名称
        container_names=$(docker ps --format "{{.Names}}")
        nums=()
        # 遍历所有容器名称，匹配格式 android_0, android_1, android_2...
        for container in $container_names; do
            if [[ $container =~ ^android_([0-9])$ ]]; then
                # 提取数字并加入 nums 数组
                nums+=("${BASH_REMATCH[1]}")
            fi
        done
    fi

    # 检测 nums 数组中的元素是否全为 0 到 9 的数字
    for num in "${nums[@]}"; do
        if ! [[ "$num" =~ ^[0-9]$ ]]; then
            log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 错误: 无效的数字 $num，nums 数组只能包含 0-9 之间的数字" "$RED"
            exit 1
        fi
    done

    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 是否为Debug模式： $debug ,交付给运维时必须为0" "$GREEN"
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 脚本版本号:$version " "$GREEN"
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志路径: $log_path/$log_name" "$GREEN"
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志文件最大值: $max_log_size , 1MB是1048576" "$GREEN"
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 每次循环检测间隔: $loop_time s" "$GREEN"
    log_and_echo "[$(date +'%Y-%m-%d %H:%M:%S')] 被检测这些android_容器的编号有: ${nums[*]}" "$GREEN"
    
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 是否为Debug模式： $debug ,交付给运维时必须为0" 
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 脚本版本号： $version "
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志路径: $log_path/$log_name" 
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 日志文件最大值: $max_log_size , 1MB是1048576"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 每次循环检测间隔: $loop_time s" 
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] 被检测这些android_容器的编号有: ${nums[*]}" 
    echo "------------------------------ 以上变量都可以在脚本变量区 自由设置"
}





# ------------------------------------------------实际执行命令的区间
# 1.检查日志大小
# 2.检查要旋转的云机编号
# 3.杀掉除本次进程以外的其他ratate.sh
# 4.进入主循环不断把要旋转的云机转成竖屏
check_log_size
check_nums
kill_other_ratate
ratate #确保至少执行一遍没有出错，才能打印成功
main_loop &

echo "[$(date +'%Y-%m-%d %H:%M:%S')] --执行成功，执行日志在 cat $log_path/$log_name"