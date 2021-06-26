#!/bin/bash

porb=$1 # 'p' or 'b'
nfs_path=$2
monitor_hmp=$3
# It only make sense asking local monitor
ft_mode=$(sudo echo "cuju-get-ft-mode" | sudo nc -w 1 -U $monitor_hmp | grep cuju_ft_mode | awk '{split($0,a,": "); print a[2]}')
ft_started=$(sudo echo "cuju-get-ft-started" | sudo nc -w 1 -U $monitor_hmp | grep ft_started | awk '{split($0,a,": "); print a[2]}')
echo "---------From get_identity.py arg start--------"
echo "porb="
echo $porb
echo "nfs_path="
echo $nfs_path
echo "monitor_hmp="
echo $monitor_hmp
echo "ft_mode="
echo $ft_mode
echo "ft_started="
echo $ft_started
echo "---------From get_identity.py arg end----------"
# /media/cool/check_identity.py $porb $ft_mode $ft_started
$nfs_path/check_identity.py $porb $ft_mode $ft_started