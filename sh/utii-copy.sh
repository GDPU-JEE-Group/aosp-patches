#! /bin/bash
#日志
LOG_FILE=./log_file
# LOG_FILE_SIZE=20000
LOG_LEVEL=0
WRITE_TO_STDOUT=false
#must 2 parameters: loglevel(INFO,DEBUG,ERROR),msg
log() {
    if [ 2 -gt $# ]; then
        echo "parameter not right in log function"
        return 1
    fi
    if [ ! -e "$LOG_FILE" ]; then
        touch "$LOG_FILE"
    fi

    local logLevel=$1
    if [ "$logLevel" == 'INFO' -a "$LOG_LEVEL" -gt 1 ]; then
        return
    elif [ "$logLevel" == 'ERROR' -a "$LOG_LEVEL" -gt 2 ]; then
        return
    elif [ "$logLevel" == 'DEBUG' -a "$LOG_LEVEL" -gt 0 ]; then
        return
    fi

    local curtime=$(date +"%Y-%m-%d %H:%M:%S")

    #debug日志不写文件
    if [ "$logLevel" == 'DEBUG' ]; then
        if $WRITE_TO_STDOUT; then
            echo -e "[$curtime] $*"
        fi
    else
        if $WRITE_TO_STDOUT; then
            echo -e "[$curtime] $*"
        fi
        echo -e "[$curtime] $*" >>$LOG_FILE
    fi
}

#eval运行指令，运行失败会打印日志
run_cmd() {
    cmd=$1
    log INFO "Executing command: $cmd"
    output=$(eval "$cmd" 2>&1)
    ret=$?
    log INFO "Command output:\n$output"
    
    # 如果命令执行失败
    if [ $ret -eq 0 ]; then
        log INFO "Command succeeded."
    else
        # 输出错误到日志文件并显示错误到标准输出
        log ERROR "Command failed. Error output:\n$output"
        echo -e "Error: Command failed. Check log for details."
        echo -e "$output" >&2  # 输出错误信息到标准错误
    fi
    return $ret
}
