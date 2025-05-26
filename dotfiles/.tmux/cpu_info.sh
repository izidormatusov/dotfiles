#!/bin/bash
#
# Print the current CPU utilization

case $(uname -s) in
  Linux)
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf("%2d%%", 100 - $1)}'
  ;;
  Darwin)
    cpuvalue=$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')
    cpucores=$(sysctl -n hw.logicalcpu)
    echo "$(( cpuvalue / cpucores ))%"
  ;;
  *)
    echo "Unsupported :("
  ;;
esac

sleep 1
