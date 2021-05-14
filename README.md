# cuju-img-backup
### Environment setting
1. public key exchange
The two machines, primary and backup, are assumed to be capable to access each other via SSH without typing password. Hence, public key exchange is required.
3. Setting variable
	1. ```new_img_path```: The new bourned image will be stored at ```new_img_path```. It is ```/diskbackup``` by default. Note that you have to ```mkdir new_img_path``` by yourself.
	2. ```nfs_path```: This is the absolute pathname of this project. By default it is ```/mnt/nfs/cuju-img-backup```.
	3. ```$image_name```: By default is ```Ubuntu1804-SCADA-bak-manual```.
	4. ```$ip_org```: The ip address of running VM.
	5. ```$ip_chg```: This variable is used when the program is testing correctness of the new bourned image. In short, ```$ip_chg``` should be a valid and non-occupied ip address.
	6. ```active_file```: The overlay image (i.e. snapshot file), which is named ```whatanicesnapshot.qcow2``` bu default, and will be stored at the directory of this project. It will be deleted by our program automatically if the whole copying process doesn't go wrong.
	7. ```try```: The image is relatively fragile, so the copy process may not go perfectly every time. Variable ```$try``` is used to tell the program how many times you want to give QEMU chance to do the all copy-thing. It is setted to be ```1``` by default.
	8. Variables ```host_p```, ```user_p```, ```monitor_p```, ```host_b```, ```user_b``` and ```monitor_b``` are ssh and qmp monitor information. Note that ```monitor_x``` should be absolute path.

    Note that all of the variables can be found in file ```.env```.

3. File ```tgid_of_cp_drive``` is reserved for other program to pass POSIX signal to our program.

### Usage
Go to the directory, then run ```main_new.sh``` with argument ```<porb>```. ```<porb>``` is an argument to tell the program which host it is running on. If ```main_new.sh``` is running on primary machine, then ```<porb>``` should be ```p```. If it is on backup machine, then ```b``` should be passed.
```bash=
cd cuju-img-backup
./main_new.sh b     # We run this on backup-side machine.
```