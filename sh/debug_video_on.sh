#!/bin/bash
# 创建调试目录
mkdir -p /data/video
mkdir -p /data/dump
chmod 777 /data/video
chmod 777 /data/dump

# 关闭 SELinux（调试期间关闭，调试后请记得恢复）
setenforce 0

# 配置 OMX 解码器调试功能
setprop vendor.omx.vdec.debug 0x03000000  # 同时捕获输入和输出数据

# 设置解码数据 dump 路径
setprop mpp_dump_in /data/video/mpp_dec_in.bin
setprop mpp_dump_out /data/video/mpp_dec_out.bin
setprop vendor.mpp_dump_in /data/video/mpp_dec_in.bin
setprop vendor.mpp_dump_out /data/video/mpp_dec_out.bin

# 开启 MPP 框架调试功能（捕获输入和输出数据）
setprop mpp_debug 0x600
setprop vendor.mpp_debug 0x600

# HWC 数据 dump（开启和存储路径默认为 /data/dump/）
setprop vendor.dump true

echo "调试功能已开启。调试数据将保存到 /data/video 和 /data/dump/。"



