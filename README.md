# cuju-img-backup
### Environment setting
1. The two machines, primary and backup, are assumed to be capable to access each other via SSH without typing password. Hence, public key exchange is required.
2. The new bourned image will be stored at ```/diskbackup``` by default, so you have to ```mkdir /diskbackup``` by yourself.
3. The overlay image (i.e. snapshot file) is named ```whatanicesnapshot.qcow2```, and will be stored at the directory of this project. It will be deleted by our program automatically if the whole copying process doesn't go wrong.
4. The image name is ```Ubuntu1804-SCADA-bak-manual.qcow2``` by default. You can change it at shell variable ```$image_name```.
5. The ip address of running VM should be stored at shell variable ```$ip_org```. Another similar variable ```$ip_chg``` is used when the program is testing the correctness of new bourned image. In short, ```$ip_chg``` should be a valid and non-occupied ip address.
6. The image is relatively fragile, so the copy process may not go perfectly every time. Variable ```$try``` is used to tell the program how many times you want to give QEMU chance to do the all copy-thing. It is setted to be ```1``` by default.
7. File ```tgid_of_cp_drive``` is reserved for other program to pass POSIX signal to our program.

### Usage
Go to the directory, then run ```main_new.sh``` with argument ```<porb>```. ```<porb>``` is an argument to tell the program which host it is running on. If ```main_new.sh``` is running on primary machine, then ```<porb>``` should be ```p```. If it is on backup machine, then ```b``` should be passed.
```bash=
cd cuju-img-backup
./main_new.sh b     # We run this on backup-side machine.
```