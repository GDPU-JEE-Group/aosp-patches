ssh tacserver@10.2.0.56
tac2023

echo '---------------------------'
ip a |grep eth0

sudo su
tac2023

docker exec -it android_0 sh

reboot


docker exec -it android_1 sh

reboot


docker exec -it android_2 sh

reboot


docker exec -it android_3 sh

reboot


docker exec -it android_0 sh
pm clear com.google.android.gms
start adbd
exit

docker exec -it android_1 sh
pm clear com.google.android.gms
start adbd
exit

docker exec -it android_2 sh
pm clear com.google.android.gms
start adbd
exit

docker exec -it android_3 sh
pm clear com.google.android.gms
start adbd
exit

exit
exit
echo '|||||||||||||||||||||||||||||||||||||||||'
csnow