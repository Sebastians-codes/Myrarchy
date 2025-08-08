#!/bin/bash

# Get CPU usage
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
if [ -z "$cpu" ]; then
    cpu=$(awk '/cpu /{u=$2+$4; t=$2+$3+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1) "%"; }' <(grep 'cpu ' /proc/stat; sleep 1; grep 'cpu ' /proc/stat) | head -1 | cut -d'%' -f1)
fi
cpu=$(printf "%.0f" "$cpu")

# Get memory usage
mem=$(free | awk '/^Mem:/ {printf "%.0f", $3*100/$2}')

echo "${cpu}% 󰻠 ${mem}% 󰍛"