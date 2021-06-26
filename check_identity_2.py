#!/usr/bin/python3

import sys

# porb = str(sys.argv[1])
ft_mode = str(sys.argv[1]).strip('\r')
ft_started = str(sys.argv[2]).strip('\r')

print("---------From check_identity_2.py arg start--------")
print(ft_mode)
print(ft_started)
print("---------From check_identity_2.py arg end----------")

    # no in ftmode = primary-0,0 backup-1,0
    # ftmode = primary-0,1 backup-5,0
    # failover = backup-6,0
    # back to no-ft = primary-0,0

if ft_mode == '0':
    if ft_started == '1':
        print("Primary, ftmode.")
        sys.exit(2)
    else:
        print("Primary, no ftmode.")
        sys.exit(0)
elif ft_mode == '1':
    print("Backup, no ftmode.")
    sys.exit(0)
elif ft_mode == '5':
    print("Backup, ftmode.")
    sys.exit(5)
elif ft_mode == '6':
    print("Backup, failover")
    sys.exit(0)
else:
    print("Unknown: ft_mode=", ftmode)
    sys.exit(8)


