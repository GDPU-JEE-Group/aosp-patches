#!/bin/bash

DATE=$(date  +%Y%m%d.%H%M)
source build/envsetup.sh >/dev/null
export PATH=$ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r416183b/bin:$PATH
export TARGET_PRODUCT=`get_build_var TARGET_PRODUCT`
export BUILD_VARIANT=`get_build_var TARGET_BUILD_VARIANT`
export ANDROID_VERSION="android12"
export BUILD_JOBS=80

export PROJECT_TOP=`gettop`
lunch $TARGET_PRODUCT-$BUILD_VARIANT

STUB_PATH=Image/"$TARGET_PRODUCT"_"$ANDROID_VERSION"_"$BUILD_VARIANT"_"$DATE"
STUB_PATH="$(echo $STUB_PATH | tr '[:lower:]' '[:upper:]')"

export STUB_PATH=$PROJECT_TOP/$STUB_PATH
export STUB_PATCH_PATH=$STUB_PATH/PATCHES

while [ $# -gt 0 ]; do
    case "$1" in
        --version=*)
            # 提取版本号
            version="${1#*=}"
            echo "version:$version"
            shift
            ;;
	    -msg=*)
            # 提取版本号
            msg="${1#*=}"
            shift
            ;;
	-K)
            echo "will build linux kernel with Clang"
            BUILD_KERNEL=true
            shift
            ;;
        -A)
            echo "will build android"
            BUILD_ANDROID=true
            shift
            ;;
        -P)
            echo "will generate patch"
            BUILD_PATCH=true
            shift
            ;;
        *)  
	    shift
            ;;
    esac
done

# 检查是否找到了版本号
if [ -z "$version" ]; then
{
    echo "Error: No version number specified"
    echo "Usage: ./build_docker_android.sh -A --verison=0711"
}>&2
exit 1
fi

if [ "$BUILD_ANDROID" = true ] ; then
	# 判断是否存在lpunpack
	type lpunpack
	if [ $? -eq 0 ]; then
		echo "lpunpack is exit"
	else
		make lpunpack
	fi

	echo "start install clean"
	make installclean
	echo "start build android"
	# make -j$BUILD_JOBS
	make  
	# check the result of Makefile
	if [ $? -eq 0 ]; then
		echo "Build android ok!"
	else
		echo "Build android failed!"
		exit 1
	fi
	mkdir -p $STUB_PATH
	mkdir -p $STUB_PATH/IMAGES/

	cd $STUB_PATH/IMAGES/
	mkdir super_img

	# cp $PROJECT_TOP/out/target/product/$TARGET_PRODUCT/super.img $STUB_PATH/IMAGES/
	cp $PROJECT_TOP/out/target/product/$TARGET_PRODUCT/system.img $STUB_PATH/IMAGES/super_img/
	cp $PROJECT_TOP/out/target/product/$TARGET_PRODUCT/vendor.img $STUB_PATH/IMAGES/super_img
	cp -rf $PROJECT_TOP/device/ntimespace/rk3588_docker/container $STUB_PATH/IMAGES/
	#ANDROID_VERSION= `get_build_var PRODUCT_ANDROID_VERSION`

	echo "pack docke android images: $TARGET_PRODUCT_$ANDROID_VERSION_$BUILD_VARIANT..."


	# simg2img super.img super.img.ext4
	# lpunpack super.img.ext4 super_img/
	# simg2img system.img system.img.ext4
	# lpunpack system.img super_img/

	# simg2img vendor.img vendor.img.ext4
	# lpunpack vendor.img super_img/
        
	# IMAGE_LOCAL=$(echo $TARGET_PRODUCT |cut -d '_' -f3)
	# IMAGE_LOCAL="inland"
	
	# tar --use-compress-program=pigz -cvpf ./container/rk3588_docker-"$ANDROID_VERSION"-$BUILD_VARIANT-super.img-$version-$IMAGE_LOCAL.tgz super_img/
	tar --use-compress-program=pigz -cvpf ./container/rk3588_docker-"$ANDROID_VERSION"-$BUILD_VARIANT-$version-$msg.tgz super_img/

	rm -rf super_img
	# rm super.img
	# rm super.img.ext4
	# rm system.img
	# rm vendor.img

image_dir=$STUB_PATH
image_name=rk3588_docker-"$ANDROID_VERSION"-$BUILD_VARIANT-$version-$msg.tgz 
file_path=$STUB_PATH/IMAGES/container/$image_name
	cd $PROJECT_TOP
echo "file_path=$file_path" > a_patches/tmp/build_vars.tmp
echo "image_dir=$image_dir" >> a_patches/tmp/build_vars.tmp
echo "image_name=$image_name" >> a_patches/tmp/build_vars.tmp
echo "version=$version" >> a_patches/tmp/build_vars.tmp
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
	echo "ANDROID_VERSION is: $ANDROID_VERSION"
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
	.repo/repo/repo forall  -c "$PROJECT_TOP/device/ntimespace/common/gen_patches_body.sh"
	.repo/repo/repo manifest -r -o out/commit_id.xml
	#Copy stubs
	cp out/commit_id.xml $STUB_PATH/manifest_${DATE}.xml
fi

