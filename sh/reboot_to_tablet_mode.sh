chmod 777 /vendor/etc/container/container.conf 
pm clear com.tencent.mm 
s9 ctlmap set /vendor/etc/container/container.conf     ro.build.characteristics   tablet  
s9 ctlmap set /vendor/etc/container/container.conf     ro.product.manufacturer    samsung
s9 ctlmap set /vendor/etc/container/container.conf     ro.product.device          f2q 
s9 ctlmap set /vendor/etc/container/container.conf     ro.product.name            f2qzcx 
s9 ctlmap set /vendor/etc/container/container.conf     ro.product.brand           samsung  
s9 ctlmap set /vendor/etc/container/container.conf     ro.product.model           SM-F9160  
chmod 755 /vendor/etc/container/container.conf  
reboot 