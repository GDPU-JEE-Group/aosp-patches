#!/bin/bash
# 关闭解码器调试
setprop vendor.omx.vdec.debug 0
setprop mpp_debug 0
setprop vendor.mpp_debug 0

# 清除数据 dump 路径
setprop mpp_dump_in ""
setprop mpp_dump_out ""
setprop vendor.mpp_dump_in ""
setprop vendor.mpp_dump_out ""

# 关闭 HWC dump
setprop vendor.dump false

# 恢复系统安全策略
setenforce 1




# 删除调试数据
rm -rf /data/video/*
rm -rf /data/dump/*

echo "调试功能已关闭，调试数据已清理。"
