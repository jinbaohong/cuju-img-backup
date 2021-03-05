#!/usr/bin/expect
# e.g. ./drive_ssh_cp.sh /media/cool/Ubuntu1804-SCADA.qcow2 /media/cool/Ubuntu1804-SCADA-bak.qcow2 localhost username password
set timeout 5
set orig_image [lindex $argv 0]
set backup_image [lindex $argv 1]
set host [lindex $argv 2]
set username [lindex $argv 3]
set password [lindex $argv 4]
set monitor [lindex $argv 5]
set command [lindex $argv 6]
spawn ssh $username@$host -p 22

expect {
    "nc: unix connect failed: Connection refused" {send "echo $command |sudo nc -w 1 -U $monitor\r\r"; sleep 1;exp_continue}
    "Connection refused" {exit 1}
    "Name or service not known" {exit 2}
    "Connection timed out" {exit 3}
    "No route to host" {exit 4}
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "$password\r"}
}

expect {
	"Welcome" {send "cp $orig_image $backup_image\r"; sleep 5; send "touch zzzzzzz\r"; exit 0}
}

expect eof
exit 5