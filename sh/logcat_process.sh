#!/system/bin/sh

# 进程名称数组
processes=("com.google.android.gms" "com.android.vending" "com.google.android.gsf")

# 初始化一个空的 PID 数组
pids=()

# 遍历每个进程，获取 PID 并存入数组
for process in "${processes[@]}"; do
    # 获取进程 PID，并将其存入 pids 数组
    process_pids=$(ps -ef | grep "$process" | grep -v grep | awk '{print $2}')
    for pid in $process_pids; do
        pids+=("--pid=$pid")
    done
done

# 如果 pids 数组为空，表示没有找到进程
if [ ${#pids[@]} -eq 0 ]; then
    echo "没有找到相关进程，退出脚本。"
    exit 1
fi

# 运行 logcat 命令并传入所有的 --pid 参数
logcat "${pids[@]}"
