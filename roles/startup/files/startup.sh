#!/bin/bash

stty_orig=`stty -g`
stty -echo
echo -ne 'nos? '
read PASS
stty $stty_orig

#SSD
echo $PASS | cryptsetup luksOpen /dev/md1 md1_open
if [ $? -ne 0 ]; then
   exit 1
fi

mount /dev/mapper/md1_open /mnt/raid1_fast
if [ $? -ne 0 ]; then
   exit 2
fi

#HDD
echo $PASS | cryptsetup luksOpen /dev/md2 md2_open
if [ $? -ne 0 ]; then
   exit 1
fi
mount /dev/mapper/md2_open /mnt/raid1_slow
if [ $? -ne 0 ]; then
   exit 3
fi

#services
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
