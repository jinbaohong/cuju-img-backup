#!/bin/bash
host=$1
image=$2
try=3
monitor=$image.monitor
echo "VM init from $image";

# sudo qemu-system-x86_64 \
sudo ./Cuju/x86_64-softmmu/qemu-system-x86_64 \
-drive if=none,id=drive1,cache=none,format=qcow2,file=$image \
-device virtio-blk,drive=drive1 \
-m 1.5G -enable-kvm \
-net tap,ifname=tap2 -net nic,model=virtio,vlan=0,macaddr=ae:ae:20:01:02:62 \
-cpu host \
-smp 1 \
-vga std -chardev socket,id=mon,path=$monitor,server,nowait -mon chardev=mon,id=monitor,mode=readline \
&


while (( try > 0 )); do
	sleep 60
	sudo ./ssh_connect_primaryvm.sh $host $image.monitor
	output=$?
	echo "output=$output"
	if (( output == 0)); then
	    echo "Primary VM running result: $?"
		echo "quit" | sudo nc -U $monitor
		exit $output
	else
	    echo "Primary VM closed result: $?"
	fi
	(( try-- ))
done

echo "quit" | sudo nc -U $monitor
exit $output

