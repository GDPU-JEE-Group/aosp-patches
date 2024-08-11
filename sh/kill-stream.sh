source util.sh

ip=$1
str="arm-stream -i"
num=$2

# 通过ssh在远程执行整个命令字符串
run_cmd ssh root@$ip "kill \$(ps -ef | grep '$str $num' | grep -v grep | awk '{print \$2}')"

run_cmd ssh root@$ip "docker exec android_$num start adbd"

