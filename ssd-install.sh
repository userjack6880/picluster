#!/bin/sh

### Check for root: ##############################################
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

################################################################
# check for network first
if ping -c 1 72.14.177.74 &> /dev/null
then
	echo "Online, continuing"
else
	echo "Internet Access Required, Please Connect to Network"
	exit
fi
################################################################

### Download image: ############################################
curl -LO j3b.in/pihpc/pi-head01-full.img.xz

### decompress and write to SSD: ###############################
cat pi-hpc-head01-full.img.xz | xz -d | dd of=$1 bs=50M status=progress conv=fsync

### Prompt user and poweroff:
echo "Done. After poweroff, remove power, SD card, and restore power"
sleep 5
poweroff