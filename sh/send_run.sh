source /snow/android10-rk3588/a_patches/sh/util.sh

#变量------------
num=$1
ip=192.168.$2
ip=$2
# filepath=IMAGE/AOSP_user_20240815.0713_clip-out/IMAGES/rk3588_docker_overseas-android10-user-super.img-20240815.0713.tgz
filepath=$3

#提取变量-------------
# 使用参数扩展提取文件名	
filename="${filepath##*/}"
# 使用 awk 提取 tag
tag=$(echo "$filepath" | awk -F'[-.]' '{print substr($(NF-2), 5) $(NF-1)}')

#输出结果--------
echo "Tag: $tag"
echo "filepath: $filepath"
echo "Filename: $filename"

	#运行----------------------------------


	run_cmd scp $filepath root@$ip:/userdata/snow/
	# run_cmd ssh root@$ip /userdata/init-in-arm/sh/build_image.sh /userdata/snow/$filename
	run_cmd ssh root@$ip /userdata/arm-agent/bin/manage-shell/android_ctl.sh createImage /userdata/snow/$filename
	run_cmd 	ssh root@$ip /userdata/arm-agent/bin/manage-shell/android_ctl.sh reset $num --image=latest
	# run_cmd ssh root@$ip /userdata/arm-agent/bin/manage-shell/android_ctl.sh restart $num --image=latest
	# run_cmd ssh root@$ip rm -rf /userdata/snow/$filename
	run_cmd ssh root@$ip docker ps

echo ssh root@$ip 

run_cmd kill-stream.sh $ip $num
##  grep -rHn "s9.adbd.auth_required" .

## grep -Hn "s9.adbd.auth_required" $(find . -name "*.rc") --exclude-dir={out,prebuilts}
