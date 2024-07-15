# rm -rf IMAGE

msg=$1
ip=$2
num=$3

if [ "$msg" = "-h" ]; then
    echo ./snow.sh $msg $ip $num
    echo ./snow.sh test 30.34 3
    exit 0
else
    echo ""
fi

source build/envsetup.sh

lunch rk3588_docker-user

./build_docker_android_snow.sh -A $msg $ip $num

# 我 把 setType=0，logd all 打印了 
