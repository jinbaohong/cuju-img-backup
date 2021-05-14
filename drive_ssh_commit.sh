#!/usr/bin/expect
# e.g. ./drive_ssh_commit.sh /home/cujuft/qmp2.socket Ubuntu1804-SCADA-bak-manual.qcow2 localhost username password
set timeout 5
set qmp_monitor [lindex $argv 0]
set base_image [lindex $argv 1]
set host [lindex $argv 2]
set username [lindex $argv 3]
set password [lindex $argv 4]
set monitor [lindex $argv 5]
set command [lindex $argv 6]
spawn ssh $username@$host -p 22

# expect {
#     "nc: unix connect failed: Connection refused" {send "echo $command |sudo nc -w 1 -U $monitor\r\r"; sleep 1;exp_continue}
#     "Connection refused" {exit 1}
#     "Name or service not known" {exit 2}
#     "Connection timed out" {exit 3}
#     "No route to host" {exit 4}
#     "continue connecting" {send "yes\r";exp_continue}
#     "password:" {send "$password\r"}
# }


expect {
	"Welcome" {send "sudo nc -U $qmp_monitor\r"}
}

expect {
    "version" {send "{ 'execute' : 'qmp_capabilities' }\r"; exp_continue}
    "{\"return\": {}}" {send "{'execute': 'block-commit','arguments': {'device': 'drive0','job-id': 'job0','base':'$base_image'}}\r"}
}
set timeout -1

expect {
    "BLOCK_JOB_READY" {send "{'execute': 'block-job-complete','arguments': {'device': 'job0'}}\r"}
}

expect {
    "BLOCK_JOB_COMPLETED" {exit 0}
}



expect eof
exit 5