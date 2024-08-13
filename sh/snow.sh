# rm -rf IMAGE

product=$1
msg=$2-$product
ip=$3
num=$4
DATE=$(date  +%Y%m%d.%H%M)

if [ "$1" = "-h"  ]; then
    echo ./snow.sh {product} {msg} {ip} {num}
    echo ./snow.sh samsung test 168.34 2
    exit 0
else
    echo ""
fi

source build/envsetup.sh

if [ "$product" = "out" ]; then
    lunch rk3588_docker_overseas-user
elif [ "$product" = "in" ]; then
    lunch rk3588_docker_inland-user
elif [ "$product" = "samsung" ]; then
    lunch GT_P7500-user
elif [ "$product" = "guozhen" ]; then
    lunch rk3588_docker_guozhen-user
    echo my_build_guozhen.sh $DATE
    /snow/android10-rk3588/my_build_guozhen.sh $DATE
    exit 0
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!errror"
else
    lunch rk3588_docker_overseas-user
fi

    # lunch rk3588_docker-user


a_patches/sh/build_docker_android_snow.sh -A $msg $ip $num

kill-stream.sh 192.168.$ip $num

# 我 把 setType=0，logd all 打印了 
