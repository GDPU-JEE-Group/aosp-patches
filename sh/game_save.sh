#!/system/bin/sh
###
# @Author: chaixiang chaixiang@ntimespace.com
# @Date: 2024-11-11 10:07:47
# @LastEditors: chaixiang chaixiang@ntimespace.com
# @LastEditTime: 2024-11-11 10:07:47
# @FilePath: /data/local/monopolygo/backup.sh
# @Description: 备份monopolygo游戏存档
###
debug=1
version=2024_1111_1007
# 设置颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
# ------------------------------------------------自定义变量区
# 设置当前脚本路径
base_dri=/data/local/monopolygo
cur_time=$(date  +%Y%m%d.%H%M)
max_log_size=8388608 # 8MB 日志最大的容量
operation=$1
backup_label=$2
log_path=$base_dri
log_name=monopolygo.log
game_save_dir=$base_dri/game_save

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
    log_and_echo  "backup_label == $backup_label" "$GREEN"
    log_and_echo  "log_path == $log_path" "$GREEN"
    log_and_echo  "log_name == $log_name" "$GREEN"
    log_and_echo  "game_save_dir == $game_save_dir" "$GREEN"
}


# ------------------------------------------------业务代码
# 使用说明
usage() {
    echo "使用方法: $0 <operation> <backup_label>"
    echo "参数说明："
    echo "  <operation>      必填，指定操作类型。支持的值有："
    echo "                   - backup  : 备份操作"
    echo "                   - restore : 恢复操作"
    echo "                   - list : 列出所有存档操作"
    echo "  <backup_label>   必填，备份的标签，用于标记备份或恢复点"
    echo "示例："
    echo "  $0 backup my_backup_2024"
    echo "  $0 restore my_backup_2024"
    echo "  $0 list my_backup_2024"
}
# 函数：检查包名是否存在
check_package() {
    package_name="com.scopely.monopolygo"

    # 获取第三方应用的包名列表
    package_list=$(pm list package -3)

    # 判断包名是否存在
    if echo "$package_list" | grep -q "$package_name"; then
        echo "包名 $package_name 存在"
    else
        echo "包名 $package_name 不存在"
        exit 1 #应用不存在
    fi
}
game_save_path_is_exist(){
    # 检查目录是否存在
    if [[ ! -d "$game_save_dir" ]]; then
        echo "目录 $game_save_dir 不存在，尝试创建..."

        # 尝试递归创建目录
        if mkdir -p "$game_save_dir"; then
            echo "目录创建成功：$game_save_dir"
        else
            echo "目录创建失败：$game_save_dir exit 1"
            exit 2  # 存档目录创建失败 2
        fi
    else
        echo "目录已存在：$game_save_dir"
    fi
}

backup(){
    if [[ -f "$game_save_dir/data-monopolygo-$backup_label.tar.gz" ]]; then
        run_cmd rm $game_save_dir/data-monopolygo-$backup_label.tar.gz
    fi
    run_cmd tar -cvf $game_save_dir/data-monopolygo-$backup_label.tar.gz /data/data/com.scopely.monopolygo
    # 检查存档是否存在
    if [[ ! -f "$game_save_dir/data-monopolygo-$backup_label.tar.gz" ]]; then
        echo "存档目录不存在：$game_save_dir/data-monopolygo-$backup_label.tar.gz"
        exit 3 # 存档创建失败 3
    fi
}

restore(){
    # 检查存档是否存在
    if [[ ! -f "$game_save_dir/data-monopolygo-$backup_label.tar.gz" ]]; then
        echo "存档不存在：$game_save_dir/data-monopolygo-$backup_label.tar.gz"
        exit 4 # 存档不存在： 4
    fi
    run_cmd pm clear com.scopely.monopolygo                                                                                                                                                   
    run_cmd tar -xvf $game_save_dir/data-monopolygo-$backup_label.tar.gz -C /
    #tar -xvf media-monopolygo.tar.gz   -C /
    #tar -xvf user_de-monopolygo.tar.gz  -C /
}
# 函数：列出所有存档文件并提取存档标签
list() {
    # 检查存档目录是否存在
    if [[ ! -d "$game_save_dir" ]]; then
        echo "存档目录不存在：$game_save_dir"
        return 1
    fi

    echo "存档列表："
    # 遍历 game_save 目录中的所有 .tar.gz 文件
    for save_file in "$game_save_dir"/data-monopolygo-*.tar.gz; do
        # 提取存档标签，例如从 data-monopolygo-a1.tar.gz 中提取 a1
        if [[ -f "$save_file" ]]; then
            save_label=$(basename "$save_file" | sed -E 's/^data-monopolygo-(.*)\.tar\.gz$/\1/')
            echo "存档标签：$save_label"
        fi
    done
}
new_game(){
    run_cmd pm clear com.scopely.monopolygo
}
# ------------------------------------------------主逻辑
# 参数检查
if [[ $# -lt 2 ]]; then
    echo "错误：参数不足。"
    usage
    exit 5 # 非法参数 5
fi
check_log_size
check_package
game_save_path_is_exist
case $operation in
    backup)
        # 当 variable 匹配 pattern1 时执行的命令
        backup
        ;;
    restore)
        # 当 variable 匹配 pattern2 时执行的命令
        restore
        ;;
    list)
        # 当 variable 匹配 pattern2 时执行的命令
        list
        ;;
    new_game)
        # 当 variable 匹配 pattern2 时执行的命令
        new_game
        ;;
    *)
        # 默认情况：当 variable 不匹配任何模式时执行
        log_and_echo "operation $operation is  illegal"
        exit 6  # 非法操作 6
        ;;
esac
log_and_echo '----------------------------------------------------------------------------------------------'
exit 0




# tar -cvf data-monopolygo.tar.gz /data/data/com.scopely.monopolygo
# tar -cvf media-monopolygo.tar.gz /data/media/0/Android/data/com.scopely.monopolygo 
# tar -cvf user_de-monopolygo.tar.gz /data/user_de/0/com.scopely.monopolygo