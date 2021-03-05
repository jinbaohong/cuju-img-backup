#!/bin/bash
# ./repair.sh Ubuntu1804-SCADA.qcow2 2
sudo modprobe nbd max_part=8

image=$1
nbd_part=$2
sync
sleep 1
for i in {2..15}
do
	sync
	sleep 1
	sudo qemu-nbd --connect=/dev/nbd$i $image
	if [ $? == 0 ]
	then
		sync
		sleep 1
		break
	fi
done

sudo fsck -y /dev/nbd${i}p${nbd_part}
sync
sleep 1
sudo qemu-nbd --disconnect /dev/nbd$i
sync
sudo rmmod nbd
