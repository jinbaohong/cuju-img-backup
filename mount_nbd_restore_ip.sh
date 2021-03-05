#!/bin/bash
image=$1
ip_patr=$2
ip_sbst=$3
nbd_part=2
# nbd e.g. nbd2
# nbd2p2 e.g. nbd2p2
# ip_patr = ip we are going to replace .e.g. 192.168.77.161
# ip_sbst = new ip e.g. 192.168.77.160
# For example, ./mount_nbd_restore_ip.sh 1610091088 192.168.77.161 192.168.77.160



sudo modprobe nbd max_part=8
for i in {1..15}
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
# sudo partx -a /dev/nbd2
sync
sleep 1
# sudo fdisk -l | grep "nbd${i}p.*Linux filesystem" | awk '{split($0,a," "); print a[2]}'
sudo mount /dev/nbd${i}p${nbd_part} ./imgmnt
sync
sleep 1
sudo sed -i "s/$ip_patr/$ip_sbst/" ./imgmnt/etc/netplan/50-cloud-init.yaml
cat ./imgmnt/etc/netplan/50-cloud-init.yaml
sync
sleep 2

sudo umount ./imgmnt
while [ $? != 0 ]; do
	echo "Retry to umount..."
	sleep 2
	sudo umount ./imgmnt
done
echo "umount successfully!"

sudo qemu-nbd --disconnect /dev/nbd$i
sudo rmmod nbd

