#!/bin/bash
start_time=$(date  +.%H%M)
DATE=$(date  +%Y%m%d.%H%M)
#source build/envsetup.sh >/dev/null
source build/envsetup.sh
export PATH=$ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r416183b/bin:$PATH
export TARGET_PRODUCT=`get_build_var TARGET_PRODUCT`
export BUILD_VARIANT=`get_build_var TARGET_BUILD_VARIANT`
export ANDROID_VERSION=`get_build_var PRODUCT_ANDROID_VERSION`
export BUILD_JOBS=80			

echo $TARGET_PRODUCT 
export PROJECT_TOP=`gettop`
lunch $TARGET_PRODUCT-$BUILD_VARIANT

echo $TARGET_PRODUCT-$BUILD_VARIANT

STUB_PATH=Image/"$TARGET_PRODUCT"_"$ANDROID_VERSION"_"$BUILD_VARIANT"_"$DATE"
STUB_PATH="$(echo $STUB_PATH | tr '[:lower:]' '[:upper:]')"

export STUB_PATH=$PROJECT_TOP/$STUB_PATH
export STUB_PATCH_PATH=$STUB_PATH/PATCHES

if [ -n "$1" ]
then
    while getopts "KAP" arg
    do
         case $arg in
	     K)
	         echo "will build linux kernel with Clang"
	         BUILD_KERNEL=true
	         ;;
	     A)
	         echo "will build android"
	         BUILD_ANDROID=true
	         ;;
	     P)
		 echo "will generate patch"
		 BUILD_PATCH=true
		 ;;
             ?)
	         echo "will build kernel AND android"
	         BUILD_KERNEL=true
	         BUILD_ANDROID=true
		 BUILD_PATCH=true
	         ;;
         esac
    done
else
    echo "will build kernel AND android"
    BUILD_KERNEL=true
    BUILD_ANDROID=true
    BUILD_PATCH=true
fi

if [ "$BUILD_ANDROID" = true ] ; then
	# 判断是否存在lpunpack
	type lpunpack
	if [ $? -eq 0 ]; then
		echo "lpunpack is exit"
	else
		make lpunpack
	fi

	echo "start build android"
	make installclean
	make -j$BUILD_JOBS
	# check the result of Makefile
	if [ $? -eq 0 ]; then
		echo "Build android ok!"
	else
		echo "Build android failed!"
		exit 1
	fi
	mkdir -p $STUB_PATH
	mkdir -p $STUB_PATH/IMAGES/

	cp $PROJECT_TOP/out/target/product/$TARGET_PRODUCT/super.img $STUB_PATH/IMAGES/
	cp -rf $PROJECT_TOP/device/rockchip/rk3588/rk3588_docker/container $STUB_PATH/IMAGES/
	#ANDROID_VERSION= `get_build_var PRODUCT_ANDROID_VERSION`

	echo "pack docke android images: $TARGET_PRODUCT_$ANDROID_VERSION_$BUILD_VARIANT..."

	cd $STUB_PATH/IMAGES/

	mkdir super_img

	simg2img super.img super.img.ext4
	lpunpack super.img.ext4 super_img/

	tar --use-compress-program=pigz -cvpf $TARGET_PRODUCT-"$ANDROID_VERSION"-$BUILD_VARIANT-super.img-$DATE.tgz super_img/

	rm -rf super_img
	rm super.img
	rm super.img.ext4

	cd $PROJECT_TOP
fi

if [ "$BUILD_KERNEL" = true ] ; then
	# build kernel
	echo "Start build kernel"
