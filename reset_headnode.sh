# check for network first
if ping -c 1 72.14.177.74 &> /dev/null
then

	# remove home directories and ummount

	rm -r /home/admin
	rm -r /home/user

	# clear and unformat shared storage area

	rm -r /mnt/shared/*
	umount /mnt/shared
	wipefs /dev/sda3
	fdisk /dev/sda
	rm -r /mnt/shared

	# unmount apps
	unmount /mnt/apps
	rm -r /mnt/apps

	# wait for sanity
	echo "done!"
	sleep 10

	# shutdown
	shutdown now

else
	echo "Internet Access Required, Please Connec to Network"
fi
