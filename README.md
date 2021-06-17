# cuju-img-backup
### Environment setting
img_mnt
1. Public key exchange:
	The two machines, Primary and Backup, are assumed to be capable to access each other and themself via SSH without sending password explicitly. Hence, public key exchange is required.
	We provide an easy way to do the exchange thing.
	1. On Primary, type ```ssh-keygen```: This command will create a public key ```id_rsa.pub``` under directory ```.ssh```.
	2. On Primary, copy the content of ```.ssh/d_rsa.pub```, then paste it into file ```.ssh/authorized_keys```. This step makes Primary can login itself passwordlessly.
	3. On Primary, copy the content of ```.ssh/d_rsa.pub```, then use ssh to login Backup and paste the copied content into file ```.ssh/authorized_keys```. This step makes Primary can login Backup passwordlessly.
	4. On Backup, type ```ssh-keygen```: This command will create a public key ```id_rsa.pub``` under directory ```.ssh```.
	5. On Backup, copy the content of ```.ssh/d_rsa.pub```, then paste it into file ```.ssh/authorized_keys```. This step makes Backup can login itself passwordlessly.
	6. On Backup, copy the content of ```.ssh/d_rsa.pub```, then use ssh to login Primary and paste the copied content into file ```.ssh/authorized_keys```. This step makes Backup can login Primary passwordlessly.
2. Create directory manually:
	Our program will use some directories, and it won't create them by itself, so you have to do it a favor.
	1. ```img_mnt```: When we are testing the new bourned image, we have to modify its IP address. In our approach, we need a mount point, which is ```img_mnt```.
	2. ```new_img_dir```: see Setting variable 1.
3. Setting variable:
    All of the variables can be found in file ```envi```.
	1. ```new_img_dir```: The new bourned image will be stored at ```new_img_dir```. It is ```/diskbackup``` by default. Note that you have to ```mkdir new_img_path``` by yourself.
	2. ```nfs_path```: This is the absolute pathname of this project. By default it is ```/mnt/nfs/cuju-img-backup```.
	3. ```$image_name```: By default is ```Ubuntu1804-SCADA-bak-manual```.
	4. ```$ip_org```: The ip address of running VM.
	5. ```$ip_chg```: This variable is used when the program is testing correctness of the new bourned image. In short, ```$ip_chg``` should be a valid and non-occupied ip address.
	6. ```active_file```: The overlay image (i.e. snapshot file), which is named ```whatanicesnapshot.qcow2``` bu default, and will be stored at the directory of this project. It will be deleted by our program automatically if the whole copying process doesn't go wrong.
	7. ```try```: The image is relatively fragile, so the copy process may not go perfectly every time. Variable ```$try``` is used to tell the program how many times you want to give QEMU chance to do the all copy-thing. It is setted to be ```1``` by default.
	8. Variables ```host_p```, ```user_p```, ```monitor_p```, ```monitor_hmp_p```, ```host_b```, ```user_b```, ```monitor_b``` and ```monitor_hmp_b``` are ssh and monitor information. Note that ```monitor_x``` and ```monitor_hmp_x``` should be absolute path.

4. File ```tgid_of_cp_drive``` is reserved for other program to pass POSIX signal to our program.

### Usage
Go to the directory, then run ```main_new.sh``` with argument ```<porb>```. ```<porb>``` is an argument to tell the program which host it is running on. If ```main_new.sh``` is running on primary machine, then ```<porb>``` should be ```p```. If it is on backup machine, then ```b``` should be passed.
```bash=
cd cuju-img-backup
./main_new.sh b     # We run this on backup-side machine.
```