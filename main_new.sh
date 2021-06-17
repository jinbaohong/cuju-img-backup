#!/bin/bash
# $host       : The copied image's new ip (which is the ip after ./mount_nbd_change_ip.sh)
# $monitor    : The primary VM's qmp socket.
# $sleep_time : The period of polling block-job-query.
# $image      : The file name of backup image.
# e,g, sudo ./main_new.sh /media/cool/Ubuntu1804-SCADA-bak-manual.qcow2

# sudo modprobe nbd max_part=8
# sync
# sleep 1
# orig_image=$1
# porb=$1 # If run this script on primary, then pass p, vice versa.
source envi
# image_name=Ubuntu1804-SCADA-bak-manual
orig_image="${nfs_path}/${image_name}.qcow2"
# porb=$2

image="${new_img_dir}/${image_name}_bak_$(date +"%Y-%m-%d-%H-%M.qcow2")"


# image="${orig_image//.qcow2/}_bak_$(date +"%Y-%m-%d-%H-%M.qcow2")"
# ip_org="192.168.77.160"
# ip_chg="192.168.77.161"
# nbd="nbd2"
# nbdp="nbd2p2"
# active_file="/media/cool/whatanicesnapshot.qcow2"
# try=1

# host_p=$(grep primary < login_info | awk '{split($0,a,":"); print a[2]}')
# user_p=$(grep primary < login_info | awk '{split($0,a,":"); print a[3]}')
# monitor_p=$(grep primary < login_info | awk '{split($0,a,":"); print a[4]}')

# host_b=$(grep backup < login_info | awk '{split($0,a,":"); print a[2]}')
# user_b=$(grep backup < login_info | awk '{split($0,a,":"); print a[3]}')
# monitor_b=$(grep backup < login_info | awk '{split($0,a,":"); print a[4]}')

# Check if the space is enough. If it doesn't, then exit.
if (($(df -P $new_img_dir | tail -1 | awk '{print $4}') <= $(stat -c "%s" $orig_image) / 1024)); then
	echo "The free space of current folder is not enough."
	exit 2
fi

# Write ppid to a file, so the cancel_job script can terminate it.
echo $PPID > tgid_of_cp_drive


while (( try > 0 ))
do
	if [ $porb = p ]; then
		./ssh_get_identity.sh $host_p $user_p p $nfs_path $monitor_hmp_p
	else
		./ssh_get_identity.sh $host_b $user_b b $nfs_path $monitor_hmp_b
	fi
	res=$?
	if (( res != 0 )); then # FT
	# Set interrupt handler, because user can Ctrl+C to cancel the block job.
		# trap 'echo "Cancelling block job...";sudo ./job_cancel.sh $monitor 5; sync; sleep 2; sudo umount ./imgmnt; sudo qemu-nbd --disconnect /dev/nbd2; sudo rmmod nbd; echo "Done!"; exit 1;' INT
		echo "Creating backup-side snapshot..."
		./drive_ssh_snapshot.sh $monitor_b $active_file $host_b $user_b
		res=$?
		if (( res == 0 )); then
			echo "Successful!"
		else
			exit $res
		fi

		echo "Creating primary-side snapshot..."
		./drive_ssh_snapshot.sh $monitor_p $active_file $host_p $user_p
		res=$?
		if (( res == 0 )); then
			echo "Successful!"
		else
			exit $res
		fi

		trap 'echo "Cancelling cp process..."; sudo rm $image; sync; sudo ./drive_ssh_commit.sh $monitor_b $orig_image $host_b $user_b $password_b; sudo ./drive_commit.sh $monitor_p $orig_image $host_p $user_p $password_p; sudo umount ./imgmnt; sudo qemu-nbd --disconnect /dev/nbd2; sudo rmmod nbd; echo "Done!"; exit 1;' INT
		echo "The copy mission is running now."
		echo "If you want to abort the copy mission, press Ctrl+C."
		sudo cp $orig_image $image
		sync
		echo "Copy finished! The new image is $image"

		echo "Merging backup-side snapshot into base image..."
		./drive_ssh_commit.sh $monitor_b $orig_image $host_b $user_b
		res=$?
		if (( res == 0 )); then
			echo "Successful!"
		else
			./ssh_get_identity.sh $host_p $user_p p $nfs_path $monitor_hmp_p
			res=$?
			if (( res != 0 )); then
				echo "Error: In ft_mode but can't merge image."
				exit $res
			else
				echo "Warning: Backup env had failed."
			fi
		fi

		echo "Merging snapshot into base image..."
		# If fail over happened in the process of copy drive,
		# then the $monitor below should be $monitor_b, and
		# executed by backup VM.
		./drive_ssh_commit.sh $monitor_p $orig_image $host_p $user_p
		res=$?
		if (( res == 0 )); then
			echo "Successful!"
		else
			./ssh_get_identity.sh $host_b $user_b b $nfs_path $monitor_hmp_b
			res=$?
			if (( res != 0 )); then
				echo "Error: In ft_mode but can't merge image."
				exit $res
			else
				echo "Warning: Primary env had failed."
			fi
		fi

	else  # no-FT
		echo "Creating primary-side snapshot..."
		./drive_ssh_snapshot.sh $monitor_p $active_file $host_p $user_p
		res=$?
		if (( res == 0 )); then
			echo "Successful!"
		else
			exit $res
		fi

		trap 'echo "Cancelling cp process..."; sudo rm $image; sync; sudo ./drive_ssh_commit.sh $monitor_b $orig_image $host_b $user_b $password_b; sudo ./drive_commit.sh $monitor_p $orig_image $host_p $user_p $password_p; sudo umount ./imgmnt; sudo qemu-nbd --disconnect /dev/nbd2; sudo rmmod nbd; echo "Done!"; exit 1;' INT
		echo "The copy mission is running now."
		echo "If you want to abort the copy mission, press Ctrl+C."
		sudo cp $orig_image $image
		sync
		echo "Copy finished! The new image is $image"

		echo "Merging snapshot into base image..."
		./drive_ssh_commit.sh $monitor_p $orig_image $host_p $user_p
		res=$?
		if (( res == 0 )); then
			echo "Successful!"
		else
			exit $res
		fi
	fi

	echo "Cleaning snapshot..."
	sudo rm $active_file
	echo "Done!"

	./mount_nbd_restore_ip.sh $image $ip_org $ip_chg

	./check_ssh.sh $ip_chg $image
	res=$?

	./mount_nbd_restore_ip.sh $image $ip_chg $ip_org


	# If the image didn't corrupt, then we can leave directly.
	echo "res = $res"
	if (( res == 0 )); then
		sudo rmmod nbd
		exit $res
	fi
	((try--))
done

# sudo rmmod nbd



