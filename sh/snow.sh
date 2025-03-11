
source a_patches/sh/util.sh

echo 'a_patches/sh/snow.sh V=$1 msg=$2 ip=$3 num=$4'

V=$1
msg=$2
ip=$3
num=$4


run_cmd source build/envsetup.sh
run_cmd lunch 70
run_cmd a_patches/sh/build_docker_android_snow.sh -A --version=$V -msg=$msg

source a_patches/tmp/build_vars.tmp

echo "File Path: $file_path"
echo "Image Dir: $image_dir"
echo "image_name: $image_name"
echo "version: $version"

run_cmd a_patches/sh/send_run.sh $num $ip $file_path