#	export PATH=$PROJECT_TOP/prebuilts/clang/host/linux-x86/clang-r416183b/bin:$PATH
	export KERNEL_VERSION=`get_build_var PRODUCT_KERNEL_VERSION`
	if [ "$ANDROID_VERSION"x == "android10"x ]; then
		export LOCAL_KERNEL_PATH=kernel
	else
		export LOCAL_KERNEL_PATH=kernel-$KERNEL_VERSION
	fi
	echo "ANDROID_VERSION is: $ANDROID_VERSION"k
	export ADDON_ARGS="CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"
	export KERNEL_DTS=`get_build_var PRODUCT_LINUX_KERNEL_DTS`
	export KERNEL_ARCH=`get_build_var PRODUCT_KERNEL_ARCH`
	export KERNEL_DEFCONFIG=`get_build_var PRODUCT_LINUX_KERNEL_CONFIG`
	echo "KERNEL_DEFCONFIG: $KERNEL_DEFCONFIG; dts: $KERNEL_DTS"
	cd $LOCAL_KERNEL_PATH &&  make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_DEFCONFIG && make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_DTS.img -j$BUILD_JOBS && cd -
	#cd $LOCAL_KERNEL_PATH && make clean && make $ADDON _ARGS ARCH=$KERNEL_ARCH $KERNEL_DTS.img -j$BUILD_JOBS && cd -
	if [ $? -eq 0 ]; then
		mv $LOCAL_KERNEL_PATH/zboot.img $LOCAL_KERNEL_PATH/zboot-linux-$KERNEL_DTS.img
		if [ -d $STUB_PATH ];then
			cp $LOCAL_KERNEL_PATH/zboot-linux-$KERNEL_DTS.img $STUB_PATH/IMAGES/
		fi
		echo "Build kernel ok!"
	else
		echo "Build kernel failed!"
		exit 1
	fi

	cd $PROJECT_TOP
fi

if [ "$BUILD_PATCH" = true ] ; then
	#Generate patches
	mkdir -p $STUB_PATCH_PATH
	.repo/repo/repo forall  -c "$PROJECT_TOP/device/rockchip/common/gen_patches_body.sh"
	.repo/repo/repo manifest -r -o out/commit_id.xml
	 #Copy stubs
	 cp out/commit_id.xml $STUB_PATH/manifest_${DATE}.xml
fi


# tips: STUB_PATH=Image/"$TARGET_PRODUCT"_"$ANDROID_VERSION"_"$BUILD_VARIANT"_"$DATE"
# chaixiang
msg=$2
ip=192.168."$3"
num=$4

echo build_docker_android_snow.sh $msg $ip $num

filename=$TARGET_PRODUCT-"$ANDROID_VERSION"-$BUILD_VARIANT-super.img-$DATE.tgz
echo filename=$filename

cd $PROJECT_TOP

if [ -n "$msg" ]; then
    echo "msg is not empty"
	# 改名+打印
	echo mv $STUB_PATH IMAGE/AOSP_"$BUILD_VARIANT"_"$DATE"_"$msg"
	mv $STUB_PATH IMAGE/AOSP_"$BUILD_VARIANT"_"$DATE"_"$msg"
	filepath=IMAGE/AOSP_"$BUILD_VARIANT"_"$DATE"_"$msg"/IMAGES/$TARGET_PRODUCT-"$ANDROID_VERSION"-$BUILD_VARIANT-super.img-$DATE.tgz
	echo filepath=$filepath

	# 发送
	echo scp $filepath root@$ip:/userdata/snow/
	echo ssh root@$ip /userdata/init-in-arm/sh/build_image.sh /userdata/snow/$filename
	echo ssh root@$ip rm -rf /userdata/snow/$filename
	echo ssh root@$ip /userdata/arm-agent/bin/manage-shell/android_ctl.sh reset $num --image=latest
	echo ssh root@$ip docker ps

	scp $filepath root@$ip:/userdata/snow/
	ssh root@$ip /userdata/init-in-arm/sh/build_image.sh /userdata/snow/$filename
	ssh root@$ip rm -rf /userdata/snow/$filename
	ssh root@$ip /userdata/arm-agent/bin/manage-shell/android_ctl.sh reset $num --image=latest
	ssh root@$ip docker exec -it android_$num start adbd
	ssh root@$ip docker ps

else
    echo "msg is empty"
fi

end_time=$(date  +.%H%M)
echo $start_time - $end_time
echo ssh root@$ip docker exec -it android_$num 

# ip_=192.168.30.34
# id_=3
# scp $STUB_PATH/IMAGES/$TARGET_PRODUCT-"$ANDROID_VERSION"-$BUILD_VARIANT-super.img-$DATE.tgz  root@$ip_:/userdata/snow/
# ssh root@$ip_ build_image.sh /data/snow/$TARGET_PRODUCT-"$ANDROID_VERSION"-$BUILD_VARIANT-super.img-$DATE.tgz 
# ssh root@$ip_ android_ctl.sh restart $id_ --image=latest 
# echo  $STUB_PATH/IMAGES/$TARGET_PRODUCT-"$ANDROID_VERSION"-$BUILD_VARIANT-super.img-$DATE.tgz  root@$ip_:/userdata/snow/
