# functions.sh

run_cmd() {
    echo -e "\033[0;32mExecuting: $*\033[0m"
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "\033[0;31mError: Command failed with status $status\033[0m"
        exit $status
    fi
}
# 定义函数 check_args
check_args() {
    # 检查是否有任意一个参数为空
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        # 打印示例信息
        # echo "Usage: $0 <arg1> <arg2> <arg3>"
        # echo "Example: $0 value1 value2 value3"
        echo "Usage: $0 image_msg ip num"
        echo "Example: $0 oversea_gps 30.34 1"
        # 退出脚本
        exit 1
    fi
}


# 定义run_container函数
run_container() {
    # 接受两个参数
    local num=$1
    local image=$2

    # 如果image为空，则赋值为redroid10
    if [ -z "$image" ]; then
        image="rd_arm10"
    fi

 docker stop redroid10arm_$num
 docker rm redroid10arm_$num
 
    run_cmd docker run -itd  --privileged --name redroid10arm_$num \
    -v /userdata/snow/redroid_data/rd_$num/:/data \
    -p 110"$num":5555 \
    $image \
    androidboot.redroid_width=1080 \
    androidboot.redroid_height=1920 \
    androidboot.redroid_dpi=480 \
    androidboot.redroid_gpu_mode=guest \

}
