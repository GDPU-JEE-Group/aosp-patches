source util.sh
png=$1.png
ip=192.168.168.5$2
1
# ssh -i /snow/android_rsa root@$ip sh

if [ -z "$1" ] ; then
    # 打印示例信息
    # echo "Usage: $0 <arg1> <arg2> <arg3>"
    # echo "Example: $0 value1 value2 value3"
    run_cmd ssh -i /snow/android_rsa root@$ip ls -al /sdcard/Download/
    run_cmd ssh -i /snow/android_rsa root@$ip am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/
    run_cmd ssh -i /snow/android_rsa root@$ip rm /sdcard/Download/*
    run_cmd ssh -i /snow/android_rsa root@$ip am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/
    run_cmd ssh -i /snow/android_rsa root@$ip ls -al /sdcard/Download/


    # 退出脚本
    exit 1
fi

    # run_cmd scp -i /snow/android_rsa a_patches/tmp/$png root@$ip:/sdcard/Download/$png
    # run_cmd ssh -i /snow/android_rsa root@$ip am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///storage/emulated/0/Download/
    # run_cmd ssh -i /snow/android_rsa root@$ip ls -al /storage/emulated/0/Download/
    # run_cmd ssh -i /snow/android_rsa root@$ip chmod -R 777 /sdcard/Download/*
    # run_cmd ssh -i /snow/android_rsa root@$ip ls -al /storage/emulated/0/Download/

    run_cmd scp -i /snow/android_rsa a_patches/tmp/$png root@$ip:/sdcard/Download/$png
    # run_cmd ssh -i /snow/android_rsa root@$ip am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///data/media/0/Download/$png
    run_cmd ssh -i /snow/android_rsa root@$ip am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///storage/emulated/0/Download/$png
    run_cmd ssh -i /snow/android_rsa root@$ip ls -al /storage/emulated/0/Download/
    run_cmd ssh -i /snow/android_rsa root@$ip chmod -R 777 /sdcard/Download/*
    run_cmd ssh -i /snow/android_rsa root@$ip ls -al /storage/emulated/0/Download/