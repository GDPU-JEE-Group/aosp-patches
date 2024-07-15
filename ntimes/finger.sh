ssh tacserver@10.2.0.55
yes
tac2023

echo '---------------------------'
ifconfig

sudo su
tac2023

chmod 777 /userdata/arm-agent/bin/manage-shell/build_prop/default/vendor/build.prop 

sed -i '$c\\ro.build.fingerprint=samsung/GT-P7500/GT-P7500:3.2/HTJ85B/XWKL1:user/release-keys' /userdata/arm-agent/bin/manage-shell/build_prop/0/vendor/build.prop 
sed -i '$c\\ro.build.fingerprint=samsung/GT-P7500/GT-P7500:3.2/HTJ85B/XWKL1:user/release-keys' /userdata/arm-agent/bin/manage-shell/build_prop/1/vendor/build.prop 
sed -i '$c\\ro.build.fingerprint=samsung/GT-P7500/GT-P7500:3.2/HTJ85B/XWKL1:user/release-keys' /userdata/arm-agent/bin/manage-shell/build_prop/2/vendor/build.prop 
sed -i '$c\\ro.build.fingerprint=samsung/GT-P7500/GT-P7500:3.2/HTJ85B/XWKL1:user/release-keys' /userdata/arm-agent/bin/manage-shell/build_prop/3/vendor/build.prop 
sed -i '$c\\ro.build.fingerprint=samsung/GT-P7500/GT-P7500:3.2/HTJ85B/XWKL1:user/release-keys' /userdata/arm-agent/bin/manage-shell/build_prop/default/vendor/build.prop 

tail /userdata/arm-agent/bin/manage-shell/build_prop/1/vendor/build.prop
tail /userdata/arm-agent/bin/manage-shell/build_prop/3/vendor/build.prop

exit
exit

echo '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||'
