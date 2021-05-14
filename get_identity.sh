#!/bin/bash

# It only make sense asking local monitor
ft_mode=$(sudo echo "cuju-get-ft-mode" | sudo nc -w 1 -U /home/cujuft/vm1.monitor | grep cuju_ft_mode | awk '{split($0,a,": "); print a[2]}')
ft_started=$(sudo echo "cuju-get-ft-started" | sudo nc -w 1 -U /home/cujuft/vm1.monitor | grep ft_started | awk '{split($0,a,": "); print a[2]}')
porb=$1 # 'p' or 'b'

/media/cool/check_identity.py $porb $ft_mode $ft_started