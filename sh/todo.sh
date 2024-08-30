#!/bin/bash

# 检查是否提供了命令参数
if [ $# -lt 1 ]; then
  echo "Usage: $0 <command> [args...]"
  exit 1
fi

# 目标命令及参数
CMD="$@"

# 设置CPU占用率的阈值，超过该值时继续等待
THRESHOLD=60

# 初始化存储CPU使用率的数组
CPU_USAGES=()

while true; do
  # 初始化累计的CPU空闲率
  SUM_CPU_IDLE=0
  SAMPLES=6

  # 获取6次CPU空闲率，每次间隔1秒
  for i in $(seq 1 $SAMPLES); do
    CPU_IDLE=$(top -b -n1 | grep "Cpu(s)" | awk '{print $8}')
    SUM_CPU_IDLE=$(echo "$SUM_CPU_IDLE + $CPU_IDLE" | bc)
    sleep 1
  done

  # 计算平均CPU空闲率和CPU使用率
  AVG_CPU_IDLE=$(echo "$SUM_CPU_IDLE / $SAMPLES" | bc -l)
  AVG_CPU_USAGE=$(echo "100 - $AVG_CPU_IDLE" | bc)

  # 检查平均CPU使用率是否低于阈值
  if (( $(echo "$AVG_CPU_USAGE < $THRESHOLD" | bc -l) )); then
    # 如果低于阈值，执行目标命令
    echo "6-second average CPU usage is low: $AVG_CPU_USAGE%. Executing command: $CMD"
    $CMD
    break
  else
    # 否则继续等待并打印当前的平均CPU使用率
    echo "6-second average CPU usage is high: $AVG_CPU_USAGE%. Waiting..."
  fi
done
