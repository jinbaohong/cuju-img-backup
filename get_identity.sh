#!/bin/bash

porb=$1 # 'p' or 'b'
nfs_path=$2
monitor_hmp=$3
# It only make sense asking local monitor
ft_mode=$(sudo echo "cuju-get-ft-mode" | sudo nc -w 1 -U $monitor_hmp | grep cuju_ft_mode | awk '{split($0,a,": "); print a[2]}')
ft_started=$(sudo echo "cuju-get-ft-started" | sudo nc -w 1 -U $monitor_hmp | grep ft_started | awk '{split($0,a,": "); print a[2]}')


# /media/cool/check_identity.py $porb $ft_mode $ft_started
$nfs_path/check_identity.py $porb $ft_mode $ft_started