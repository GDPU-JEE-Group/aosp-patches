http://www.anjian.com/download

内核不是x5,而是系统内核


正常
```
498b5e0ae422:/ # find -name "*x5*so"
./data/data/com.tencent.mtt/app_tbs/home/default/components/x5webview/46022/libx5log.so
./data/data/com.tencent.mtt/app_tbs/home/default/components/x5webview/46022/libx5patch.so
./data/data/com.tencent.mtt/app_tbs/home/default/components/x5webview/46022/libx5breakpad.so
./data/data/com.tencent.mtt/app_tbs/core_share/libx5lite.so
./data/app/com.tencent.mtt-ldHEGpzY_6xzXzE-WCHsWw==/lib/arm/libx5lite_lzma_1_6324106.so
./data/app/com.tencent.mtt-ldHEGpzY_6xzXzE-WCHsWw==/lib/arm/libx5lite_lzma_0_0.so
find: ./proc/24698/task/5975/fdinfo/197: No such file or directory
find: ./proc/24698/task/5975/fdinfo/199: No such file or directory
find: ./proc/24698/task/5976/fdinfo/196: No such file or directory
```


临时方案
pm install  system/priv-app/qqbrowser_15.1.5.5032_GA_20240604_115940_1100125022/qqbrowser_15.1.5.5032_GA_20240604_115940_1100125022.apk && pm clear com.tencent.mtt