#!/bin/bash

stty_orig=`stty -g`
stty -echo
echo -ne 'nos? '
read PASS
stty $stty_orig

#stop wtf md127
mdadm --stop /dev/md127

#NEW /home
mdadm --assemble /dev/md1 /dev/sda2 /dev/sdb2

echo $PASS | cryptsetup luksOpen /dev/md1 md1_open
if [ $? -ne 0 ]; then
   exit 1
fi

mount /dev/mapper/md1_open /mnt/raid1_1TB
if [ $? -ne 0 ]; then
   exit 2
fi

#NEW /mnt/data
echo $PASS | cryptsetup luksOpen /dev/sda5 sda5_open
if [ $? -ne 0 ]; then
   exit 1
fi
mount /dev/mapper/sda5_open /mnt/noraid_2TB
if [ $? -ne 0 ]; then
   exit 3
fi

systemctl start docker.socket
if [ $? -ne 0 ]; then
   exit 4
fi

systemctl start docker.service

if [ $? -ne 0 ]; then
   exit 5
fi

echo OK
exit 0
