#变量------------
ip=192.168.168.59
num=0
filepath=IMAGE/AOSP_user_20240808.1317_clip-realse1-in/IMAGES/rk3588_docker_inland-android10-user-super.img-20240808.1317.tgz

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
	echo scp $filepath root@$ip:/userdata/snow/
	echo ssh root@$ip /userdata/init-in-arm/sh/build_image.sh /userdata/snow/$filename
	echo ssh root@$ip /userdata/arm-agent/bin/manage-shell/android_ctl.sh restart $num --image=latest
	echo ssh root@$ip rm -rf /userdata/snow/$filename
	echo ssh root@$ip docker ps

	scp $filepath root@$ip:/userdata/snow/
	ssh root@$ip /userdata/init-in-arm/sh/build_image.sh /userdata/snow/$filename
		ssh root@$ip /userdata/arm-agent/bin/manage-shell/android_ctl.sh reset $num
	ssh root@$ip /userdata/arm-agent/bin/manage-shell/android_ctl.sh restart $num --image=latest
	ssh root@$ip rm -rf /userdata/snow/$filename
	ssh root@$ip docker ps

echo ssh root@$ip 

kill-stream.sh $num
##  grep -rHn "s9.adbd.auth_required" .

## grep -Hn "s9.adbd.auth_required" $(find . -name "*.rc") --exclude-dir={out,prebuilts}
echo ssh root@$ip docker exec -it android_$num 
	sleep 3
	ssh root@$ip docker exec  android_$num start adbd
	echo ssh root@$ip docker exec  android_$num start adbd