#!/usr/bin/expect
# e.g. ./ssh_get_identity.sh localhost cujuft itrift p
set timeout 5
set host [lindex $argv 0]
set username [lindex $argv 1]
set porb [lindex $argv 2]
set password [lindex $argv 3]
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
	"Welcome" {send "/media/cool/get_identity.sh $porb\r"}
}

expect {
	"Primary, no ftmode." {exit 0}
    "Primary, ftmode."    {exit 2}
    "Backup, no ftmode."  {exit 0}
    "Backup, ftmode."     {exit 2}
    "Backup, failover"    {exit 0}
    "Unknown ft_mode: "   {exit 3}
}

expect eof
exit 10